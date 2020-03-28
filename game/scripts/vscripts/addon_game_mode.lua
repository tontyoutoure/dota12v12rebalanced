GameMode = GameMode or class({});

-- set parameters
local HERO_BANNING_TIME = 15;
local HERO_SELECTION_TIME = 30;
local HERO_SELECTION_PENALTY_TIME = 15;
local PRE_GAME_TIME = 90;

local STARTING_GOLD = 600;
local RESPAWN_SCALE = 0.65;

if IsInToolsMode() then
	HERO_BANNING_TIME = 0;
end

-- Load Lua modules
GoldTuner = GoldTuner or require("GoldTuner");
ExperienceTuner = ExperienceTuner or require("ExperienceTuner");
PostGameStats = PostGameStats or require("PostGameStats");
DisableHelp = DisableHelp or require("DisableHelp");
Vote = Vote or require("Vote");
Bots = Bots or require("Bots");
Inventory = Inventory or require("Inventory");
CosmeticAbilities = CosmeticAbilities or require("CosmeticAbilities");
Color = Color or require("Color");
Fountain = Fountain or require("Fountain");
Rune = Rune or require("Rune");

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
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 );
	GameRules:LockCustomGameSetupTeamAssignment( true );

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
	Inventory:Initialize();
	-- Vote:Initialize(); -- moved to Pre Game 

	-- Extras
	CosmeticAbilities:Initialize();
	Color:Initialize();

	-- Other
	Rune:Initialize();

	-- Game Events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap( GameMode, 'OnGameRulesStateChange'), GameMode );

end

--[[
function GameMode:TimePrinter()
	local gameState = GameRules:State_Get();
	local time;
	if gameState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- print("dotatime "..GameRules:GetDOTATime(false, true));
		-- print("gametime "..GameRules:GetGameTime());
	elseif gameSate == DOTA_GAMERULES_STATE_IN_PROGRESS then
		-- print("dotatime "..GameRules:GetDOTATime(false, true));
		-- print("gametime "..GameRules:GetGameTime());
	end
	return 1;
end
--]]

-- call when game state changes
function GameMode:OnGameRulesStateChange()
	if IsServer() then
		local gameState = GameRules:State_Get();
		if gameState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		elseif gameState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
			Bots:AddBotsInterval();
		elseif gameState == DOTA_GAMERULES_STATE_PRE_GAME then
			Vote:Initialize(); 
			Fountain:Buff();
		elseif gameState == DOTA_GAMERULES_STATE_POST_GAME then
			PostGameStats:SetNetTable();
		end
	end
end
