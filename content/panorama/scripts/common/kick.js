function kickCheck() {
    var myId = Game.GetLocalPlayerID();
    var table = CustomNetTables.GetTableValue( "kicked_players", myId.toString() );
    if (table && table.isKicked) {
        // GameUI.SendCustomHUDError("KICK CHECK: YOU HAVE BEEN KICKED.", "");
        while (true) {
            $.Msg("YOU ARE KICKED!");
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