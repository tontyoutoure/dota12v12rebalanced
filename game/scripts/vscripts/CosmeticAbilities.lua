local CosmeticAbilities = class({});
local Bots = Bots or require("Bots");

-- TODO generalize

function CosmeticAbilities:Initialize()
    -- register callbacks
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CosmeticAbilities, "OnNPCSpawned" ), CosmeticAbilities );
end


function CosmeticAbilities:OnNPCSpawned( event )
    -- event.entindex

    local hScript = EntIndexToHScript(event.entindex);
    -- do not care about non heroes
    if not hScript:IsRealHero() then
        return;
    end

    local playerId = hScript:GetPlayerOwnerID();

    if not Bots:IsBot(playerId) and not hScript.SeenByCosmeticAbilities then
        local ability = hScript:FindAbilityByName("high_five");
        if not ability then
            ability = hScript:AddAbility("high_five");
        end
        local level = 1;
        ability:SetLevel(level);
        -- ability:SetHidden(true);
        -- GameRules:GetGameModeEntity():SetThink(function ()
        --     ability:CastAbility();
        --     ability:StartCooldown(ability:GetCooldown(level));
        -- end, "testing "..playerId, 2 + RandomFloat(-1, 1));
        hScript.SeenByCosmeticAbilities = true;
    end


end


return CosmeticAbilities;