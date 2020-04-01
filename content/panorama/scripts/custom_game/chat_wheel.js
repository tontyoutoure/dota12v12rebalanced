var ChatWheel = {};

function ChatWheelInitialize(){
    ChatWheel.Hud = $.GetContextPanel();
    ChatWheel.ChatWheel = ChatWheel.Hud.FindChildTraverse("ChatWheel");
    ChatWheel.Arrow = ChatWheel.Hud.FindChildTraverse("ArrowContainer");
    ChatWheel.Circle = ChatWheel.Hud.FindChildTraverse("Circle");
    ChatWheel.Options = [];
    for (var i = 0; i <= 7; ++i) {
        ChatWheel.Options[i] = ChatWheel.Hud.FindChildTraverse("ChatOption" + i);
        ChatWheel.Options[i].SetAttributeString("soundname", "");
    }
    ChatWheel.Highlighted = null;
    ChatWheel.Scheduled = null;
    ChatWheel.Active = false;
    ChatWheel.Page = 0;
    ChatWheel.Origin = null;
}

function OnMouseClickChatWheel(){
    if (ChatWheel.Active) {
        if (ChatWheel.Page == 0 && ChatWheel.Highlighted !== null) {
            ChatWheel.Page = 1;
            SetSoundOptions();
        } else {
            OnChatWheelKeyUp();
        }
    }
}

function SetSoundOptions(){
    var group = ChatWheel.Highlighted;
    var sounds = CustomNetTables.GetTableValue("voice_chat_table", group.toString());
    var i = 0;
    for (var name in sounds) {
        if (sounds.hasOwnProperty(name)) {
            ChatWheel.Options[i].text = sounds[name].text;
            ChatWheel.Options[i].SetAttributeString("soundname", name);
            i = i + 1;
        }
    }
    for (i = i; i < 8; ++i) {
        ChatWheel.Options[i].text = "";
        ChatWheel.Options[i].SetAttributeString("soundname", "");
    }
}

function SetSoundGroupOptions(){
    var soundGroupNames = CustomNetTables.GetTableValue("voice_chat_groups", "soundGroupNames");
    for (var i = 0; i <= 7; ++i) {
        ChatWheel.Options[i].text = soundGroupNames[i];
    }
}

function OnChatWheelKeyDown(){
    ChatWheel.Page = 0;
    SetSoundGroupOptions();
    ChatWheel.ChatWheel.style.visibility = 'visible';
    ChatWheel.Active = true;
    var W = ChatWheel.Hud.actuallayoutwidth;
    var H = ChatWheel.Hud.actuallayoutheight;
    var origin = [W/2, H/2];
    // ChatWheel.Origin = GameUI.GetCursorPosition();
    ChatWheel.Origin = origin;
    UpdateChatWheel();
}

function OnChatWheelKeyUp(){
    if (ChatWheel.Active) {
        ChatWheel.ChatWheel.style.visibility = 'collapse';
        ChatWheel.Active = false;
        if (ChatWheel.Scheduled) {
            $.CancelScheduled(ChatWheel.Scheduled);
            ChatWheel.Scheduled = null;
        }

        if (ChatWheel.Page == 1 && ChatWheel.Highlighted !== null) {
            // play selected sound if any
            var i = ChatWheel.Highlighted;
            var soundname = ChatWheel.Options[i].GetAttributeString("soundname", "");
            var soundtext = ChatWheel.Options[i].text;
            // send sound event to server
            PlayerPlaySound(soundname, soundtext);
        }
    }
}

function PlayerPlaySound(soundname, soundtext) {
    var event = {
        playerId: Game.GetLocalPlayerID(),
        soundname: soundname,
        soundtext: soundtext
    };
    GameEvents.SendCustomGameEventToServer( "voice_chat_wheel", event );
}

function UpdateChatWheel(){
    var interval = 1/60;

    var W = ChatWheel.Hud.actuallayoutwidth;
    var H = ChatWheel.Hud.actuallayoutheight;
    // var origin = [W/2, H/2];
    var radialThreshold = 0.04 * H;
    var origin = ChatWheel.Origin;
    var cursorPosition = GameUI.GetCursorPosition();

    var north = [0, -1];
    var vd = vectorDifference(cursorPosition, origin);
    var vdm = vectorMagnitude(vd);
    var v = normalize(vd);
    
    if (vdm == 0) {
        $.Schedule( interval, UpdateChatWheel );
        return;
    }

    var angle = angularDifference(north, v);
    var i = ChatWheel.Highlighted;
    var j = GetSection(angle);

    var circleR = Math.min(0.6 * radialThreshold, vdm);
    var circleX = Math.round(circleR * v[0]); 
    var circleY = Math.round(circleR * v[1]);
    ChatWheel.Circle.style.transform = "translate3d("+circleX+"px, "+circleY+"px, 0)";

    if (vdm < radialThreshold || !angle) {
        if (i != null) {
            ChatWheel.Options[i].RemoveClass("Highlighted");
        }
        ChatWheel.Arrow.AddClass("Hidden");
        ChatWheel.Highlighted = null;
    } else if (i == null || i != j) {
        if (i != null) {
            ChatWheel.Options[i].RemoveClass("Highlighted");
        }
        ChatWheel.Options[j].AddClass("Highlighted");
        ChatWheel.Arrow.RemoveClass("Hidden");
        ChatWheel.Arrow.style.transform = "rotateZ("+GetSectionAngle(j)+"deg);";

        ChatWheel.Highlighted = j;
    }


    ChatWheel.Scheduled = $.Schedule( interval, UpdateChatWheel );
    return;
}

function GetSectionAngle(i){
    var sectionWidth = 2 * Math.PI / 8;
    return i * sectionWidth * 180 / Math.PI;
}

function GetSection(angle){
    var sectionWidth = 2 * Math.PI / 8;
    angle = angle + (sectionWidth / 2);
    var quotient = Math.floor(angle / sectionWidth);
    if (quotient > 7 || quotient < 0) {
        quotient = 0;
    }
    return quotient;
}

function radius(x, y){
    return Math.sqrt(x*x + y*y);
}

/*
function angle(x, y){

}

function positionX(radius, angle){
    return radius * Math.cos(angle);
}

function positionY(radius, angle){
    return radius * Math.sin(angle);
}
*/

function vectorDifference(v1, v2) {
    var v3 = [];
    for (var i = 0; i < 2; ++i){
        v3[i] = v1[i] - v2[i];
    }
    return v3;
}

function angularDifference(v1, v2) {
    var divisor = vectorMagnitude(v1) * vectorMagnitude(v2);
    if (divisor == 0) {
        return nil;
    } else {
        var sign = Math.sign(crossProduct(v1, v2));
        var mag = Math.acos(dotProduct(v1, v2) / divisor);
        var val = sign * mag;
        if (sign < 0) {
            val = val + 2 * Math.PI;
        }
        return val;
    }
}

function dotProduct(v1, v2) {
    var sum = 0;
    for (var i = 0; i < 2; ++i){
        sum = sum + v1[i] * v2[i];
    }
    return sum;
}

function crossProduct(v1, v2) {
    return v1[0]*v2[1] - v1[1]*v2[0];
}

function vectorMagnitude(v) {
    return radius(v[0], v[1]);
}

function normalize(v) {
    var m = vectorMagnitude(v);
    for (var i = 0; i < 2; ++i){
        v[i] = v[i] / m;
    }
    return v;
}

(function () {
    ChatWheelInitialize();

    Game.AddCommand("+CustomChatWheelButton", OnChatWheelKeyDown, "", 0);
    Game.AddCommand("-CustomChatWheelButton", OnChatWheelKeyUp, "", 0);

    GameUI.SetMouseCallback(OnMouseClickChatWheel);
})();