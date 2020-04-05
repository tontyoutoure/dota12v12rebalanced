local Bots = class({});

-- GameRules:BotPopulate(); -- does not work on live server

local laneCount = {
	top = 0,
	bot = 0,
	mid = 0,
};

function Bots:ChooseLane()
	-- find least occupied
	local choice = "top";
	local min = laneCount[choice];
	for lane, count in pairs(laneCount) do
		if count < min then
			choice = lane;
		end
	end
	laneCount[choice] = laneCount[choice] + 1;
	return choice;
end

-- adds bots 
function Bots:AddBots()
-- tontyoutoure: Before adding bots, get a list of human players.
	self.tHumanPlayerList = self.tHumanPlayerList or {}
	for i=0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:IsValidPlayer(i) then
			self.tHumanPlayerList[i] = true
		end
	end
-- tontyoutoure's codes end here
	local numRadiant = Bots:GetTeamCount( DOTA_TEAM_GOODGUYS );
	local numDire = Bots:GetTeamCount( DOTA_TEAM_BADGUYS );

	if numRadiant + numDire >= DOTA_MAX_TEAM_PLAYERS then
		return;
	end

	Tutorial:StartTutorialMode(); -- MUST ADD OR CRASH
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
	-- GameRules:GetGameModeEntity():SetBotsInLateGame(true); -- they might be rushing mid because of this

	local lane = { "top", "mid", "bot" };
	local difficulty = "unfair";

	local N = 12;

	for i = 1, N do
		if (numRadiant < N) then
			local r = Bots:RandomUnusedHeroName();
			local l = Bots:ChooseLane();
			Tutorial:AddBot(r, l, difficulty, true);
			numRadiant = numRadiant + 1;
		end
		if (numDire < N) then
			local r = Bots:RandomUnusedHeroName();
			local l = Bots:ChooseLane();
			Tutorial:AddBot(r, l, difficulty, false);
			numDire = numDire + 1;
		end
	end

end

--[[
-- adds bots in intervals to prevent lag
function Bots:AddBotsInterval()
	Tutorial:StartTutorialMode(); -- MUST ADD OR CRASH
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
	-- GameRules:GetGameModeEntity():SetBotsInLateGame(true); -- they might be rushing mid because of this

	local numRadiant = Bots:GetTeamCount( DOTA_TEAM_GOODGUYS );
	local numDire = Bots:GetTeamCount( DOTA_TEAM_BADGUYS );

	local difficulty = "unfair";

	local i = 1;
	local N = 12;
	local INITIAL_DELAY = 1;
	local SPAWN_INTERVAL = 0.5;

	GameRules:GetGameModeEntity():SetThink(function()
		if i <= 12 then
			if (numRadiant < 12) then
				local r = Bots:RandomUnusedHeroName();
				local l = Bots:ChooseLane();
				Tutorial:AddBot(r, l, difficulty, true);
				numRadiant = numRadiant + 1;
			end
			if (numDire < 12) then
				local r = Bots:RandomUnusedHeroName();
				local l = Bots:ChooseLane();
				Tutorial:AddBot(r, l, difficulty, false);
				numDire = numDire + 1;
			end
			i = i + 1;
			-- return SPAWN_INTERVAL + RandomFloat(-0.1, 0.1);
			return SPAWN_INTERVAL;
		else
			return nil;
		end
	end, "Spawn Bots", INITIAL_DELAY);
end
]]

--[[
function Bots:SetBotDifficulty()
	-- set bot difficulty
	for i = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
		local player = PlayerResource:GetPlayer(i);
		print("player "..i.." is:")
		DeepPrintTable(player);
		local hero = player:GetAssignedHero();
		DeepPrintTable(hero);
		-- hero:SetBotDifficulty(4);
	end
end
--]]

function Bots:GetTeamCount( teamId )
	local count = 0;
	for i = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
		if PlayerResource:IsValidPlayer(i) and PlayerResource:GetTeam(i) == teamId then
			count = count + 1;
		end
	end
	return count;
end

function Bots:RandomUnusedHeroName() 
	local length = #(Bots.HeroList);
	local r = RandomInt(1, length);
	local heroName = Bots.HeroList[r];
	while PlayerResource:IsHeroSelected(heroName, false) do
		r = (r + 1) % length + 1;
		heroName = Bots.HeroList[r];
	end

	-- true doesn't work
	-- if PlayerResource:IsHeroSelected(heroName, true) ~= PlayerResource:IsHeroSelected(heroName, false) then
	-- 	print(heroName);
	-- end

	return heroName;
end


function Bots:IsBot( playerId )
	return PlayerResource:GetConnectionState(playerId) == 1;
end

-- does not include newest heroes
Bots.HeroList = {
	"npc_dota_hero_axe",
	"npc_dota_hero_bane",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_lich",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_luna",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_pudge",
	-- "npc_dota_hero_razor", -- does not work
	"npc_dota_hero_sand_king",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_sniper",
	"npc_dota_hero_sven",
	-- "npc_dota_hero_tidehunter", -- does not work
	"npc_dota_hero_tiny",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_viper",
	"npc_dota_hero_warlock",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_zuus"
};



-- tontyoutoure's codes start from here
-- basically they give bots 4 modifiers to make the bots work properly. 

function _OnNPCSpawned(keys)
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_PRE_GAME then return end

	local hHero = EntIndexToHScript(keys.entindex)	
	if hHero.bInitialized or not hHero:IsHero() then return end	 

	if not Bots.tHumanPlayerList[hHero:GetPlayerOwnerID()] then

		hHero:AddNewModifier(hHero, nil, "modifier_bots_behavior", {}).tHumanPlayerList = Bots.tHumanPlayerList
		if hHero:GetName() == "npc_dota_hero_axe" and not hHero:IsIllusion() then
			hHero:AddNewModifier(hHero, nil, "modifier_axe_thinker", {})
		end	
		if hHero:IsRealHero() and not hHero:IsTempestDouble() and not hHero:IsClone() then
			hHero:AddNewModifier(hHero, nil, "modifier_bot_use_items", {})
			hHero:AddNewModifier(hHero, nil, 'modifier_item_assemble_fix', {})
		end
	end

--tontyoutoure: Not sure these two causes lagging


	hHero.bInitialized = true;
end

-- modifier_bot_use_items makes bots can use some other items
LinkLuaModifier('modifier_bot_use_items', 'global_modifiers.lua', LUA_MODIFIER_MOTION_NONE)
-- modifier_item_assemble_fix makes bots can build more items and fix some bugs
LinkLuaModifier('modifier_item_assemble_fix', 'global_modifiers.lua', LUA_MODIFIER_MOTION_NONE)
-- modifier_bots_behavior Make bots able to attack inner towers/base, pick up runes and activate watch towers.
LinkLuaModifier('modifier_bots_behavior', 'global_modifiers.lua', LUA_MODIFIER_MOTION_NONE)
--Last time I check, Axe cannot use his abilities, modifier_axe_thinker makes him able to do it.
LinkLuaModifier('modifier_axe_thinker', 'global_modifiers.lua', LUA_MODIFIER_MOTION_NONE)
ListenToGameEvent('npc_spawned', _OnNPCSpawned, nil)

-- tontyoutoure's codes end here

return Bots;