local PostGameStats = class({});

local NET_TABLE_NAME = "post_game_stats";

function PostGameStats:SetNetTable()
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        if PlayerResource:IsValidPlayerID(playerId) then

            local stats = {
                GPM = PlayerResource:GetGoldPerMin(playerId),
                goldEarned = PlayerResource:GetTotalEarnedGold(playerId),
                damageDealt = PlayerResource:GetRawPlayerDamage(playerId),
                damageTaken = PlayerResource:GetHeroDamageTaken(playerId, true) 
            };

            CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerId) , stats );
        end
    end
end

return PostGameStats;