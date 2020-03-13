local GoldTuner = class({});

local INITIAL_TIME = 0;
local HOUR_TIME = 60 * 60;
local SCALE_INITIAL_VALUE = 1; -- value at initial time 
local SCALE_HOUR_VALUE = 5; -- value at final time 
local SCALE_TIME_COEFFICIENT = (SCALE_HOUR_VALUE - SCALE_INITIAL_VALUE) / (HOUR_TIME - INITIAL_TIME);

local scaleFactor = SCALE_INITIAL_VALUE;

function GoldTuner:UpdateFactor( time )
    scaleFactor = SCALE_INITIAL_VALUE + SCALE_TIME_COEFFICIENT * time;
end

function GoldTuner:GoldFilter( filterTable )
    filterTable["gold"] = scaleFactor * filterTable["gold"];
    return true;
end

return GoldTuner;