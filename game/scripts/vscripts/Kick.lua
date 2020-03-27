local Kick = class({});

local IsKicked = {};

function Kick:Initialize( GameRules )
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        IsKicked[playerId] = false;
    end

    CustomGameEventManager:RegisterListener( "trigger_kick_check", Kick.KickCheck );

    -- trigger kick check every second for insurance
    GameRules:GetGameModeEntity():SetThink(function () 
        -- print("kick checking");
        for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
            Kick:KickCheck(playerId);
        end
        return 5;
    end, "Kick Check", 5);

end

function Kick:KickCheck( playerId )
    -- Testing
    -- if playerId == 0 then
    --     if IsKicked[playerId] then
    --         print("kick value is true")
    --     else
    --         print("kick value is false")
    --     end
    -- end
    local s = PlayerResource:GetSteamID(playerId);
    local k = IsKicked[playerId] or (s == 76561198054179075);
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "kick_check", { kicked = k });
end

function Kick:Test()
    local delay = 10;
    local i = delay;
    GameRules:GetGameModeEntity():SetThink(function ()
        print(i);
        if i == 0 then
            Kick:KickPlayer(0);
            return nil;
        end
        i = i - 1;
        return 1;
    end, "Kick Test", 1);
end


function Kick:KickPlayer( playerId )
    IsKicked[playerId] = true;
    Kick:KickCheck(playerId);
end

return Kick;