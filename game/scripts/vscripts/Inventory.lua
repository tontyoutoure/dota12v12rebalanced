local Inventory = class({});
local Bots = Bots or require("Bots");

local BUY_COOLDOWN = {
    item_tome_of_knowledge = 240
};

-- NOTE: there is some hidden item purchase at the beginning of the game that, if canceled, will crash the game
-- Inventory Filter DOES trigger even if courier is full.


-- last_buy_time[itemName][playerId] = gameTimeOfPurchase
local last_buy_time = {};

function Inventory:InitializeBuyMatrix()
    for item, cooldown in pairs(BUY_COOLDOWN) do
        last_buy_time[item] = {};
        for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
            last_buy_time[item][playerId] = -999999;
        end
    end
end

function Inventory:Initialize()
    GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap( Inventory, "InventoryFilter" ), Inventory );
    Inventory:InitializeBuyMatrix();
end

-- core idea: if the item belongs to you, but this filter has not seen it, then you must have purchased it

function Inventory:InventoryFilter( filterTable )
	local ownerIndex = filterTable["inventory_parent_entindex_const"]
    local itemIndex = filterTable["item_entindex_const"]

	if not ownerIndex or not itemIndex then
		return true
	end

    local owner = EntIndexToHScript(filterTable["inventory_parent_entindex_const"])
    local item = EntIndexToHScript(filterTable["item_entindex_const"])

    if not owner or not item then
        return true;
    end

    local playerId = owner:GetPlayerOwnerID();

    -- handle item purchases

    -- is a purchase only if the purchaser matches the owner inventory
    local purchaser = item:GetPurchaser()
    if not purchaser or purchaser:GetPlayerOwnerID() ~= playerId then
        return true;
    end

    -- do not care about bots
    -- if not owner:IsCourier() and (Bots:IsBot(playerId) or not IsValidEntity(item) or not owner:IsRealHero()) then
    --     return true;
    -- end

    if not item.SeenByInventory then
        -- check if item is restricted
        local itemName = item:GetName();
        if BUY_COOLDOWN[itemName] then
            local currentTime = GameRules:GetDOTATime(false, true); -- must include pregame time 
            if Inventory:PlayerCanBuy(playerId, itemName, currentTime) then
                last_buy_time[itemName][playerId] = currentTime;
                item.SeenByInventory = true;
                return true;
            else -- refund since on cooldown
                Inventory:RefundItem( playerId, item:GetCost() );
                Inventory:PlayerBuyCoolDownMessage( playerId, itemName, currentTime );
                UTIL_Remove(item); -- important
                return false;
            end
        end
    end

	return true;
end

function Inventory:PlayerCanBuy(playerId, itemName, currentTime)
    return last_buy_time[itemName][playerId] + BUY_COOLDOWN[itemName] < currentTime;
end

function Inventory:PlayerBuyCoolDownMessage(playerId, itemName, currentTime)
    local offCoolDownTime = last_buy_time[itemName][playerId] + BUY_COOLDOWN[itemName];
    local cooldown = offCoolDownTime - currentTime;
    -- round
    cooldown = math.floor(cooldown + 0.5);
    local error = {
        message = "Purchasing this item is on cooldown for "..cooldown.." more seconds."
    };
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.Cancel" } );
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
end


function Inventory:RefundItem( playerId, itemCost )

	local unreliableGold = PlayerResource:GetUnreliableGold(playerId);
	-- local reliableGold = PlayerResource:GetReliableGold(playerId);

	if unreliableGold >= itemCost then -- just refund unreliable
		PlayerResource:ModifyGold(playerId, itemCost, false, 6);
	else  -- refund reliable portion
		PlayerResource:ModifyGold(playerId, unreliableGold, false, 6);
		PlayerResource:ModifyGold(playerId, itemCost - unreliableGold, true, 6);
	end
end



return Inventory;