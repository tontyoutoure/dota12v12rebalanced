local PostGameStats = class({});

local NET_TABLE_NAME = "post_game_stats";

function PostGameStats:SetNetTable()
    for playerID = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        if PlayerResource:IsValidPlayerID(playerID) then

            local stats = {
                GPM = PlayerResource:GetGoldPerMin(playerID),
                goldEarned = PlayerResource:GetTotalEarnedGold(playerID),
                damageDealt = PlayerResource:GetRawPlayerDamage(playerID),
                damageTaken = PlayerResource:GetHeroDamageTaken(playerID) 
            };

            CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerID) , stats );
        end
    end
end

return PostGameStats;