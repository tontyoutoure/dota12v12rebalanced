function kickCheck( event ) {
    // $.Msg(event.kicked);
    var myId = Game.GetLocalPlayerID();
    var i = 1;
    if (event.kicked) {
        // GameUI.SendCustomHUDError("KICK CHECK: YOU HAVE BEEN KICKED.", "");
        while (0 < i) {
            $.Msg("YOU ARE KICKED!");
            i = i + 1;
        }
    } else {
        // GameUI.SendCustomHUDError("KICK CHECK: YOU HAVE NOT BEEN KICKED.", "");
        // $.Msg("YOU ARE NOT KICKED!");
    }
}

(function(){
    GameEvents.Subscribe("kick_check", kickCheck);
    GameEvents.SendCustomGameEventToServer("trigger_kick_check", {playerId: Game.GetLocalPlayerID()});
})();