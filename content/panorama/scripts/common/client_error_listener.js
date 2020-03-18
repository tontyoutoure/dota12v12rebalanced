GameEvents.Subscribe( "display_error_from_server", function (event) {
	GameUI.SendCustomHUDError(event.message, "");
	$.Msg("Error: " + event.message);
});

// GameEvents.Subscribe("display_chat_error", function(event) {
// 	GameEvents.SendEventClientSide("dota_hud_error_message", {
// 		splitscreenplayer: 0,
// 		reason: 80,
// 		message: event.message
// 	});
// });