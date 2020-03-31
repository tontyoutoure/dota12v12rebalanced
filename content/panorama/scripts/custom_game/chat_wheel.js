
var ChatWheel = {};

function ChatWheelInitialize(){
    ChatWheel.Hud = $.GetContextPanel();
    ChatWheel.Arrow = ChatWheel.Hud.FindChildTraverse("ArrowContainer");
    ChatWheel.Circle = ChatWheel.Hud.FindChildTraverse("Circle");
    ChatWheel.Options = [];
    for (var i = 0; i <= 7; ++i) {
        ChatWheel.Options[i] = ChatWheel.Hud.FindChildTraverse("ChatOption" + i);
    }
    ChatWheel.Highlighted = 0;
}

function UpdateChatWheel(){
    var interval = 1/60;

    var W = ChatWheel.Hud.actuallayoutwidth;
    var H = ChatWheel.Hud.actuallayoutheight;
    var radialThreshold = 0.04 * H;
    var origin = [W/2, H/2];
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


    $.Schedule( interval, UpdateChatWheel );
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

    // ChatWheel.Hud.style.visibility = 'collapse';

    UpdateChatWheel();
})();