local Bots = class({});

-- GameRules:BotPopulate(); -- does not work on live server

-- adds bots 
function Bots:AddBots()
	Tutorial:StartTutorialMode(); -- MUST ADD OR CRASH
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
	-- GameRules:GetGameModeEntity():SetBotsInLateGame(true); -- they might be rushing mid because of this

	-- GameRules:BotPopulate(); -- does not work on live server
	local numRadiant = Bots:GetTeamCount( DOTA_TEAM_GOODGUYS );
	local numDire = Bots:GetTeamCount( DOTA_TEAM_BADGUYS );

	local lane = { "top", "mid", "bot" };
	local difficulty = "unfair";

	local N = 12;

	for i = 1, N do
		if (numRadiant < N) then
			local r = Bots:RandomUnusedHeroName();
			local l = lane[RandomInt(1, 3)];
			Tutorial:AddBot(r, l, difficulty, true);
			numRadiant = numRadiant + 1;
		end
		if (numDire < N) then
			local r = Bots:RandomUnusedHeroName();
			local l = lane[RandomInt(1, 3)];
			Tutorial:AddBot(r, l, difficulty, false);
			numDire = numDire + 1;
		end
	end

end

-- adds bots in intervals to prevent lag
function Bots:AddBotsInterval()
	Tutorial:StartTutorialMode(); -- MUST ADD OR CRASH
	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
	-- GameRules:GetGameModeEntity():SetBotsInLateGame(true); -- they might be rushing mid because of this

	local numRadiant = Bots:GetTeamCount( DOTA_TEAM_GOODGUYS );
	local numDire = Bots:GetTeamCount( DOTA_TEAM_BADGUYS );

	local lane = { "top", "mid", "bot" };
	local difficulty = "unfair";

	local i = 1;
	local N = 12;
	local INITIAL_DELAY = 1;
	local SPAWN_INTERVAL = 0.4;

	GameRules:GetGameModeEntity():SetThink(function()
		if i <= 12 then
			if (numRadiant < 12) then
				local r = Bots:RandomUnusedHeroName();
				local l = lane[RandomInt(1, 3)];
				Tutorial:AddBot(r, l, difficulty, true);
				EmitGlobalSound("Bots.Spawned");
				numRadiant = numRadiant + 1;
			end
			if (numDire < 12) then
				local r = Bots:RandomUnusedHeroName();
				local l = lane[RandomInt(1, 3)];
				Tutorial:AddBot(r, l, difficulty, false);
				EmitGlobalSound("Bots.Spawned");
				numDire = numDire + 1;
			end
			i = i + 1;
			return SPAWN_INTERVAL;
		else
			return nil;
		end
	end, "Spawn Bots", INITIAL_DELAY);

end


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
	while PlayerResource:IsHeroSelected(heroName) do
		r = (r + 1) % length + 1;
		heroName = Bots.HeroList[r];
	end
	return heroName;
end

-- does not include newest heroes
Bots.HeroList = {
	"npc_dota_hero_abaddon",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_axe",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_centaur",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_chen",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_enigma",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_furion",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_huskar",
	"npc_dota_hero_invoker",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lich",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_lone_druid",
	"npc_dota_hero_luna",
	"npc_dota_hero_lycan",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_medusa",
	"npc_dota_hero_meepo",
	"npc_dota_hero_mirana",
	"npc_dota_hero_morphling",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_oracle",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_puck",
	"npc_dota_hero_pudge",
	"npc_dota_hero_pugna",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_razor",
	"npc_dota_hero_riki",
	"npc_dota_hero_rubick",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_shredder",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_slardar",
	"npc_dota_hero_slark",
	"npc_dota_hero_sniper",
	"npc_dota_hero_spectre",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_sven",
	"npc_dota_hero_techies",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_tinker",
	"npc_dota_hero_tiny",
	"npc_dota_hero_treant",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_tusk",
	"npc_dota_hero_undying",
	"npc_dota_hero_ursa",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_viper",
	"npc_dota_hero_visage",
	"npc_dota_hero_warlock",
	"npc_dota_hero_weaver",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_wisp",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_zuus"
};

return Bots;