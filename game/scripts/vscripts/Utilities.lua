local Utilities = class({});

function Utilities:RegisterCustomEventListener(event, callback, context)
    --[[
    local id = CustomGameEventManager:RegisterListener( event, function (clientId, args)
        -- CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
        -- GameRules:SendCustomMessage("event triggered by ".._, 0, 0);
        callback(context, args);
    end);
    ]]

    local id = CustomGameEventManager:RegisterListener( event, Utilities:Throttle(event, callback, context, 0.1) );
end

function Utilities:RegisterGameEventListener(event, callback, context)
    local id = ListenToGameEvent( event, callback, context);
end

-- throttle a callback per clientId
function Utilities:Throttle(event, callback, context, cooldown)
    -- true if locked for clientId
    local locked = {};
    return function (clientId, args)
        if not locked[clientId] then
            locked[clientId] = true;
            callback(context, args);
            local timeoutId = event..clientId;
            Utilities:SetTimeout(timeoutId, function ()
                locked[clientId] = false;
            end, cooldown);
            -- print("++++++++++++++++++++++++++++++++++++++++++");
        else 
            -- print("------------------------------------------");
            -- local message = event.." throttled for "..clientId.."!";
            -- print(message);
            -- GameRules:SendCustomMessage(message, 0, 0);
        end
    end;
end

-- calls callback after delay
function Utilities:SetTimeout(timeoutId, callback, delay)
    GameRules:GetGameModeEntity():SetThink(function ()
        callback();
        return nil;
    end, timeoutId, delay);
end

-- calls callback after delay
function Utilities:SetTimeoutWithMessage(timeoutId, callback, delay, message)
    GameRules:GetGameModeEntity():SetThink(function ()
        print(message);
        GameRules:SendCustomMessage(message, 0, 0);
        return callback();
    end, timeoutId, delay);
end

function Utilities:Test()
    local count = 20;
    Utilities:SetTimeoutWithMessage("Testing Timeout", function ()
        if count > 0 then
            -- print("count is "..count);
            local data = {
                playerId = 0,
                disable = 1,
                targetPlayerId = 1
            };
            local event = {
                name = "set_disable_help",
                data = data
            }
            CustomGameEventManager:Send_ServerToAllClients( "echo", event );
            count = count - 1;
            return 0.01;
        else
            return nil;
        end
    end, 5, "Now calling callback...");
end

return Utilities;