-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
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
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()

	-- Game Setup Phase
	GameRules:SetCustomGameSetupTimeout( 1 ) -- must be 1 or host will be unable to pick hero
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameRules:LockCustomGameSetupTeamAssignment( true )

	-- Adjust team limits
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 12 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 12 )

	-- GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )

	-- Hero Selection Phase 
	GameRules:SetHeroSelectionTime( 60 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetShowcaseTime( 0 )

	-- Pre Game Phase
	GameRules:SetPreGameTime( 90 )


end

-- -- Evaluate the state of the game
-- function CAddonTemplateGameMode:OnThink()
-- 	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
-- 		--print( "Template addon script is running." )
-- 	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
-- 		return nil
-- 	end
-- 	return 1
-- end