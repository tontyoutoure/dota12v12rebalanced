local Fountain = class({});

local fountain_abilities = {
	faceless_void_time_lock = 4,
	luna_moon_glaive = 4
}

local fountain_items = {
	-- item_ultimate_scepter = 1,
	item_mjollnir = 2,
	item_monkey_king_bar = 1
}

function Fountain:Buff()
	local fountains = Entities:FindAllByClassname('ent_dota_fountain');
	for i, fountain in pairs(fountains) do
		for name, level in pairs(fountain_abilities) do
			local ability = fountain:FindAbilityByName(name);
			if not ability then
				ability = fountain:AddAbility(name);
				if ability then
					ability:SetLevel(level);
				end
			end
		end
		for name, N in pairs(fountain_items) do
			for i = 1, N do
				local item = CreateItem(name, fountain, fountain);
				if item then
					fountain:AddItem(item);
				end
			end
		end
	end
end

return Fountain;