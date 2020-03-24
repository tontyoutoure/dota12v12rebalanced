(function () {
    GameEvents.Subscribe( "player_color_set", OnPlayerColorSet);
})();

function OnPlayerColorSet(event) {
    // event.playerId
    // event.team

    var hud = $.GetContextPanel().GetParent().GetParent();
    var topbar = hud.FindChild("HUDElements").FindChild("topbar");

    var teamTopbar = null;
    if (event.team == "Radiant") {
        var radiantTopbarContainer = topbar.FindChildTraverse("TopBarRadiantTeamContainer");
        var radiantTopbar = radiantTopbarContainer.FindChild("TopBarRadiantTeam");
        teamTopbar = radiantTopbar;
    } else {
        var direTopbarContainer = topbar.FindChildTraverse("TopBarDireTeamContainer");
        var direTopbar = direTopbarContainer.FindChild("TopBarDireTeam");
        teamTopbar = direTopbar;
    }

    // $.Msg(event.team + "Player" + event.playerId);
    var playerPanel = teamTopbar.FindChildTraverse(event.team + "Player" + event.playerId);
    var playerColor = playerPanel.FindChildTraverse("PlayerColor");
    playerColor.style.backgroundColor = GetHexPlayerColor(event.playerId);

}

function GetHexPlayerColor(playerId) {
	var playerColor = Players.GetPlayerColor(playerId).toString(16);
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}