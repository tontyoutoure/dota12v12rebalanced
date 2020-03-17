function kickCheck() {
    var myId = Game.GetLocalPlayerID();
    var table = CustomNetTables.GetTableValue( "kicked_players", myId.toString() );
    if (table && table.isKicked) {
        $.Msg("YOU ARE KICKED! D:");
        GameUI.SendCustomHUDError("TESTING: YOU HAVE BEEN KICKED.", "");
        while (false) {
            $.Msg("YOU ARE KICKED! D:");
        }
    } else {
        GameUI.SendCustomHUDError("TESTING: YOU HAVE NOT BEEN KICKED.", "");
            $.Msg("YOU ARE NOT KICKED!");
    }
}

(function(){
    GameEvents.Subscribe("kick_check", kickCheck);
    GameEvents.SendCustomGameEventToServer("trigger_kick_check", {playerId: Game.GetLocalPlayerID()});
})();