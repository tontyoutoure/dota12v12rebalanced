(function () {
    GameEvents.Subscribe( "player_colors_set", OnPlayerColorsSet);
})();

function OnPlayerColorsSet(event) {

    for (var i = 0; i < 24; ++i) {
        var playerId = i;
        var teamId = Players.GetTeam(playerId);

        var hud = $.GetContextPanel().GetParent().GetParent();
        var topbar = hud.FindChild("HUDElements").FindChild("topbar");

        if (teamId == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
            var radiantTopbarContainer = topbar.FindChildTraverse("TopBarRadiantTeamContainer");
            var radiantTopbar = radiantTopbarContainer.FindChild("TopBarRadiantTeam");
            var teamTopbar = radiantTopbar;
            var playerPanel = teamTopbar.FindChildTraverse("RadiantPlayer" + playerId);
            var playerColor = playerPanel.FindChildTraverse("PlayerColor");
            playerColor.style.backgroundColor = GetHexPlayerColor(playerId);
        } else {
            var direTopbarContainer = topbar.FindChildTraverse("TopBarDireTeamContainer");
            var direTopbar = direTopbarContainer.FindChild("TopBarDireTeam");
            var teamTopbar = direTopbar;
            var playerPanel = teamTopbar.FindChildTraverse("DirePlayer" + playerId);
            var playerColor = playerPanel.FindChildTraverse("PlayerColor");
            playerColor.style.backgroundColor = GetHexPlayerColor(playerId);
        }
    }

}

function GetHexPlayerColor(playerId) {
    var playerColor = Players.GetPlayerColor(playerId).toString(16);
    // $.Msg(playerId);
    // $.Msg(Players.GetPlayerColor(playerId).toString(10));
	return playerColor == null ? '#000000' : ('#' + playerColor.substring(6, 8) + playerColor.substring(4, 6) + playerColor.substring(2, 4) + playerColor.substring(0, 2));
}