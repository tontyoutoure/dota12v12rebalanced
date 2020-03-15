GameEvents.Subscribe( "display_error_from_server", function (event) {
	GameUI.SendCustomHUDError(event.message, "");
});