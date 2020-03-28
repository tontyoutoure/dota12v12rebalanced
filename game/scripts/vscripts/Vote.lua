local Vote = class({});
local Kick = require("Kick");
Vote.Kick = Kick;

function Vote:GetKick()
    return Vote.Kick;
end

-- vote timeout does not respect pause (which is intentional)
-- doesn't matter though since pause is disabled
-- cooldown respects pauses

-- NOTES: thinkers can collide here, need to assign unique names for each team

local VOTE_TIMEOUT = 15; -- 15
local VOTE_BUTTON_COOLDOWN = 60; -- cooldown after voting ends -- 60 
local INITIAL_AVAILABLE_TIME = 0; -- time when voting becomes off cooldown 0 is game start
local MAX_VOTE_INITIATIONS_PER_PLAYER = 1; -- if change, update message
local VOTES_TO_KICK = 6;
local VOTE_OPTIONS = {
    YES = "Yes",
    NO = "No"
};

function Vote:Threshold( voteTable )
    -- return math.min(VOTES_TO_KICK, voteTable.numVotes); --TODO change to voters
    return VOTES_TO_KICK;
end

local SUBJECT_VOTE_TABLE = {};
-- Table Contents:
-- subjectId
    -- "numVoters" number of people that can vote
        -- current number of players minus subject (GetTeamPlayerCount)
    -- "numVotes"
    -- "numYes" number of yes's
    -- "votes" each player's votes
        -- "Yes", "No", or nil

local TEAM_VOTE_STATUS = {};
-- Table Contents:
-- teamId (radiant or dire) 
    -- voteInProgress
    -- cooldown
        -- true if on cooldown (this is necessary for triggering when it goes off cooldown)
    -- availableTime
        -- time when off cooldown
    -- subjectId

local DISCONNECTED = {};
-- Table Contents
-- teamId -> table that maps playerId to true if disconnect or false/nil otherwise

local VOTES_INITIATED = {};
-- playerId -> number of votes triggered

function Vote:TeamName( teamId )
    if teamId == DOTA_TEAM_GOODGUYS then
        return "<font color='#00ee00'>Radiant</font>";
    elseif teamId == DOTA_TEAM_BADGUYS then
        return "<font color='#ee0000'>Dire</font>";
    else 
        return "Team "..teamId;
    end
end

function Vote:TeamMessage( teamId, message )
    local teamName = Vote:TeamName(teamId);
    GameRules:SendCustomMessage(teamName.." | "..message, 0, 0);
end

function Vote:PlayerNameString(playerId)
    local playerName = PlayerResource:GetPlayerName(playerId);
    return "<font color='#eeeeee'>"..playerName.."</font>";
end

function Vote:Initialize()

    -- ListenToGameEvent('player_disconnect', Dynamic_Wrap(Vote, 'OnPlayerDisconnect'), Vote);
    -- ListenToGameEvent('player_resconnect', Dynamic_Wrap(Vote, 'OnPlayerReconnect'), Vote);
    Kick:Initialize( GameRules );

    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        VOTES_INITIATED[playerId] = 0;
    end

    TEAM_VOTE_STATUS[DOTA_TEAM_GOODGUYS] = { voteInProgress = false, cooldown = true, availableTime = INITIAL_AVAILABLE_TIME, subjectId = nil };
    TEAM_VOTE_STATUS[DOTA_TEAM_BADGUYS] = { voteInProgress = false, cooldown = true, availableTime = INITIAL_AVAILABLE_TIME, subjectId = nil };
    GameRules:SendCustomMessage("Start a vote kick by clicking the Boots icon on the scoreboard. Vote kicking becomes available when the clock hits <font color='#eeeeee'>0:00</font>.", 0, 0);

    CustomGameEventManager:RegisterListener( "begin_voting", Dynamic_Wrap( Vote, "BeginVoting" ) );
    CustomGameEventManager:RegisterListener( "vote_submitted", Dynamic_Wrap( Vote, "ReceiveVote" ) );

    local time = GameRules:GetDOTATime(false, true);
    GameRules:GetGameModeEntity():SetThink(function () 
        TEAM_VOTE_STATUS[DOTA_TEAM_GOODGUYS].cooldown = false;
        TEAM_VOTE_STATUS[DOTA_TEAM_BADGUYS].cooldown = false;
        Vote:TeamMessage( DOTA_TEAM_GOODGUYS, "Vote kick is now off cooldown.");
        Vote:TeamMessage( DOTA_TEAM_BADGUYS, "Vote kick is now off cooldown.");
        return nil;
    end, "Vote Initial Cooldown", INITIAL_AVAILABLE_TIME - time );
end

function Vote:BeginVoting( event )

    -- event.playerId, event.subjectId
    local playerId = event.playerId;
    local subjectId = event.subjectId;
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    local time = GameRules:GetDOTATime(false, true);

    local teamTable = TEAM_VOTE_STATUS[playerTeamId];
    if not (VOTES_INITIATED[playerId] < MAX_VOTE_INITIATIONS_PER_PLAYER) then
        local error = {
            message = "You can only initiate a vote once!"
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    elseif teamTable.voteInProgress then
        local error = {
            message = "A vote is already in progress for your team."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    elseif teamTable.cooldown then
        local remainingTime = teamTable.availableTime - time;
        local error = {
            message = "Vote kick is on cooldown for "..math.floor(remainingTime + 0.5).." more seconds."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_AbilityInCooldown" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    elseif playerId == subjectId then
        local error = {
            message = "Cannot kick yourself."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    elseif playerTeamId ~= subjectTeamId then
        local error = {
            message = "Cannot kick players on different teams."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    end

    VOTES_INITIATED[playerId] = VOTES_INITIATED[playerId] + 1;
    
    Vote:TeamMessage(subjectTeamId, "A vote to kick "..Vote:PlayerNameString(subjectId).." has begun!");

    teamTable.voteInProgress = true;
    teamTable.subjectId = subjectId;

    -- set vote table
    Vote:ResetVoteTable( subjectId );
    -- apply vote from initiating player
    Vote:UpdateVoteTable( playerId, subjectId, VOTE_OPTIONS.YES );

    local voteTable = SUBJECT_VOTE_TABLE[subjectId];

    local message = "Vote Initiated | Votes: "..(voteTable.numVotes)..
                    " | Kick: "..(voteTable.numYes)..
                    " | Don't Kick: "..(voteTable.numVotes - voteTable.numYes)..
                    " | Did Not Vote: "..(voteTable.numVoters - voteTable.numVotes);
    Vote:TeamMessage(subjectTeamId, message);

    -- check kick condition
    if Vote:IsComplete( subjectId ) then
        Vote:EndVoting( subjectId );
        return nil;
    end

    -- set timeout for vote using thinker
    -- need closure to capture subjectId
    GameRules:GetGameModeEntity():SetThink(function () 
        Vote:EndVoting(subjectId);
        return nil;
    end, "Team "..subjectTeamId.." End Voting", VOTE_TIMEOUT );

    -- send vote button disable timeout to client
    Vote:RequestVotes( playerId, subjectId );
end

function Vote:RequestVotes( playerId, subjectId )
    -- send vote request to everyone on same team except the above two players
    -- or let client handle displaying correct dialog
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local subjectName = PlayerResource:GetPlayerName(subjectId);
    local subjectHero = PlayerResource:GetSelectedHeroName(subjectId);
    -- local subjectTeam = PlayerResource:GetTeam(subjectId);
    local event = {
        playerId = playerId,
        subjectId = subjectId,
        subjectName = subjectName,
        subjectHero = subjectHero, -- for displaying hero
        voteOptions = VOTE_OPTIONS,
        timeOut = VOTE_TIMEOUT
    };
    CustomGameEventManager:Send_ServerToTeam( playerTeamId , "request_votes", event );
end

function Vote:ReceiveVote( event )
    -- handle vote sent by player
    local voterId = event.voterId;
    local subjectId = event.subjectId;
    local vote = event.vote;
    Vote:UpdateVoteTable( voterId, subjectId, vote );

    local voteTable = SUBJECT_VOTE_TABLE[subjectId];
    local teamId = PlayerResource:GetTeam(voterId);

    -- not used
    -- CustomGameEventManager:Send_ServerToTeam( teamId, "update_votes", table );

    local message = "Vote Submitted | Votes: "..(voteTable.numVotes)..
                    " | Kick: "..(voteTable.numYes)..
                    " | Don't Kick: "..(voteTable.numVotes - voteTable.numYes)..
                    " | Did Not Vote: "..(voteTable.numVoters - voteTable.numVotes);
    Vote:TeamMessage(teamId, message);

    if Vote:IsComplete( subjectId ) then
        Vote:EndVoting( subjectId );
        return nil;
    end
end

--[[
function Vote:OnPlayerReconnect( event )
    if not event.PlayerID then -- failsafe if argument is not what is expected
        return nil;
    end
    DISCONNECTED[event.playerID] = false;
end
--]]

-- TODO FIX UP
--[[
function Vote:OnPlayerDisconnect( event )
    -- the point of the following is that disconnecting reduces the number of voters
    -- which can change the outcome of an in-progress vote


    -- update disconnected table
    local playerId = event.PlayerID;
    DISCONNECTED[playerId] = true;

    local playerTeamId = PlayerResource:GetTeam(playerId);

    local teamTable = TEAM_VOTE_STATUS[playerTeamId];
    if not teamTable.voteInProgress then -- does not matter if vote is not in progress
        return nil;
    end
    
    local subjectId = teamTable.subjectId;
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];

    if not voteTable.votes[playerId] then -- does not matter if player did not vote
        return nil;
    else -- else set their vote to false
        voteTable.votes[playerId] = VOTE_OPTIONS.NO;
    end

    -- recompute number of voters
    voteTable.numVoters = Vote:GetNumVoters( subjectId );

    -- update players on change
    CustomGameEventManager:Send_ServerToTeam( playerTeamId, "update_votes", voteTable);
    local message = "Vote Submitted | Votes: "..(voteTable.numVotes)..
                    " | Kick: "..(voteTable.numYes)..
                    " | Don't Kick: "..(voteTable.numVotes - voteTable.numYes)..
                    " | Did Not Vote: "..(voteTable.numVoters - voteTable.numVotes);
    Vote:TeamMessage(subjectTeamId, message);

    -- check kick condition
    if Vote:IsComplete( subjectId ) then
        Vote:EndVoting( subjectId );
        return nil;
    end

    return nil;
end
--]]

function Vote:IsComplete( subjectId )
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];
    local kickCondition = Vote:KickCondition( voteTable );
    local allVoted = (voteTable.numVotes == voteTable.numVoters);
    return kickCondition or allVoted;
end

function Vote:KickCondition( voteTable )
    return voteTable.numYes >= Vote:Threshold(voteTable);
end

function Vote:ResetVoteTable( subjectId )
    SUBJECT_VOTE_TABLE[subjectId] = {
        numVoters = Vote:GetNumVoters(subjectId), 
        numVotes = 0,
        numYes = 0,
        votes = {}
    };
end

function Vote:UpdateVoteTable( voterId, subjectId, vote )
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];
    voteTable.numVotes = voteTable.numVotes + 1;
    if vote == VOTE_OPTIONS.YES then 
        voteTable.numYes = voteTable.numYes + 1;
    end
    voteTable.votes[voterId] = vote;
end

function Vote:EndVoting( subjectId )

    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    -- emit event to team 
    -- simply has to close dialog for players via event emission
    -- probably unused event value
    local event = {
        subjectId = subjectId
    };
    CustomGameEventManager:Send_ServerToTeam( subjectTeamId, "end_voting", event ); -- close vote dialog

    local time = GameRules:GetDOTATime(false, true);
    TEAM_VOTE_STATUS[subjectTeamId].voteInProgress = false;
    TEAM_VOTE_STATUS[subjectTeamId].cooldown = true;
    TEAM_VOTE_STATUS[subjectTeamId].availableTime = time + VOTE_BUTTON_COOLDOWN;
    TEAM_VOTE_STATUS[subjectTeamId].subjectId = nil;

    -- release team vote lock after delay
    GameRules:GetGameModeEntity():SetThink(function () 
        TEAM_VOTE_STATUS[subjectTeamId].cooldown = false;
        local message = "Vote kick is now off cooldown.";
        Vote:TeamMessage(subjectTeamId, message);
        return nil;
    end, "Team "..subjectTeamId.." Unlock Voting", VOTE_BUTTON_COOLDOWN );

    -- process results
    Vote:HandleVoteResults( subjectId );

    return nil; -- end thinker
end

function Vote:HandleVoteResults( subjectId )
    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];
    local threshold = Vote:Threshold(voteTable);

    local v = " voters";
    if voteTable.numYes == 1 then
        v = " voter"
    end

    if Vote:KickCondition(voteTable) then
        Kick:KickPlayer( subjectId );
        local message = voteTable.numYes..v.." voted to kick "..Vote:PlayerNameString(subjectId).." ("..threshold.." needed). Vote kick successful.";
        Vote:TeamMessage(subjectTeamId, message);
        -- play axe successs sound on all players
        EmitGlobalSound("Custom_Game.Vote_Kick.Success");
    else
        -- play axe fail sound on all players
        local message = voteTable.numYes..v.." voted to kick "..Vote:PlayerNameString(subjectId).." ("..threshold.." needed). Vote kick failed.";
        Vote:TeamMessage(subjectTeamId, message);
        -- play axe fail sound on all players
        EmitGlobalSound("Custom_Game.Vote_Kick.Fail");
    end
end

function Vote:GetNumVoters( subjectId )
    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    -- count up number of non disconnected players on the same team
    local count = 0;
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        if PlayerResource:IsValidPlayerID(playerId) then
            local playerTeamId = PlayerResource:GetTeam(playerId);
            if (playerTeamId == subjectTeamId) and not DISCONNECTED[playerId] then
                count = count + 1;
            end
        end
    end
    return count;
end


return Vote;