local Vote = class({});
local Kick = Kick;
if not Kick then
    Kick = require("Kick");
    Kick:Initialize();
end

-- TODO SET TIMEOUTS
local VOTE_TIMEOUT = 10;
local VOTE_BUTTON_COOLDOWN = 5; -- cooldown after voting ends
local VOTE_BUTTON_INITIAL_COOLDOWN = 0; -- cooldown after match start 
local VOTES_TO_KICK = 5;
local VOTE_OPTIONS = {
    YES = "Yes",
    NO = "No",
    NEITHER = "Neither"
}

local NET_TABLE_NAME = "vote_table";
-- Table Contents:
-- subjectId
    -- key is player ID of player to kick
    -- value is table containing:
        -- table containing:
            -- "numVoters" number of people that can vote
                -- current number of players minus subject (GetTeamPlayerCount)
            -- "numVotes"
            -- "numYes" number of yes's
            -- "votes" each player's votes
                -- votes[voterID] = "yes"/"no"/"neither"
                -- iterate through table to process results
local NET_TEAM_TABLE_NAME = "vote_team_table";
-- Table Contents:
-- teamId (radiant or dire) 
    -- key is a teamID
    -- value is table containing:
        -- voteInProgress
            -- subjectId
                -- player going to be kicked
                -- used as a lock on votes
                -- nil means no in progress votes, i.e. this can be used as a lock
        -- cooldown
                -- is true if vote kick is on cooldown

local DISCONNECT_TABLE_NAME = "disconnected";
-- Table Contents
-- teamId -> table that maps playerId to true if disconnect or false/nil otherwise



function Vote:Initialize()
    CustomNetTables:SetTableValue( "vote", "settings", { timeOut = VOTE_TIMEOUT } );
    CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(DOTA_TEAM_GOODGUYS), { voteInProgress = nil, cooldown = 1 } );
    CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(DOTA_TEAM_BADGUYS), { voteInProgress = nil, cooldown = 1 } );
    CustomNetTables:SetTableValue( DISCONNECT_TABLE_NAME, tostring(DOTA_TEAM_GOODGUYS), { } );
    CustomNetTables:SetTableValue( DISCONNECT_TABLE_NAME, tostring(DOTA_TEAM_BADGUYS), { } );

    CustomGameEventManager:RegisterListener( "begin_voting", Dynamic_Wrap( self, "BeginVoting" ) );
    CustomGameEventManager:RegisterListener( "vote", Dynamic_Wrap( self, "ReceiveVote" ) );

    GameRules:GetGameModeEntity():SetThink(function () 
        CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(DOTA_TEAM_GOODGUYS), { voteInProgress = nil, cooldown = 0 } );
        CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(DOTA_TEAM_BADGUYS), { voteInProgress = nil, cooldown = 0 } );
        CustomGameEventManager:Send_ServerToAllClients( "display_error_from_server", {message = "Vote kick is now off cooldown."});
    end, self, "Initial Cooldown", VOTE_BUTTON_INITIAL_COOLDOWN );
end

local lock = false;
function Vote:BeginVoting( event )

    if lock then
        return nil;
    else
        lock = true;
    end

    -- event.playerId, event.subjectId
    local playerId = event.playerId;
    local subjectId = event.subjectId;
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local subjectTeamId = PlayerResource:GetTeam(subjectId);

    -- check team vote lock
    local table = CustomNetTables:GetTableValue( NET_TEAM_TABLE_NAME, tostring(playerTeamId) ); 
    if table.voteInProgress then
        local error = {
            message = "A vote is already in progress for your team."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        lock = false;
        return nil;
    elseif table.cooldown == 1 then
        local error = {
            message = "Vote kick is on cooldown."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_AbilityInCooldown" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        lock = false;
        return nil;
    end

    if playerId == subjectId then
        local error = {
            message = "Cannot kick yourself."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        lock = false;
        return nil;
    end

    -- check same team
    if playerTeamId ~= subjectTeamId then
        local error = {
            message = "Cannot kick players on different teams."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        lock = false;
        return nil;
    end
    
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.playerId), "display_error_from_server", {message = "Begin voting!"});

    -- set lock
    CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(playerTeamId), { voteInProgress = subjectId, cooldown = 1} );

    -- set net table
    Vote:ResetNetTable( subjectId );
    -- apply vote from initiating player
    Vote:UpdateNetTable( playerId, subjectId, VOTE_OPTIONS.YES );

    -- set timeout for vote using thinker
    -- need closure to capture subjectId
    GameRules:GetGameModeEntity():SetThink(function () 
        Vote:EndVoting(subjectId);
    end, self, "EndVotingTimeout", VOTE_TIMEOUT );

    -- send vote button disable timeout to client
    Vote:RequestVotes( playerId, subjectId );
    lock = false;
end

function Vote:RequestVotes( playerId, subjectId )
    -- send vote request to everyone on same team except the above two players
    -- or let client handle displaying correct dialog
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local subjectSteamId = PlayerResource:GetSteamID(subjectId);
    local subjectHero = PlayerResource:GetSelectedHeroName(subjectId);
    -- local subjectTeam = PlayerResource:GetTeam(subjectId);
    local event = {
        playerId = playerId,
        subjectId = subjectId,
        subjectSteamId = subjectSteamId,
        subjectHero = subjectHero,
        voteOptions = VOTE_OPTIONS
    };
    CustomGameEventManager:Send_ServerToTeam( playerTeamId , "request_votes", event );
end

function Vote:ReceiveVote( event )
    -- handle vote sent by player
    local table = Vote:UpdateNetTable( event.voterId, event.subjectId, event.vote );
    -- send vote net table info to client to update dialog box
    local teamId = PlayerResource:GetTeam(event.voterId);
    CustomGameEventManager:Send_ServerToTeam( teamId, "update_votes", table );

    if Vote:IsComplete( event.subjectId ) then
        Vote:EndVoting( event.subjectId );
    end
end

function Vote:OnPlayerReconnect( event )
    -- update disconnected table
    local playerId = event.playerId;
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local disconnected = CustomNetTables:GetTableValue( DISCONNECT_TABLE_NAME, tostring(playerTeamId) );
    disconnected[tostring(playerId)] = false;
    CustomNetTables:SetTableValue( DISCONNECT_TABLE_NAME, tostring(playerTeamId), disconnected );
end

function Vote:OnPlayerDisconnect( event )

    -- update disconnected table
    local playerId = event.playerId;
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local disconnected = CustomNetTables:GetTableValue( DISCONNECT_TABLE_NAME, tostring(playerTeamId) );
    disconnected[tostring(playerId)] = true;
    CustomNetTables:SetTableValue( DISCONNECT_TABLE_NAME, tostring(playerTeamId), disconnected );

    -- the point of the following is that disconnecting reduces the number of voters
    -- which can change the outcome of an in-progress vote

    -- do something if player is on same team as a subject player
    -- i.e. get team table and check voteInProgress 
    local teamTable = CustomNetTables:GetTableValue( NET_TEAM_TABLE_NAME, tostring(playerTeamId) );

    -- does not matter if vote is not in progress
    if not teamTable.voteInProgress then
        return nil;
    end

    local subjectId = teamTable.voteInProgress;

    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) );

    -- change number of voters
    table.numVoters = Vote:GetNumVoters( subjectId );

    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );

    CustomGameEventManager:Send_ServerToTeam( playerTeamId, "update_votes", table );

    -- check kick condition
    if Vote:IsComplete( event.subjectId ) then
        Vote:EndVoting( event.subjectId );
    end

    return nil;
end

function Vote:IsComplete( subjectId )
    -- check net table to see if finished
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) ); 
    local kickCondition = Vote:KickCondition( table );
    local allVoted = (table.numVotes == table.numVoters);
    return kickCondition or allVoted;
end

function Vote:KickCondition( table )
    local threshold = math.min(VOTES_TO_KICK, table.numVoters);
    local kickCondition = (table.numYes >= threshold);
    return kickCondition;
end

function Vote:ResetNetTable( subjectId )
    local table = {
        numVoters = Vote:GetNumVoters(subjectId), 
        numVotes = 0,
        numYes = 0,
        votes = {}
    };
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );
end

function Vote:UpdateNetTable( voterId, subjectId, vote )
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) );

    table.numVotes = table.numVotes + 1;
    if vote == VOTE_OPTIONS.YES then 
        table.numYes = table.numYes + 1;
    end
    table.votes[tostring(voterId)] = vote;
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );
    return table;
end

function Vote:EndVoting( subjectId )

    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    -- emit event to team 
    -- simply has to close dialog for players via event emission
    -- probably unused event value
    local event = {
        subjectId = subjectId
    };
    CustomGameEventManager:Send_ServerToTeam( subjectTeamId, "end_voting", event );

    -- set voteInProgress to nil, but cooldown to true
    CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(subjectTeamId), { voteInProgress = nil, cooldown = 1 } );

    -- release team vote lock after delay
    GameRules:GetGameModeEntity():SetThink(function () 
        -- TODO REMOVE
        CustomGameEventManager:Send_ServerToTeam( subjectTeamId, "display_error_from_server", {message = "Vote kick is now off cooldown."});
        CustomNetTables:SetTableValue( NET_TEAM_TABLE_NAME, tostring(subjectTeamId), { voteInProgress = nil, cooldown = 0 } );
    end, self, "UnlockVoting", VOTE_BUTTON_COOLDOWN );

    -- process results
    Vote:HandleVoteResults( subjectId );

    return nil; -- end thinker
end

function Vote:HandleVoteResults( subjectId )
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) ); 
    if Vote:KickCondition(table) then
        Kick:KickPlayer( subjectId );
        -- play axe successs sound on all players
        -- TODO
        CustomGameEventManager:Send_ServerToAllClients( "display_error_from_server", {message = "Vote kick successful."});
        CustomGameEventManager:Send_ServerToAllClients( "play_sound", { sound = "ui.report_negative" } );
    else
        -- play axe fail sound on all players
        -- TODO
        CustomGameEventManager:Send_ServerToAllClients( "display_error_from_server", {message = "Vote kick failed."});
        CustomGameEventManager:Send_ServerToAllClients( "play_sound", { sound = "Hero_Axe.Culling_Blade_Failed" } );
    end
end

function Vote:GetNumVoters( subjectId )
    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    local disconnected = CustomNetTables:GetTableValue( DISCONNECT_TABLE_NAME, tostring(subjectTeamId) );
    -- count up number of non disconnected players
    local count = 0;
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        if PlayerResource:IsValidPlayerID(playerId) then
            local playerTeamId = PlayerResource:GetTeam(playerId);
            if (playerTeamId == subjectTeamId) and not disconnected[tostring(playerId)] then
                count = count + 1;
            end
        end
    end
    return count;
end


return Vote;