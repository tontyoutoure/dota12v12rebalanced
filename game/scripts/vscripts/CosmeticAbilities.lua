local CosmeticAbilities = class({});
local Bots = Bots or require("Bots");
local Utilities = Utilities or require("Utilities");

-- TODO generalize

function CosmeticAbilities:Initialize()
    -- register callbacks
    -- ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CosmeticAbilities, "OnNPCSpawned" ), CosmeticAbilities );
    Utilities:RegisterGameEventListener( "npc_spawned", CosmeticAbilities.OnNPCSpawned, CosmeticAbilities );
end


function CosmeticAbilities:OnNPCSpawned( event )
    -- event.entindex

    local hScript = EntIndexToHScript(event.entindex);
    -- do not care about non heroes
    if not hScript:IsRealHero() then
        return;
    end

    local playerId = hScript:GetPlayerOwnerID();

    -- if not Bots:IsBot(playerId) and not hScript.SeenByCosmeticAbilities then
    if not hScript.SeenByCosmeticAbilities then
        local ability = hScript:FindAbilityByName("high_five");
        if not ability then
            ability = hScript:AddAbility("high_five");
        end
        local level = 1;
        ability:SetLevel(level);
        if Bots:IsBot(playerId) then
            ability:SetHidden(true);
            if RandomFloat(0, 1) < 0.35 then
                GameRules:GetGameModeEntity():SetThink(function ()
                    ability:CastAbility();
                    ability:StartCooldown(ability:GetCooldown(level));
                end, "testing "..playerId, 1 + RandomFloat(0, 5));
            end
        end
        hScript.SeenByCosmeticAbilities = true;
    end



end


return CosmeticAbilities;