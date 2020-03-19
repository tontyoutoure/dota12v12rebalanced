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
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context );

end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = GameMode();
	GameRules.AddonTemplate:InitGameMode();
end


-- Load Lua modules
GoldTuner = GoldTuner or require("GoldTuner");
ExperienceTuner = ExperienceTuner or require("ExperienceTuner");
PostGameStats = PostGameStats or require("PostGameStats");
DisableHelp = DisableHelp or require("DisableHelp");
Kick = Kick or require("Kick");
Vote = Vote or require("Vote");
Bots = Bots or require("Bots");


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
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 30 ); -- 30 CHECK

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
	GameRules:GetGameModeEntity():SetThink( "GameTimeThinker", GameMode, "GameTimeThinker", 1 );

	--TODO
	-- GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( GameMode.InventoryFilter, GameMode );
	-- Game Events
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap( GameMode, 'OnGameRulesStateChange'), GameMode );

	-- Other
	-- GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 9999 );
	-- GameRules:GetGameModeEntity():SetThink( "AfterDelay", self, "AfterDelay", 10 ); -- CHECK

end

function GameMode:InventoryFilter( filterTable )
	DeepPrintTable(filterTable);
	return true;
end

-- for testing
function GameMode:AfterDelay()
	-- GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS );
	return nil;
end


-- trigger every second of game time
function GameMode:GameTimeThinker()
	-- Say(PlayerResource:GetPlayer(0), "HELLLLLLLOOOOOOOOOOO", true); --TODO
	-- GameRules:SendCustomMessage("what", 0, 0);
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
	if gameState == DOTA_GAMERULES_STATE_HERO_SELECTION then
	elseif gameState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		if IsServer() then
			Bots:AddBots();
		end
	elseif gameState == DOTA_GAMERULES_STATE_PRE_GAME then
		-- GameMode:SetBotDifficulty();
	elseif gameState == DOTA_GAMERULES_STATE_POST_GAME then
		PostGameStats:SetNetTable();
	end
end