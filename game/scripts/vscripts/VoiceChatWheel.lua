local VoiceChatWheel = class({});
local Utilities = Utilities or require("Utilities");

local PLAYER_COOLDOWN = 60;

local PlayerLastUsage = {};

function VoiceChatWheel:Initialize( GameRules )
    for i = 0, 23 do
        PlayerLastUsage[i] = -999999;
    end
    VoiceChatWheel:Loader();
    Utilities:RegisterCustomEventListener( "voice_chat_wheel", VoiceChatWheel.VoiceChatWheelHandler, VoiceChatWheel );
end

function VoiceChatWheel:VoiceChatWheelHandler( event )
    local soundname = event.soundname;
    if soundname == "" then
        return;
    end

    local playerId = event.playerId;
    local currentTime = GameRules:GetDOTATime(false, true); -- must include pregame time 
    local remainingCooldown = (PlayerLastUsage[playerId] + PLAYER_COOLDOWN) - currentTime;
    if remainingCooldown < 0 then
        EmitAnnouncerSound("Custom_Game."..soundname);
        PlayerLastUsage[playerId] = currentTime;
    else  
        VoiceChatWheel:PlayerCoolDownMessage(playerId, remainingCooldown);
    end
end

function VoiceChatWheel:PlayerCoolDownMessage(playerId, cooldown)
    -- round
    cooldown = math.floor(cooldown + 0.5);
    local error = {
        message = "Using the voice chat wheel is on cooldown for "..cooldown.." more seconds."
    };
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "play_sound", { sound = "General.Cancel" } );
    CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerId), "display_error_from_server", error );
end

function VoiceChatWheel:Loader()

    local soundGroupNames = LoadKeyValues("scripts/tables/sound_groups_map.txt");

    local soundGroups = {};
    for i = 0, 7 do
        soundGroups[i] = {};
    end

    local sounds = LoadKeyValues("scripts/tables/sounds_map.txt");

    for k, v in pairs(sounds) do
        local g = v.group;
        if g >= 0 and g <= 7 then
            soundGroups[g][k] = v;
        end
    end

    CustomNetTables:SetTableValue( "voice_chat_groups", "soundGroupNames", soundGroupNames );
    for i = 0, 7 do
        CustomNetTables:SetTableValue( "voice_chat_table", tostring(i), soundGroups[i]);
    end

end


return VoiceChatWheel;