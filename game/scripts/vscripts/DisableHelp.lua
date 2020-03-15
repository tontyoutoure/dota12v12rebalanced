local DisableHelp = class({});

local NET_TABLE_NAME = "disable_help";

function DisableHelp:UpdateNetTable( playerId, targetPlayerId, disable )
    local table = CustomNetTables:GetTableValue( NET_TABLE_NAME, tostring(playerId) ) or {};
    table[tostring(targetPlayerId)] = disable;
    CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerId), table );
end

function DisableHelp:DisableHelpListener( args )
    local targetPlayerId = args.targetPlayerId;

	if PlayerResource:IsValidPlayerID(targetPlayerId) then
		local playerId = args.playerId;
        local disable = (args.disable == 1);
        print("HELLLLLLLLOOOOOOO");
        print(disable);
		PlayerResource:SetUnitShareMaskForPlayer(playerId, targetPlayerId, 4, disable);

        DisableHelp:UpdateNetTable( playerId, targetPlayerId, disable );
	end
end

function DisableHelp:Initialize()
    CustomGameEventManager:RegisterListener( "set_disable_help", Dynamic_Wrap( DisableHelp, "DisableHelpListener" ) );
end

return DisableHelp;