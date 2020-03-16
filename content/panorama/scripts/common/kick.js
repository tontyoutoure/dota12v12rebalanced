function kickCheck() {
    var myId = Game.GetLocalPlayerID();
    var table = CustomNetTables.GetTableValue( "kicked_players", myId.toString() );
    if (table && table.isKicked) {
        $.Msg("YOU ARE KICKED! D:");
        while (false) {
            $.Msg("YOU ARE KICKED! D:");
        }
    } else {
        $.Msg("YOU ARE NOT KICKED! :D");
    }
}

(function(){
    GameEvents.Subscribe("kick_check", kickCheck);
    GameEvents.SendCustomGameEventToServer("trigger_kick_check", {playerId: Game.GetLocalPlayerID()});
})();