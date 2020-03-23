local Poof = class({});


local POOF_PARTICLE = "particles/units/heroes/hero_meepo/meepo_poof_end.vpcf";
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

    local particle = ParticleManager:CreateParticle( POOF_PARTICLE, PATTACH_ABSORIGIN, hScript);
    EmitSoundOn("Custom_Game.Hero.Spawned", hScript);
end


return Poof;