local Kick = class({});

-- store kicked players on a nettable
local NET_TABLE_NAME = "kicked_players";

function Kick:Initialize()
    CustomGameEventManager:RegisterListener( "trigger_kick_check", Kick.KickCheck );
end

function Kick:KickCheck( args )
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args.playerId), "kick_check", {})
end

function Kick:KickPlayer( playerId )
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerId), { isKicked = true } );
    self:KickCheck({ playerId = playerId });
end

return Kick;