local Utilities = class({});

function Utilities:RegisterCustomEventListener(event, callback, context)
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
        end
    end;
end

return Utilities;