-- Generated from template

GameMode = GameMode or class({});

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = GameMode();
	GameRules.AddonTemplate:InitGameMode();
end

GoldTuner = GoldTuner or require("GoldTuner");
ExperienceTuner = ExperienceTuner or require("ExperienceTuner");
PostGameStats = PostGameStats or require("PostGameStats");
DisableHelp = DisableHelp or require("DisableHelp");
Kick = Kick or require("Kick");
Vote = Vote or require("Vote");

function GameMode:InitGameMode()

	-- Game Setup Phase
	GameRules:SetCustomGameSetupTimeout( 5 ); -- must be > 0 or host will be unable to pick hero; besides that, value does not seem to matter
	GameRules:EnableCustomGameSetupAutoLaunch( true );
	GameRules:SetCustomGameSetupAutoLaunchDelay( 10 + 1 );
	GameRules:LockCustomGameSetupTeamAssignment( false );

	-- Adjust team limits
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 12 );
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 12 );

	-- Hero Selection Phase 
	-- GameRules:SetHeroSelectionTime( 30 ); -- ignored when EnablePickRules is enabled
	GameRules:SetStrategyTime( 0 );
	GameRules:SetShowcaseTime( 0 );
	GameRules:SetHeroSelectPenaltyTime( 15 );
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( true );
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 0 ); -- 15 CHECK
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 30 );

	-- Pre Game Phase
	GameRules:SetPreGameTime( 90 ); -- 90 CHECK

	-- Game Rules
	GameRules:SetStartingGold( 800 );
	GameRules:GetGameModeEntity():SetRespawnTimeScale( 1.0 );
	
	-- GameRules:SetGoldTickTime( 0.5 ); -- no longer works
	-- GameRules:SetGoldPerTick( 2 );  -- no longer works
	GameRules:GetGameModeEntity():SetPauseEnabled( false );
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true );

	-- Game Tuner (Filters and Thinkers)
	GoldTuner:Initialize( GameRules );
	ExperienceTuner:Initialize( GameRules );

	-- Anti-Troll
	DisableHelp:Initialize();
	Kick:Initialize();
	Vote:Initialize();

	-- Game Thinkers
	GameRules:GetGameModeEntity():SetThink( "GameTimeThinker", self, "GameTimeThinker", 1 );

	-- Game Events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap( self, 'OnGameRulesStateChange'), self );

	-- Other
	-- GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 9999 );
	-- GameRules:GetGameModeEntity():SetThink( "AfterDelay", self, "AfterDelay", 10 ); -- CHECK

end

-- for testing
function GameMode:AfterDelay()
	-- GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS );
	return nil;
end


-- trigger every second of game time
function GameMode:GameTimeThinker()
	local gameState = GameRules:State_Get();
	local time = GameRules:GetDOTATime(false, false);
	if gameState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		GoldTuner:UpdateFactor( time );
		ExperienceTuner:UpdateFactor( time );
	elseif gameState >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

-- call when game state changes
function GameMode:OnGameRulesStateChange()
	local gameState = GameRules:State_Get();
	if gameState == DOTA_GAMERULES_STATE_POST_GAME then
		PostGameStats:SetNetTable();
	elseif gameState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		-- print("kicking self");
		-- Kick:KickPlayer(0);
	elseif gameState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		if IsServer() then
			GameMode:AddBots();
		end
	end

end

-- TODO FIX BOTS
function GameMode:AddBots()
	-- GameRules:BotPopulate(); -- does not work on live server
	local numRadiant = PlayerResource:GetPlayerCountForTeam( DOTA_TEAM_GOODGUYS );
	local numDire = PlayerResource:GetPlayerCountForTeam( DOTA_TEAM_BADGUYS );

	local lane = { "top", "mid", "bot" };
	for i = 1, 12 do
		if (numRadiant < 12) then
			local r = GameMode:RandomHeroName();
			local l = lane[RandomInt(1, 3)];
			Tutorial:AddBot(r, l, "unfair", true);
			numRadiant = numRadiant + 1;
		end
		if (numDire < 12) then
			local r = GameMode:RandomHeroName();
			local l = lane[RandomInt(1, 3)];
			Tutorial:AddBot(r, l, "unfair", false);
			numDire = numDire + 1;
		end
	end

	GameRules:GetGameModeEntity():SetBotThinkingEnabled(true);
	GameRules:GetGameModeEntity():SetBotsInLateGame(true);

end

function GameMode:RandomHeroName() 
	local length = #(GameMode.HeroList);
	local r = RandomInt(1, length);
	return GameMode.HeroList[r];
end

-- does not include newest heroes
GameMode.HeroList = {
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