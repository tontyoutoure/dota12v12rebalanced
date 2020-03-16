GameEvents.Subscribe( "play_sound", function (event) {
    Game.EmitSound( event.sound );
});