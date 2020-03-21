local ShopCooldown = class({});
local Courier = Courier or require("Courier");

-- notes: hero inventory is 0-15
-- 0-5 is main inventory
-- 6-8 is backpack
-- 9-14 is stash
-- 15 is tp scroll
-- 16 is probably neutral slot

-- also note: items are considered a subclass of abilities, hence item name = ability name

-- side effect: reliable gold is converted to unreliable gold


local BUY_COOLDOWN = {
    item_tome_of_knowledge = 240
};

-- last_buy_time[itemName][playerId] = gameTimeOfPurchase
local last_buy_time = {};

function ShopCooldown:Initialize()
    ShopCooldown:InitializeBuyMatrix();
	ListenToGameEvent('dota_item_purchased', Dynamic_Wrap( ShopCooldown, 'OnItemPurchase'), ShopCooldown );
end

function ShopCooldown:InitializeBuyMatrix()
    for itemName, cooldown in pairs(BUY_COOLDOWN) do
        last_buy_time[itemName] = {};
        for playerId = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
            last_buy_time[itemName][playerId] = -999999;
        end
    end
end

function ShopCooldown:FindNewestItem( itemsList )
    if #itemsList == 0 then
        return nil;
    end

    local newest = itemsList[1];
    for i = 2, #itemsList do
        local item = itemsList[i];
        if item:GetPurchaseTime() > newest:GetPurchaseTime() then
            newest = item;
        end
    end
    return newest;
end

function ShopCooldown:FilterByPlayerId( playerId, itemsList )
    local filtered = {};
    local i = 1;
    for j = 1, #itemsList do
        local item = itemsList[j];
        local purchaserId = item:GetPurchaser():GetPlayerID();
        if purchaserId == playerId then
            filtered[i] = item;
            i = i + 1;
        end
    end
    return filtered;
end

function ShopCooldown:HeroHasSlot( hero )
    -- 15 is tp slot
    for i = 0, 14 do
        local item = hero:GetItemInSlot(i);
        if not item then
            return true;
        end
    end
    return false;
end

function ShopCooldown:CourierHasSlot( courier )
    for i = 0, 8 do
        local item = courier:GetItemInSlot(i);
        if not item then
            return true;
        end
    end
    return false;
end

function ShopCooldown:OnItemPurchase( event )

    local itemName = event.itemname;
    local playerId = event.PlayerID;
    local itemCost = event.itemcost;

    -- get purchased item by searching all items
    -- filtering by owner
    -- then taking the most recently purchased
    local itemsList = Entities:FindAllByClassname( itemName );
    local filtered = ShopCooldown:FilterByPlayerId( playerId, itemsList );
    if #filtered == 0 then
        return nil;
    end
    local purchasedItem = ShopCooldown:FindNewestItem( filtered );

    -- check if item is restricted
    if BUY_COOLDOWN[itemName] then
        local currentTime = GameRules:GetDOTATime(false, true); -- must include pre-game time 
        if ShopCooldown:PlayerCanBuy(playerId, itemName, currentTime) then
            last_buy_time[itemName][playerId] = currentTime;
        else -- refund since on cooldown
            ShopCooldown:ReturnItem( purchasedItem, playerId );
            ShopCooldown:PlayerBuyCoolDownMessage( playerId, itemName, currentTime );
        end
    end
end

-- this function relies on the fact that there is at least one open inventory slot on the courier or the hero
function ShopCooldown:ReturnItem( purchasedItem, playerId )
    local hero = PlayerResource:GetPlayer(playerId):GetAssignedHero();
    local courier = Courier:GetCourier(playerId);

    if ShopCooldown:HeroHasSlot(hero) then
        hero:SellItem( purchasedItem );
    -- elseif ShopCooldown:CourierHasSlot(hero) then
    else
        courier:SellItem( purchasedItem );
    end

    -- ShopCooldown:RefundItem( playerId, itemCost );
    UTIL_Remove( purchasedItem ); -- does not restock
end

function ShopCooldown:PlayerCanBuy(playerId, itemName, currentTime)
    return last_buy_time[itemName][playerId] + BUY_COOLDOWN[itemName] < currentTime;
end

function ShopCooldown:PlayerBuyCoolDownMessage(playerId, itemName, currentTime)
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

function ShopCooldown:RefundItem( playerId, itemCost )
	local unreliableGold = PlayerResource:GetUnreliableGold(playerId);
    -- local reliableGold = PlayerResource:GetReliableGold(playerId);

	if unreliableGold >= itemCost then -- just refund unreliable
		PlayerResource:ModifyGold(playerId, itemCost, false, 6);
	else  -- refund reliable portion
		PlayerResource:ModifyGold(playerId, unreliableGold, false, 6);
        PlayerResource:ModifyGold(playerId, itemCost - unreliableGold, true, 6);
	end
end

return ShopCooldown;