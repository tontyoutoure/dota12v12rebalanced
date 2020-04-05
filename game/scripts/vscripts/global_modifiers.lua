--require('bot_item_data')
local tBotItemData = {}
tBotItemData.tItemParts = {
	item_solar_crest = {'item_medallion_of_courage'},
	item_mjollnir = {'item_maelstrom'},
	item_guardian_greaves = {'item_mekansm', 'item_arcane_boots'},
	item_hurricane_pike = {'item_dragon_lance', 'item_force_staff'},
	item_ultimate_scepter_2 = {'item_ultimate_scepter'},
	item_abyssal_blade = {'item_basher','item_vanguard'},
}

tBotItemData.tLuxuryItemList = {
	npc_dota_hero_axe = {'item_shivas_guard', 'item_ultimate_scepter_2'},
	npc_dota_hero_bane = {'item_necronomicon_3', 'item_octarine_core', 'item_shivas_guard', 'item_sphere', 'item_ultimate_scepter_2'},
	npc_dota_hero_bloodseeker = {'item_vanguard', 'item_abyssal_blade', 'item_radiance','item_butterfly', 'item_ultimate_scepter_2'},
	npc_dota_hero_bounty_hunter = {'item_black_king_bar', 'item_assault', 'item_ultimate_scepter_2'},
	npc_dota_hero_crystal_maiden = {'item_black_king_bar', 'item_shivas_guard', 'item_sheepstick', 'item_octarine_core', 'item_monkey_king_bar', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_drow_ranger = {"item_satanic", "item_mjollnir", "item_greater_crit", "item_ultimate_scepter_2"},
	npc_dota_hero_dazzle = {'item_orchid', 'item_guardian_greaves', 'item_octarine_core', 'item_shivas_guard', 'item_ultimate_scepter_2'},
	npc_dota_hero_earthshaker = {'item_sheepstick', 'item_greater_crit', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_juggernaut = {'item_satanic', 'item_monkey_king_bar', 'item_ultimate_scepter_2'},
	npc_dota_hero_pudge = {'item_ultimate_scepter', 'item_octarine_core', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_nevermore = {'item_butterfly', 'item_ultimate_scepter_2'},
	npc_dota_hero_death_prophet = {'item_octarine_core', 'item_shivas_guard', 'item_sheepstick', 'item_ultimate_scepter_2'},
	npc_dota_hero_sniper = {'item_maelstrom','item_hurricane_pike', 'item_manta', 'item_black_king_bar', 'item_mjollnir', 'item_greater_crit', 'item_ultimate_scepter_2'}, --ulti ok?
	npc_dota_hero_jakiro = {'item_ultimate_scepter', 'item_guardian_greaves', 'item_shivas_guard', 'item_octarine_core', 'item_refresher', 'item_sphere', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_kunkka = {'item_assault', 'item_bfury', 'item_monkey_king_bar', 'item_ultimate_scepter_2'},
	npc_dota_hero_lina = {'item_ultimate_scepter', "item_cyclone", "item_octarine_core", "item_hurricane_pike", 'item_monkey_king_bar', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_lion = {"item_dagon_5", 'item_octarine_core', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_luna = {"item_assault", "item_satanic", "item_ultimate_scepter_2"},
	npc_dota_hero_omniknight = {"item_heart", "item_guardian_greaves", "item_ultimate_scepter_2"},
	npc_dota_hero_oracle = {"item_orchid","item_guardian_greaves", 'item_octarine_core', "item_aeon_disk", "item_ultimate_scepter_2"},
	npc_dota_hero_sand_king = {"item_shivas_guard", "item_sphere", "item_ultimate_scepter_2"},
	npc_dota_hero_sven = {"item_satanic", "item_greater_crit", 'item_ultimate_scepter_2'},
	npc_dota_hero_tiny = {"item_heart", "item_assault", 'item_ultimate_scepter_2'},
	npc_dota_hero_warlock = {'item_octarine_core','item_sphere', 'item_shivas_guard','item_recipe_ultimate_scepter_2'},
	npc_dota_hero_vengefulspirit = {"item_aether_lens", "item_hurricane_pike", "item_butterfly", "item_assault", 'item_ultimate_scepter_2'},
	npc_dota_hero_viper = {"item_monkey_king_bar", 'item_butterfly', "item_guardian_greaves", 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_witch_doctor = {"item_black_king_bar", "item_guardian_greaves"},
	npc_dota_hero_zuus = {'item_bloodstone', 'item_aether_lens', 'item_refresher', 'item_sheepstick', 'item_ultimate_scepter_2'},
	npc_dota_hero_windrunner = {"item_mjollnir", "item_hurricane_pike", 'item_greater_crit', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_lich = {'item_ultimate_scepter','item_octarine_core','item_recipe_ultimate_scepter_2'},
	npc_dota_hero_necrolyte = {'item_octarine_core', 'item_sphere', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_skeleton_king = {'item_assault', 'item_ultimate_scepter_2'},
	npc_dota_hero_phantom_assassin = {'item_vanguard', 'item_abyssal_blade', 'item_satanic', 'item_assault' , 'item_monkey_king_bar','item_ultimate_scepter_2'},
	npc_dota_hero_dragon_knight = {'item_assault', 'item_ultimate_scepter_2'},
	npc_dota_hero_chaos_knight = {'item_assault', 'item_ultimate_scepter_2'},
	npc_dota_hero_skywrath_mage = {'item_sheepstick', 'item_octarine_core', 'item_recipe_ultimate_scepter_2'},
	npc_dota_hero_bristleback = {'item_vanguard', 'item_blade_mail', 'item_heart', 'item_assault', 'item_shivas_guard', 'item_radiance', 'item_ultimate_scepter_2'}, -- ability ok?
}



tBotItemData.tWrongItems = {
	{tRightItems = {'item_butterfly', 'item_satanic'}, components = {item_mask_of_madness = 1,item_eagle = 1, item_reaver =1, item_talisman_of_evasion = 1, item_claymore= 1}, deficit = 0},
	{tRightItems = {'item_black_king_bar'}, components = {item_javelin = 1, item_ogre_axe = 1, item_recipe_black_king_bar = 1}, deficit = 500},
}

tBotItemData.tLowCostItems = {
	item_flask = true;
	item_branches = true;
	item_bottle = true;
	item_clarity = true;
	item_tango = true;
	item_magic_stick = true;
	item_magic_wand = true;
	item_recipe_magic_wand = true;
	item_mantle = true;
	item_wraith_band = true;
	item_null_talisman = true;
	item_bracer = true;
--	item_ring_of_basilius = true;
--	item_stout_shield = true;
--	item_quelling_blade = true;
}

local tClassFTF = {
	IsPurgable = function(self) return false end,
	IsHidden = function(self) return true end,
	RemoveOnDeath = function(self) return false end,
}

modifier_bots_behavior = class(tClassFTF)

function modifier_bots_behavior:OnCreated()
	if IsClient() then return end
	self:StartIntervalThink(0.1)
end

function modifier_bots_behavior:OnIntervalThink()
	if IsClient() then return end
	local hParent = self:GetParent()
	local tTowers = FindUnitsInRadius(hParent:GetTeam(), hParent:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

-- has enough health and has tower/watch tower nearby and no enemy nearby
	if hParent:GetHealth()/hParent:GetMaxHealth() > 0.3 and tTowers[1] and not FindUnitsInRadius(hParent:GetTeam(), hParent:GetAbsOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)[1] then
		if self.hTarget == tTowers[1] or hParent:IsCommandRestricted() then return end
		self.hTarget = tTowers[1]
		if string.find(self.hTarget:GetName(), 'watch_tower') then
			local tOrder = 
				{
					UnitIndex = hParent:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					AbilityIndex = hParent:FindAbilityByName('ability_capture'):entindex(),
					TargetIndex = self.hTarget:entindex()
				}
			ExecuteOrderFromTable(tOrder)
			self.bSentCommand = true
		elseif FindUnitsInRadius(tTowers[1]:GetTeam(), tTowers[1]:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)[1]  then
			local tOrder = 
				{
					UnitIndex = hParent:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = self.hTarget:entindex()
				}
			hParent:SetForceAttackTarget(nil)
			ExecuteOrderFromTable(tOrder)
			self.bSentCommand = true
			hParent:SetForceAttackTarget(self.hTarget)
		end
	elseif Entities:FindAllByClassnameWithin("dota_item_rune", hParent:GetOrigin(), 500)[1] then
		local hRune = Entities:FindAllByClassnameWithin("dota_item_rune", hParent:GetOrigin(), 500)[1]
		local tOrder = 
		{
			UnitIndex = hParent:entindex(),
			OrderType = DOTA_UNIT_ORDER_PICKUP_RUNE,
			TargetIndex = hRune:entindex()
		}
		ExecuteOrderFromTable(tOrder)		
	elseif self.bSentCommand then	
		hParent:SetForceAttackTarget(nil)
		self.bSentCommand = false
		self.hTarget = nil
	end
end
function modifier_bots_behavior:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = self.bSentCommand}
end


modifier_axe_thinker = class(tClassFTF)
function modifier_axe_thinker:OnCreated()
	if IsClient() then return end
	self:StartIntervalThink(0.04)
end

function modifier_axe_thinker:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end

local function ThinkForAxeAbilities(hAxe)
	local hAbility1 = hAxe:GetAbilityByIndex(0)
	local hAbility2 = hAxe:GetAbilityByIndex(1)
	local hAbility6 = hAxe:GetAbilityByIndex(5)
	if hAxe:IsSilenced() or hAxe:IsStunned() or hAbility1:IsInAbilityPhase() or hAbility2:IsInAbilityPhase() or hAbility6:IsInAbilityPhase() then return end
	local iRange2 = hAbility2:GetCastRange()
	local iThreshold = hAbility6:GetSpecialValueFor("kill_threshold")
	if hAbility6:IsFullyCastable() then
		local tAllHeroes = FindUnitsInRadius(hAxe:GetTeam(), hAxe:GetOrigin(), nil, hAbility6:GetCastRange()+150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		
		for i, v in ipairs(tAllHeroes) do
			if v:GetHealth() < iThreshold then
				hAxe:CastAbilityOnTarget(v, hAbility6, hAxe:GetPlayerOwnerID())
				hAxe.IsCasting = true
				return
			end
		end
	end
	if hAbility1:IsFullyCastable() then

		local tAllHeroes = FindUnitsInRadius(hAxe:GetTeam(), hAxe:GetOrigin(), nil, hAbility1:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		local iCount = #tAllHeroes
		for i = 1, iCount do
			if tAllHeroes[iCount+1-i]:IsStunned() or tAllHeroes[iCount+1-i]:IsHexed() then table.remove(tAllHeroes, iCount+1-i) end
		end
		
		if #tAllHeroes > 0 then
			hAxe:CastAbilityNoTarget(hAbility1, hAxe:GetPlayerOwnerID())
			return
		end
	end
	if hAbility2:IsFullyCastable() then
		local tAllHeroes = FindUnitsInRadius(hAxe:GetTeam(), hAxe:GetOrigin(), nil, hAbility2:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i, v in ipairs(tAllHeroes) do
			hAxe:CastAbilityOnTarget(v, hAbility2, hAxe:GetPlayerOwnerID())
			return
		end
	end
end

function modifier_axe_thinker:OnIntervalThink()
	if IsClient() then return end
	ThinkForAxeAbilities(self:GetParent())
end


modifier_item_assemble_fix = class(tClassFTF)
function modifier_item_assemble_fix:OnCreated() 
	if IsClient() then return end
	self:StartIntervalThink(0.5)
end
local function FindItemByNameIncludeStash(hHero, sName)
	for i = 0, 15 do
		if hHero:GetItemInSlot(i) and hHero:GetItemInSlot(i):GetName() == sName then return hHero:GetItemInSlot(i) end
	end
	return nil
end

local function GetItemCount(hHero, sName)
	local iCount = 0
	local hItem
	for i = 0,14 do
		if hHero:GetItemInSlot(i) and hHero:GetItemInSlot(i):GetName() == sName then
			iCount = iCount+1
			hItem = hHero:GetItemInSlot(i)
		end
	end
	return iCount, hItem
end


local function CheckItemAfter(hHero, sItemBefore, sItemAfter)
	if FindItemByNameIncludeStash(hHero, sItemBefore) and (not hHero.tItemHistory or not hHero.tItemHistory[sItemAfter] ) then
		if tBotItemData.tItemParts[sItemAfter] then
		
			local iComponentsCost = 0
			for i, v in pairs(tBotItemData.tItemParts[sItemAfter]) do
				iComponentsCost = iComponentsCost + GetItemCost(v)
			end
			if hHero:GetGold() > GetItemCost(sItemAfter)-iComponentsCost  then
				for i, v in pairs(tBotItemData.tItemParts[sItemAfter]) do
					local _, hItem = GetItemCount(hHero, v)
					hHero:RemoveItem(hItem)
				end			
				hHero:SpendGold(GetItemCost(sItemAfter)-iComponentsCost, DOTA_ModifyGold_PurchaseItem)
				hHero:AddItemByName(sItemAfter)
				hHero.tItemHistory = hHero.tItemHistory or {}
				hHero.tItemHistory[sItemAfter] = true
			end
			
			
		else		
			if hHero:GetGold() > GetItemCost(sItemAfter)then
				hHero:SpendGold(GetItemCost(sItemAfter), DOTA_ModifyGold_PurchaseItem)
				hHero:AddItemByName(sItemAfter)
				hHero.tItemHistory = hHero.tItemHistory or {}
				hHero.tItemHistory[sItemAfter] = true
			end
		end
	end
end






local function SellLowCostItems(hHero)
	if (hHero:HasModifier('modifier_fountain_aura_buff') or GameMode.iUniversalShop == 1) then
		iTotalCost = 0
		for i = 0,14 do
			if hHero:GetItemInSlot(i) then
				iTotalCost = iTotalCost+hHero:GetItemInSlot(i):GetCost()
			end
		end
		if iTotalCost > 20000 then
			for i = 0,14 do
				if hHero:GetItemInSlot(i) and tBotItemData.tLowCostItems[hHero:GetItemInSlot(i):GetName()] then
					hHero:SellItem(hHero:GetItemInSlot(i))
				end
			end		
		end
	end
end



function modifier_item_assemble_fix:OnIntervalThink()
	if IsClient() then return end
	local hParent = self:GetParent()
	if not IsInToolsMode() and not hParent:HasModifier('modifier_fountain_aura_buff') then return end
	iEntIndex = hParent:entindex()

	if self:GetStackCount() > 0 and hParent:GetGold() > 0 then
		if hParent:GetGold() > self:GetStackCount() then
			hParent:SpendGold(self:GetStackCount(), DOTA_ModifyGold_PurchaseItem)
			self:SetStackCount(0)
		else
			self:SetStackCount(self:GetStackCount() - hParent:GetGold())
			hParent:SpendGold(hParent:GetGold(), DOTA_ModifyGold_PurchaseItem)
		end
	end
	
	for k,v in ipairs(tBotItemData.tWrongItems) do
		local bHasAllComponents = true
		for k1, v1 in pairs(v.components) do
			if GetItemCount(hParent, k1) < v1 then
				bHasAllComponents = false
			end
		end
		if bHasAllComponents and hParent:GetName() ~= v.disable_hero then
			for k1, v1 in pairs(v.components) do
				for j = 1,v1 do
					local _, hItem = GetItemCount(hParent, k1)
					hParent:RemoveItem(hItem)
				end
			end
			for i2, v2 in pairs(v.tRightItems) do
				hParent:AddItemByName(v2)
			end
			if v.deficit > 0 then
				self:SetStackCount(v.deficit)
			else
				hParent:ModifyGold(-v.deficit, false, DOTA_ModifyGold_SellItem)
			end
		end
	end
	
	if not hParent.bHasEndItem then
		local tHeroLuxuryItemList = tBotItemData.tLuxuryItemList[hParent:GetName()]

		for i = 1, (#tHeroLuxuryItemList-1) do
			CheckItemAfter(hParent, tHeroLuxuryItemList[i], tHeroLuxuryItemList[i+1])
		end
		if hParent:HasModifier('modifier_item_ultimate_scepter_consumed') then
			hParent.bHasEndItem = true
		end
	end
--	SellLowCostItems(hParent)

end

modifier_bot_use_items = class(tClassFTF)
function modifier_bot_use_items:OnCreated()
	self:StartIntervalThink(0.04)
end
function modifier_bot_use_items:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end
function modifier_bot_use_items:OnOrder(keys)
	if keys.unit~= self:GetParent() then return end
	--[[
	if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION  then
		for i, v in pairs(keys.unit.tPapyrusScarabMinions) do
			ExecuteOrderFromTable({
				OrderType = keys.order_type,
				UnitIndex  = v:entindex(),
				Position = keys.new_pos,
			})
		end
	end
	--]]
	if  keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET and keys.unit.tPapyrusScarabMinions then
		for i, v in pairs(keys.unit.tPapyrusScarabMinions) do
			ExecuteOrderFromTable({
				OrderType = keys.order_type,
				UnitIndex  = v:entindex(),
				TargetIndex = keys.target:entindex(),
			})
		end
	end
end

local function FindItemByNameNotIncludeBackpack(hHero, sName)
	for i = 0, 5 do
		if hHero:GetItemInSlot(i) and hHero:GetItemInSlot(i):GetName() == sName then return hHero:GetItemInSlot(i) end
	end
	return nil
end

function modifier_bot_use_items:OnIntervalThink()
	if IsClient() then return end
	
	local hParent = self:GetParent()
	if hParent:IsIllusion() then self:Destroy() end
	if hParent:IsStunned() or hParent:IsMuted() or hParent:IsCommandRestricted() then return end
	
	-- Normal Items

	local hItem = FindItemByNameNotIncludeBackpack(hParent, "item_guardian_greaves")
	if hItem and hItem:IsFullyCastable() then
		local bAllyHurt = false
		local tAllyHeroes = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetOrigin(), nil, hItem:GetSpecialValueFor("transform_range"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,  DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
		for i, v in pairs(tAllyHeroes) do
			if v:GetHealth()/v:GetMaxHealth() < 0.5 then bAllyHurt = true end
		end
		if bAllyHurt then
			hParent:CastAbilityNoTarget(hItem, hParent:GetPlayerOwnerID())
		end
	end
	
	hItem = FindItemByNameNotIncludeBackpack(hParent, "item_bloodthorn")
	if hItem and hItem:IsFullyCastable() and not hParent:IsInvisible() then
		local tTargets = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetOrigin(), nil, hItem:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for i, v in ipairs(tTargets) do
			if not v:IsSilenced() then
				hParent:CastAbilityOnTarget(v, hItem, hParent:GetPlayerOwnerID())
				break
			end
		end
	end
	
	hItem = FindItemByNameNotIncludeBackpack(hParent, "item_refresher")
	if hItem and hItem:IsFullyCastable() then
		local fFullCooldown = 0
		local iMaxCooldownAbility
		for i = 0, 23 do
			if hParent:GetAbilityByIndex(i) then
				local fCooldown = hParent:GetAbilityByIndex(i):GetCooldown(hParent:GetAbilityByIndex(i):GetLevel())
				if fFullCooldown < fCooldown then
					fFullCooldown = fCooldown
					iMaxCooldownAbility = i
				end
			end
		end
		if hParent:GetAbilityByIndex(iMaxCooldownAbility):GetCooldownTimeRemaining() > 0 then
			hParent:CastAbilityNoTarget(hItem, hParent:GetPlayerOwnerID())
		end
	end
	
	hItem = FindItemByNameNotIncludeBackpack(hParent, "item_solar_crest")
	if hItem and not hItem:IsInBackpack() and hItem:IsFullyCastable() and not hParent:IsInvisible() then
		local tTargets = FindUnitsInRadius(hParent:GetTeamNumber(), hParent:GetOrigin(), nil, hItem:GetCastRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for i, v in ipairs(tTargets) do
			if not v:HasModifier('modifier_item_solar_crest_armor_reduction') then
				hParent:CastAbilityOnTarget(v, hItem, hParent:GetPlayerOwnerID())
				break
			end
		end
	end
end