local Vote = class({});

local VOTE_TIMEOUT = 30;
local VOTE_BUTTON_DISABLE_TIMEOUT = 60;
local VOTES_TO_KICK = 4;
local VOTE_OPTIONS = {
    YES = "Yes",
    NO = "No",
    NEITHER = "Neither"
}

local NET_TABLE_NAME = "vote_events";

-- Table Contents:
-- teamId (radiant or dire) 
    -- nil or subjectId of currently running vote
-- subjectId
    -- player ID of player to kick
    -- value
        -- table containing:
            -- "numVoters" number of people that can vote
                -- current number of players minus subject (GetTeamPlayerCount)
            -- "numVotes"
            -- "numYes" number of yes's
            -- "votes" each player's votes
                -- votes[voterID] = "yes"/"no"/"neither"
                -- iterate through table to process results


function Vote:Initialize()
    CustomGameEventManager:RegisterListener( "begin_voting", Dynamic_Wrap( self, "BeginVoting" ) );
    CustomGameEventManager:RegisterListener( "vote", Dynamic_Wrap( self, "ReceiveVote" ) );
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(DOTA_TEAM_GOODGUYS), { voteInProgress = nil } );
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(DOTA_TEAM_BADGUYS), { voteInProgress = nil } );
end

function Vote:BeginVoting( event )
    -- event.playerId, event.subjectId
    -- check same team
    local playerTeamId = PlayerResource:GetTeam(event.playerId))
    local subjectTeamId = PlayerResource:GetTeam(event.subjectId))
    if playerTeamId ~= subjectTeamId then
        local event = {
            message = "Cannot kick players on different teams."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.playerId), "display_error_from_server", event );
        return nil;
    end
    
    -- check team vote lock
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(playerTeamId) ); 
    if table.voteInProgress then
        local event = {
            message = "A vote is already in progress for your team."
        };
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(event.playerId), "display_error_from_server", event );
        return nil;
    end

    -- set lock
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerTeamId), { voteInProgress = event.subjectId } );

    -- set net table
    self:ResetNetTable( event.playerId, event.subjectId )

    -- set timeout for vote using thinker
    -- need closure to capture subjectId
    GameRules:GetGameModeEntity():SetThink(
        function () 
            self.EndVoting(event.subjectId);
        end,
    self, "EndVotingTimeout", VOTE_TIMEOUT );

    -- send vote button disable timeout to clientG
    self:RequestVotes( event.playerId, event.subjectId );
end

function Vote:RequestVotes( playerId, subjectId )
    -- send vote request to everyone on same team except the above two players
    -- or let client handle displaying correct dialog
    local playerTeam = PlayerResource:GetTeam(playerId);
    local subjectTeam = PlayerResource:GetTeam(subjectId);
    local event = {
        playerId = playerId,
        subjectId = subjectId,
        timeout = VOTE_BUTTON_DISABLE_TIMEOUT,
        voteOptions = VOTE_OPTIONS
    };
    CustomGameEventManager:Send_ServerToTeam( playerTeam, "request_votes", event );
end

function Vote:ReceiveVote( event )
    -- handle vote sent by player
    self:UpdateNetTable( event.voterId, event.subjectId, event.vote );
    -- TODO update player dialog boxes

    if self:isComplete( event.subjectId ) then
        self:EndVoting( event.subjectId );
    end
end

function Vote:isComplete( subjectId )
    -- check net table to see if finished
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) ); 
    local kickCondition = table.numYes >= VOTES_TO_KICK;
    local allVoted = table.numVotes == table.numVoters;
    return kickCondition or allVoted;
end

    -- table containing:
        -- "numVoters" number of people that can vote
            -- current number of players minus subject (GetTeamPlayerCount)
        -- "numVotes"
        -- "numYes" number of yes's
        -- "votes" each player's votes
            -- votes[voterID] = "yes"/"no"/"neither"
            -- iterate through table to process results

function Vote:ResetNetTable( subjectId )
    local table = {
        numVoters = self.GetNumVoters(subjectId), 
        numVotes = 0,
        numYes = 0,
        votes = {}
    };
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );
end

function Vote:GetNumVoters( subjectId )
    -- TODO
    -- get all players that
    -- have not abandoned
    -- and are on the same team
    -- and are not the subject
    return 12;
end

function Vote:UpdateNetTable( voterId, subjectId, vote )
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) );
    table.numVotes = table.numVotes + 1;
    if vote == VOTE_OPTIONS.YES then 
        table.numYes = table.numYes + 1;
    end
    table.votes[tostring(voterId)] = vote;
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );
end

-- TODO what args needed
function Vote:EndVoting( subjectId )
    -- simply has to close dialog for players via event emission
    -- TODO emit event to client
    CustomGameEventManager:Send_ServerToTeam( playerTeam, "end_voting", event );

    -- release team vote lock
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), { voteInProgress = nil } );

    -- process results (i.e. kick player)

    return nil; -- end thinker
end

return Vote;