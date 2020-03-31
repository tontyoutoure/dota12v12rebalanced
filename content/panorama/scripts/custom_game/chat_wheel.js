
var ChatWheel = {};

function ChatWheelInitialize(){
    ChatWheel.Hud = $.GetContextPanel();
    ChatWheel.Arrow = ChatWheel.Hud.FindChildTraverse("ArrowContainer");
    ChatWheel.Circle = ChatWheel.Hud.FindChildTraverse("Circle");
    ChatWheel.Options = [];
    for (var i = 1; i <= 8; ++i) {
        ChatWheel.Options[i] = ChatWheel.Hud.FindChildTraverse("ChatOption" + i);
    }
}

function UpdateChatWheel(){


    $.Schedule( 0.1, UpdateChatWheel );
}

(function () {
    ChatWheelInitialize();

    // ChatWheel.Hud.style.visibility = 'collapse';
    ChatWheel.Arrow.RemoveClass("Hidden");
    ChatWheel.Options[1].AddClass("Highlighted");
})();