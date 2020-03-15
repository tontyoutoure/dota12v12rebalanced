local Vote = class({});

-- ideally there should only be one vote occurring at any given moment
-- unsure if a lock can be implemented
-- we will instead name each vote event occurring

local NET_TABLE_NAME = "vote_events";
local VOTE_TIMEOUT = 30;
local VOTE_BUTTON_DISABLE_TIMEOUT = 60;

-- key
    -- vote event name
        -- player subject to vote 
-- value
    -- table containing:
        -- current number of players minus subject (GetTeamPlayerCount)
            -- int
        -- each player's votes
            -- votes[voterID] = "yes"/"no"/"neither"
            -- iterate through table to process results

-- vote is not short circuited, ends after a timeout
-- disable button for a time longer than a vote duration

function Vote:Initialize()
    CustomGameEventManager:RegisterListener( "begin_vote", Dynamic_Wrap( self, "BeginVote" ) );
    CustomGameEventManager:RegisterListener( "vote", Dynamic_Wrap( self, "ReceiveVote" ) );
end

function Vote:BeginVote( event )
    -- send vote button disable timeout to client
    self:RequestVotes( event.playerId, event.subjectId );
    -- set net table
    self:UpdateNetTable( event.playerId, event.subjectId, "yes" )
    -- set timeout for vote using thinker
    GameRules:GetGameModeEntity():SetThink( "EndVote", self, "EndVote", VOTE_TIMEOUT );
end

function Vote:RequestVotes( playerId, subjectId )
    -- send vote request to everyone on same team except the above two players
    -- or let client handle
    -- VOTE_BUTTON_DISABLE_TIMEOUT
    CustomGameEventManager:Send_ServerToTeam( team_number, "my_event_name", event_data )
end

function Vote:ReceiveVote( event )
    -- handle vote sent by player
    self:UpdateNetTable( event.voterId, event.subjectId, event.vote );
    if self:isComplete( event.subjectId )
        -- if last, end vote for this subject
        self:EndVote( event.subjectId );
    end
end

function Vote:isComplete( subjectId )
    -- check net table to see if finished
end

function Vote:UpdateNetTable( voterId, subjectId, vote )
    -- vote is "yes", "no", "neither"
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(subjectId) ) or {};
    table[tostring(voterId)] = vote;
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(subjectId), table );
end

function Vote:EndVote( subjectId )
    -- end vote dialog after timeout
    -- non-votes default to 'NO'
    -- emit endvote
    return nil; -- end thinker
end

return Vote;