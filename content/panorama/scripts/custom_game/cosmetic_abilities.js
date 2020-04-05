
var CosmeticAbilities = {
    inventoryContainerPanel: null,
    cosmeticAbilitiesHud: null,
    size: null,
    scale: 1
};

function SetCosmeticAbilitiesHud(){
    var hudPanel = $.GetContextPanel().GetParent().GetParent().GetParent();
    var lowerHud = hudPanel.FindChild("HUDElements").FindChild("lower_hud");
    CosmeticAbilities.inventoryContainerPanel = lowerHud.FindChildTraverse("InventoryContainer");
    CosmeticAbilities.cosmeticAbilitiesHud = $.GetContextPanel();
    CosmeticAbilities.scale = 1080 / Game.GetScreenHeight();

    var inventoryContainerPanel = CosmeticAbilities.inventoryContainerPanel;
    var cosmeticAbilitiesHud = CosmeticAbilities.cosmeticAbilitiesHud;
    var scale = CosmeticAbilities.scale;

    var size = {
        height: inventoryContainerPanel.desiredlayoutheight,
        width: inventoryContainerPanel.desiredlayoutwidth
    };
    size.height = Math.floor(size.height * scale + 0.5);
    size.width = Math.floor(size.width * scale + 0.5);
    cosmeticAbilitiesHud.style.height = size.height + "px";
    cosmeticAbilitiesHud.style.width = size.width + "px";

    CosmeticAbilities.size = size;
}

function SetHighFivePanel() {
    var highFivePanel = $.GetContextPanel().FindChildTraverse("CosmeticAbility1");
    highFivePanel.style.visibility = "visible";
    var abilityName = "high_five";
    highFivePanel.style.backgroundColor = "rgba(0,0,0,0)";
    highFivePanel.style.backgroundImage = "url(\"file://{images}/spellicons/consumables/" + abilityName + ".png\")";
    highFivePanel.style.backgroundSize = "100% auto";
    highFivePanel.style.backgroundRepeat = "no-repeat";
    highFivePanel.style.backgroundPosition = "left bottom";



    var heroUnit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
    var ability = Entities.GetAbilityByName(heroUnit, "high_five"); 
    highFivePanel.SetPanelEvent("onactivate", function () {
        Abilities.ExecuteAbility( ability, heroUnit, false );
    });
}

function PositionCosmeticAbilitiesHud(){
    var inventoryContainerPanel = CosmeticAbilities.inventoryContainerPanel;
    var cosmeticAbilitiesHud = CosmeticAbilities.cosmeticAbilitiesHud;
    var scale = CosmeticAbilities.scale;
    var size = CosmeticAbilities.size;
    var pos = inventoryContainerPanel.GetPositionWithinWindow();
    pos.x = Math.floor(pos.x * scale + 0.5);
    pos.y = Math.floor(pos.y * scale + 0.5);
    pos.y = pos.y - size.height;
    cosmeticAbilitiesHud.style.position = pos.x + "px" + " " + pos.y + "px" + " " + 0 + "px";
}

/*
function GetPanelPosition(panel, hud){
    var pos = {
        x: 0,
        y: 0
    };
    while (panel != null && panel != hud) {
        pos.x = pos.x + panel.actualxoffset;
        pos.y = pos.y + panel.actualyoffset;
        panel = panel.GetParent();
    }
    return pos;
}
*/

function UpdateCosmeticAbilitiesPanel() {
    var currentUnit = Players.GetLocalPlayerPortraitUnit();
    var heroUnit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
    if (currentUnit == heroUnit) {
        CosmeticAbilities.cosmeticAbilitiesHud.style.visibility = "visible";
    } else {
        CosmeticAbilities.cosmeticAbilitiesHud.style.visibility = "collapse";
    }


    $.Schedule(1/60, UpdateCosmeticAbilitiesPanel);
}

(function () {
    var callbackHandle = GameEvents.Subscribe( "npc_spawned", function (event) {

        var entIndex = event.entindex;
        var heroUnit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());

        if (entIndex == heroUnit) {
            $.Schedule(2, function () {
                SetCosmeticAbilitiesHud();
                SetHighFivePanel();
                PositionCosmeticAbilitiesHud();
                UpdateCosmeticAbilitiesPanel();
            });
            GameEvents.Unsubscribe(callbackHandle);
        }
    });
})();