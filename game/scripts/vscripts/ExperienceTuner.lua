local ExperienceTuner = class({});

local INITIAL_TIME = 0;
local HOUR_TIME = 60 * 60;
local SCALE_INITIAL_VALUE = 2; -- value at initial time 
local SCALE_HOUR_VALUE = 3; -- value at final time 
local SCALE_TIME_COEFFICIENT = (SCALE_HOUR_VALUE - SCALE_INITIAL_VALUE) / (HOUR_TIME - INITIAL_TIME);

local SCALE_FACTOR_THINK_TIME = 1;

local scaleFactor = SCALE_INITIAL_VALUE;


function ExperienceTuner:ExperienceFilter( filterTable )
    filterTable["experience"] = scaleFactor * filterTable["experience"];
    return true;
end

function ExperienceTuner:UpdateScaleFactor( time )
    scaleFactor = SCALE_INITIAL_VALUE + SCALE_TIME_COEFFICIENT * time;
end

function ExperienceTuner:ScaleFactorThinker()
	local gameState = GameRules:State_Get();
	local time = GameRules:GetDOTATime(false, true); -- use time to respect pauses
	if gameState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		ExperienceTuner:UpdateScaleFactor( time );
	elseif gameState >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return SCALE_FACTOR_THINK_TIME;
end

function ExperienceTuner:Initialize( GameRules )
	GameRules:GetGameModeEntity():SetModifyExperienceFilter( Dynamic_Wrap( ExperienceTuner, "ExperienceFilter" ), ExperienceTuner);
	GameRules:GetGameModeEntity():SetThink( "ScaleFactorThinker", ExperienceTuner, "ExperienceScaleThinker", SCALE_FACTOR_THINK_TIME );
end

return ExperienceTuner;