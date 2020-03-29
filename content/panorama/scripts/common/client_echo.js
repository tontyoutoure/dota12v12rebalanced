GameEvents.Subscribe( "echo", function (event) {
    $.Msg("Echoing server...");
    GameEvents.SendCustomGameEventToServer( event.name, event.data );
});