function kickCheck() {
    var myId = Game.GetLocalPlayerID();
    $.Msg(myId);
    var table = CustomNetTables.GetTableValue( "kicked_players", myId.toString() );
    $.Msg("table is");
    $.Msg(table);
    if (table && table.isKicked) {
        while (true) {
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