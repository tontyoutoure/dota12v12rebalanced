GameMode = GameMode or class({});

-- set parameters
local HERO_BANNING_TIME = 0;
local HERO_SELECTION_TIME = 30;
local HERO_SELECTION_PENALTY_TIME = 15;
local PRE_GAME_TIME = 90;

local STARTING_GOLD = 800;
local RESPAWN_SCALE = 0.6;

-- Load Lua modules
local GoldTuner = GoldTuner or require("GoldTuner");
local ExperienceTuner = ExperienceTuner or require("ExperienceTuner");
local PostGameStats = PostGameStats or require("PostGameStats");
local DisableHelp = DisableHelp or require("DisableHelp");
local Kick = Kick or require("Kick");
local Vote = Vote or require("Vote");
local Bots = Bots or require("Bots");
local Inventory = Inventory or require("Inventory");

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource( "soundfile", "soundevents/dota_rebalanced.vsndevts", context );

end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = GameMode();
	GameRules.AddonTemplate:InitGameMode();
end

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
	-- GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME ); -- ignored when EnablePickRules is enabled
	GameRules:SetStrategyTime( 0 );
	GameRules:SetShowcaseTime( 0 );
	GameRules:SetHeroSelectPenaltyTime( 15 );
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( true );
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( HERO_BANNING_TIME );
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( HERO_SELECTION_TIME ); 

	-- Pre Game Phase
	GameRules:SetPreGameTime( PRE_GAME_TIME ); -- 90 CHECK

	-- Game Rules
	GameRules:SetStartingGold( STARTING_GOLD );
	GameRules:GetGameModeEntity():SetPauseEnabled( false );
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true );
	GameRules:GetGameModeEntity():SetRespawnTimeScale( RESPAWN_SCALE );

	-- Game Tuner (Filters and Thinkers)
	GoldTuner:Initialize( GameRules );
	ExperienceTuner:Initialize( GameRules );

	-- Anti-Troll
	DisableHelp:Initialize();
	Kick:Initialize();
	Vote:Initialize();
	Inventory:Initialize();

	-- Game Events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap( GameMode, 'OnGameRulesStateChange'), GameMode );

	-- Other
	-- GameRules:GetGameModeEntity():SetThink( "TimePrinter", GameMode, "TimePrinter", 1 );
end

-- function GameMode:TimePrinter()
-- 	local gameState = GameRules:State_Get();
-- 	local time;
-- 	if gameState == DOTA_GAMERULES_STATE_PRE_GAME then
-- 		print("dotatime "..GameRules:GetDOTATime(false, true));
-- 		print("gametime "..GameRules:GetGameTime());
-- 	elseif gameSate == DOTA_GAMERULES_STATE_IN_PROGRESS then
-- 		print("dotatime "..GameRules:GetDOTATime(false, true));
-- 		print("gametime "..GameRules:GetGameTime());
-- 	end
-- 	return 1;
-- end

-- call when game state changes
function GameMode:OnGameRulesStateChange()
	local gameState = GameRules:State_Get();
	if gameState == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif gameState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		if IsServer() then
			Bots:AddBotsInterval();
		end
	elseif gameState == DOTA_GAMERULES_STATE_POST_GAME then
		PostGameStats:SetNetTable();
	end
end