local VoiceChatWheel = class({});
local Utilities = Utilities or require("Utilities");

function VoiceChatWheel:Initialize( GameRules )
    Utilities:RegisterCustomEventListener( "voice_chat_wheel", VoiceChatWheel.VoiceChatWheelHandler, VoiceChatWheel );
end

function VoiceChatWheel:VoiceChatWheelHandler( event )
    print(event.soundname);
    -- EmitAnnouncerSound(event.soundname);
    EmitGlobalSound("Custom_Game."..event.soundname);
end



return VoiceChatWheel;