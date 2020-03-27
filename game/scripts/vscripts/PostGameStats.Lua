local PostGameStats = class({});

local NET_TABLE_NAME = "post_game_stats";

local damageMatrix = {};

function PostGameStats:SetNetTable()
    PostGameStats:InitializeDamageMatrix();
    PostGameStats:FillDamageMatrix();

    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        if PlayerResource:IsValidPlayerID(playerId) then

            -- local stats = {
            --     GPM = PlayerResource:GetGoldPerMin(playerId),
            --     goldEarned = PlayerResource:GetTotalEarnedGold(playerId),
            --     damageDealt = PlayerResource:GetRawPlayerDamage(playerId),
            --     damageTaken = PlayerResource:GetHeroDamageTaken(playerId, true) 
            -- };

            local stats = {
                GPM = PlayerResource:GetGoldPerMin(playerId),
                goldEarned = PlayerResource:GetTotalEarnedGold(playerId),
                damageDealt = damageMatrix[playerId].damageDealt,
                damageTaken = damageMatrix[playerId].damageTaken
            };

            CustomNetTables:SetTableValue( NET_TABLE_NAME, tostring(playerId) , stats );
        end
    end
end

function PostGameStats:InitializeDamageMatrix()
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        damageMatrix[playerId] = {
            damageDealt = 0;
            damageTaken = 0;
        };
    end
end

function PostGameStats:FillDamageMatrix()
    for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
        for victimId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
            if playerId ~= victimId then
                local damage = PlayerResource:GetDamageDoneToHero(playerId, victimId);
                damageMatrix[playerId].damageDealt = damageMatrix[playerId].damageDealt + damage;
                damageMatrix[victimId].damageTaken = damageMatrix[victimId].damageTaken + damage;
            end
        end
    end
end

return PostGameStats;