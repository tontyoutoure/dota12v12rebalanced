-- UNUSED --
local Courier = class({});

-- cache[playerId] = courier
local cache = {};

function Courier:GetCourier( playerId )
    if cache[playerId] then
        return cache[playerId];
    end

	local couriers = Entities:FindAllByClassname("npc_dota_courier");
    for _, courier in pairs(couriers) do
        if courier:GetOwner() and courier:GetOwner():GetPlayerID() == playerId then
            cache[playerId] = courier;
			return courier;
		end
    end

	return nil;
end

return Courier;