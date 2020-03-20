local Vote = class({});
local Kick = Kick;
if not Kick then
    Kick = require("Kick");
    Kick:Initialize();
end

-- TODO SET TIMEOUTS
local VOTE_TIMEOUT = 15;
local VOTE_BUTTON_COOLDOWN = 30; -- cooldown after voting ends
local VOTE_BUTTON_INITIAL_COOLDOWN = 60; -- cooldown after match start 
local VOTES_TO_KICK = 6;
local VOTE_OPTIONS = {
    YES = "Yes",
    NO = "No",
    NEITHER = "Neither"
};

function Vote:Threshold( voteTable )
    -- return math.min(VOTES_TO_KICK, table.numVotes); --TODO change to voters
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
        -- votes[voterID] = "yes"/"no"/"neither"
        -- iterate through table to process results

local TEAM_VOTE_STATUS = {};
-- Table Contents:
-- teamId (radiant or dire) 
    -- voteInProgress
    -- cooldown
    -- subjectId

local DISCONNECTED = {};
-- Table Contents
-- teamId -> table that maps playerId to true if disconnect or false/nil otherwise

function Vote:TeamName( teamId )
    if teamId == DOTA_TEAM_GOODGUYS then
        return "Radiant";
    elseif teamId == DOTA_TEAM_BADGUYS then
        return "Dire";
    else 
        return "Team "..teamId;
    end
end

function Vote:TeamMessage( teamId, message )
    local teamName = Vote:TeamName(teamId);
    GameRules:SendCustomMessage(teamName.." | "..message, 0, 0);
end


function Vote:Initialize()
    TEAM_VOTE_STATUS[DOTA_TEAM_GOODGUYS] = { voteInProgress = false, cooldown = true, subjectId = nil };
    TEAM_VOTE_STATUS[DOTA_TEAM_BADGUYS] = { voteInProgress = false, cooldown = true, subjectId = nil };

    GameRules:SendCustomMessage("Start a vote kick by clicking the Boots icon on the scoreboard.", 0, 0);

    CustomGameEventManager:RegisterListener( "begin_voting", Dynamic_Wrap( Vote, "BeginVoting" ) );
    CustomGameEventManager:RegisterListener( "vote_submitted", Dynamic_Wrap( Vote, "ReceiveVote" ) );

    GameRules:GetGameModeEntity():SetThink(function () 
        TEAM_VOTE_STATUS[DOTA_TEAM_GOODGUYS].cooldown = false;
        TEAM_VOTE_STATUS[DOTA_TEAM_BADGUYS].cooldown = false;
        Vote:TeamMessage( DOTA_TEAM_GOODGUYS, "Vote kick is now off cooldown.");
        Vote:TeamMessage( DOTA_TEAM_BADGUYS, "Vote kick is now off cooldown.");
    end, self, "Initial Cooldown", VOTE_BUTTON_INITIAL_COOLDOWN );
end

function Vote:BeginVoting( event )

    -- event.playerId, event.subjectId
    local playerId = event.playerId;
    local subjectId = event.subjectId;
    local playerTeamId = PlayerResource:GetTeam(playerId);
    local subjectTeamId = PlayerResource:GetTeam(subjectId);

    local teamTable = TEAM_VOTE_STATUS[playerTeamId];
    if teamTable.voteInProgress then
        local error = {
            message = "A vote is already in progress for your team."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.CastFail_NoMana" } );
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        return nil;
    elseif teamTable.cooldown then
        local error = {
            message = "Vote kick is on cooldown."
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
    
    Vote:TeamMessage(subjectTeamId, "Begin Voting!");

    teamTable.voteInProgress = true;
    teamTable.subjectId = subjectId;

    -- set vote table
    Vote:ResetVoteTable( subjectId );
    -- apply vote from initiating player
    Vote:UpdateVoteTable( playerId, subjectId, VOTE_OPTIONS.YES );

    -- set timeout for vote using thinker
    -- need closure to capture subjectId
    GameRules:GetGameModeEntity():SetThink(function () 
        Vote:EndVoting(subjectId);
    end, self, "EndVotingTimeout", VOTE_TIMEOUT );

    -- send vote button disable timeout to client
    Vote:RequestVotes( playerId, subjectId );
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

    local message = "Votes: "..(voteTable.numVotes).." | Kick: "..(voteTable.numYes).." | Don't Kick: "..(voteTable.numVotes - voteTable.numYes);
    Vote:TeamMessage(teamId, message);

    if Vote:IsComplete( subjectId ) then
        Vote:EndVoting( subjectId );
    end
end

function Vote:OnPlayerReconnect( event )
    DISCONNECTED[event.playerId] = false;
end

function Vote:OnPlayerDisconnect( event )
    -- the point of the following is that disconnecting reduces the number of voters
    -- which can change the outcome of an in-progress vote

    -- update disconnected table
    local playerId = event.playerId;
    DISCONNECTED[playerId] = true;

    local playerTeamId = PlayerResource:GetTeam(playerId);

    local teamTable = TEAM_VOTE_STATUS[playerTeamId];
    if not teamTable.voteInProgress then -- does not matter if vote is not in progress
        return nil;
    end

    local subjectId = teamTable.subjectId;
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];

    -- change number of voters
    voteTable.numVoters = Vote:GetNumVoters( subjectId );

    CustomGameEventManager:Send_ServerToTeam( playerTeamId, "update_votes", voteTable);
    local message = "Votes: "..(voteTable.numVotes).." (Voter Disconnected) | Kick: "..(voteTable.numYes).." | Don't Kick: "..(voteTable.numVotes - voteTable.numYes);
    Vote:TeamMessage(subjectTeamId, message);

    -- check kick condition
    if Vote:IsComplete( event.subjectId ) then
        Vote:EndVoting( event.subjectId );
    end

    return nil;
end

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

    TEAM_VOTE_STATUS[subjectTeamId].voteInProgress = false;
    TEAM_VOTE_STATUS[subjectTeamId].cooldown = true;
    TEAM_VOTE_STATUS[subjectTeamId].subjectId = nil;

    -- release team vote lock after delay
    GameRules:GetGameModeEntity():SetThink(function () 
        TEAM_VOTE_STATUS[subjectTeamId].cooldown = false;
        local message = "Vote kick is now off cooldown.";
        Vote:TeamMessage(subjectTeamId, message);
    end, self, "UnlockVoting", VOTE_BUTTON_COOLDOWN );

    -- process results
    Vote:HandleVoteResults( subjectId );

    return nil; -- end thinker
end

function Vote:HandleVoteResults( subjectId )
    local subjectTeamId = PlayerResource:GetTeam(subjectId);
    local voteTable = SUBJECT_VOTE_TABLE[subjectId];
    local threshold = Vote:Threshold(voteTable);
    if Vote:KickCondition(voteTable) then
        Kick:KickPlayer( subjectId );
        local message = voteTable.numYes.." out of "..voteTable.numVotes.." voted 'Kick' (need "..threshold.."). Vote kick successful.";
        Vote:TeamMessage(subjectTeamId, message);
        -- play axe successs sound on all players
        EmitGlobalSound("Vote_Kick.Success");
    else
        -- play axe fail sound on all players
        local message = voteTable.numYes.." out of "..voteTable.numVotes.." voted 'Kick' (need "..threshold.."). Vote kick failed.";
        Vote:TeamMessage(subjectTeamId, message);
        -- play axe fail sound on all players
        EmitGlobalSound("Vote_Kick.Fail");
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