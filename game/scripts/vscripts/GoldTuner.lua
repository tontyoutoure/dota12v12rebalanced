local GoldTuner = class({});

local GOLD_TICK_TIME = 1; -- seconds
local GOLD_PER_TICK = 2;

local INITIAL_TIME = 0;
local HOUR_TIME = 60 * 60;
local SCALE_INITIAL_VALUE = 1; -- value at initial time 
local SCALE_HOUR_VALUE = 5; -- value at final time 
local SCALE_TIME_COEFFICIENT = (SCALE_HOUR_VALUE - SCALE_INITIAL_VALUE) / (HOUR_TIME - INITIAL_TIME);

local scaleFactor = SCALE_INITIAL_VALUE;

-- call in game time thinker
function GoldTuner:UpdateFactor( time )
    scaleFactor = SCALE_INITIAL_VALUE + SCALE_TIME_COEFFICIENT * time;
end

function GoldTuner:GoldFilter( filterTable )
    filterTable["gold"] = scaleFactor * filterTable["gold"];
    return true;
end

function GoldTuner:IncrementPlayerGold()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        local allHeroes = HeroList:GetAllHeroes();
        for _, hero in pairs(allHeroes) do
            if hero:IsRealHero() then
                hero:ModifyGold(GOLD_PER_TICK, false, 0);
            end
        end
    end
    return GOLD_TICK_TIME;
end

function GoldTuner:SetGoldThinker( GameRules )
    GameRules:GetGameModeEntity():SetThink( "IncrementPlayerGold", GoldTuner, "GoldThinker", GOLD_PER_TICK );
end


return GoldTuner;