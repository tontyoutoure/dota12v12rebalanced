local Poof = class({});


local POOF_PARTICLE = "particles/units/heroes/hero_meepo/meepo_poof_end.vpcf";
local SUPER_SAIYAN = "particles/units/heroes/hero_sven/sven_storm_bolt_lightning_sword_01.vpcf";
function Poof:Precache( context )
	PrecacheResource( "particle", POOF_PARTICLE, context );
end

function Poof:Initialize()
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( Poof, "OnNPCSpawned" ), Poof );
end

function Poof:OnNPCSpawned( event )
    -- event.entindex
    local hScript = EntIndexToHScript(event.entindex);
    -- do not care about non heroes
    if not hScript:IsRealHero() then
        return;
    end

    local playerId = hScript:GetPlayerOwnerID();

    if not hScript.SeenByPoof then
        -- local player = hScript:GetPlayerOwner();
        local particle = ParticleManager:CreateParticle( POOF_PARTICLE, PATTACH_ABSORIGIN, hScript);
        EmitSoundOn("Custom_Game.Hero.Spawned", hScript);
        ParticleManager:ReleaseParticleIndex(particle);
        -- hScript:SetThink(function ()
        --     ParticleManager:DestroyParticle(particle, true);
        --     StopSoundOn("Custom_Game.Hero.Spawned", hScript);
        -- end, "Destroy Poof Particle", 1);
    end

    hScript.SeenByPoof = true;
end


return Poof;