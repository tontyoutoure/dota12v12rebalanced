-- Generated from template

if GameMode == nil then
	GameMode = class({});
end

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

GoldTuner = require("GoldTuner");
ExperienceTuner = require("ExperienceTuner");

function GameMode:InitGameMode()

	-- Game Setup Phase
	GameRules:SetCustomGameSetupTimeout( 1 ); -- must be 1 or host will be unable to pick hero
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 );
	GameRules:LockCustomGameSetupTeamAssignment( true );

	-- Adjust team limits
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 12 );
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 12 );

	-- Hero Selection Phase 
	-- GameRules:SetHeroSelectionTime( 30 ); -- ignored when EnablePickRules is enabled
	GameRules:SetStrategyTime( 0 );
	GameRules:SetShowcaseTime( 0 );
	GameRules:SetHeroSelectPenaltyTime( 15 );
	GameRules:GetGameModeEntity():SetSelectionGoldPenaltyEnabled( true );
	GameRules:GetGameModeEntity():SetDraftingBanningTimeOverride( 15 );
	GameRules:GetGameModeEntity():SetDraftingHeroPickSelectTimeOverride( 30 );

	-- Pre Game Phase
	GameRules:SetPreGameTime( 0 );

	-- Game Rules
	GameRules:SetStartingGold( 800 );
	
	-- GameRules:SetGoldTickTime( 0.5 ); -- no longer works
	-- GameRules:SetGoldPerTick( 2 );  -- no longer works
	GameRules:GetGameModeEntity():SetPauseEnabled( false );
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled( true );

	-- Game Filters
	GameRules:GetGameModeEntity():SetModifyGoldFilter( Dynamic_Wrap( GoldTuner, "GoldFilter" ), GoldTuner );
	GameRules:GetGameModeEntity():SetModifyExperienceFilter( Dynamic_Wrap( ExperienceTuner, "ExperienceFilter" ), ExperienceTuner );

	-- Game Thinker
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 1 );

end


-- Evaluate the state of the game
function GameMode:OnThink()
	local time = GameRules:GetDOTATime(false, false);
	local allHeroes = HeroList:GetAllHeroes();

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then

		GoldTuner:UpdateFactor( time );
		GoldTuner:IncrementPlayerGold( allHeroes );

		ExperienceTuner:UpdateFactor( time );

	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end

	return 1
end