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
			-- return SPAWN_INTERVAL + RandomFloat(-0.1, 0.1);
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
	"npc_dota_hero_razor",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_sniper",
	"npc_dota_hero_sven",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_tiny",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_viper",
	"npc_dota_hero_warlock",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_zuus"
};

return Bots;