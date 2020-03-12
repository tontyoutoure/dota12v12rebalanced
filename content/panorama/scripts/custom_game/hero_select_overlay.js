"use strict";

(function() {
	// Create Layout
	createLayout();

	// Set Hero Selection Callbacks
	OnUpdateHeroSelection();
	GameEvents.Subscribe( "dota_player_hero_selection_dirty", OnUpdateHeroSelection );
	GameEvents.Subscribe( "dota_player_update_hero_selection", OnUpdateHeroSelection );

	// Update Clock
	UpdateTimer();
})();

function createLayout() {
	var localPlayerTeamId = Game.GetLocalPlayerInfo().player_team_id;
	var teamsContainer = $("#HeroSelectTeamsContainer");
	$.CreatePanel( "Panel", teamsContainer, "EndSpacer" );
	
	var teamIds = Game.GetAllTeamIDs();
	if (teamIds.length < 1) {
		createEmptyTeamPanel(0, teamsContainer);
		createTimerPanel(teamsContainer);
		createEmptyTeamPanel(0);
	} else if (teamIds.length < 2) {
		createTeamPanel(teamIds[0], teamsContainer, localPlayerTeamId);
		createTimerPanel(teamsContainer);
		createEmptyTeamPanel(0, teamsContainer);
	} else if (teamIds.length < 3) {
		createTeamPanel(teamIds[0], teamsContainer, localPlayerTeamId);
		createTimerPanel(teamsContainer);
		createTeamPanel(teamIds[1], teamsContainer, localPlayerTeamId);
	} else {
		$.Msg("Error: Number of Team IDs exceeds 2.");
	}
	
	$.CreatePanel( "Panel", teamsContainer, "EndSpacer" );
}

function createTimerPanel (teamsContainer) {
	var timerPanel = $.CreatePanel( "Panel", teamsContainer, "TimerPanel" );
	timerPanel.BLoadLayout( "file://{resources}/layout/custom_game/hero_select_overlay_timer.xml", false, false );
};

function createEmptyTeamPanel (teamId, teamsContainer) {
	var teamPanelName = "team_" + teamId;
	var teamPanel = $.CreatePanel( "Panel", teamsContainer, teamPanelName );
	teamPanel.BLoadLayout( "file://{resources}/layout/custom_game/hero_select_overlay_team.xml", false, false );
	return teamPanel
}

function createTeamPanel (teamId, teamsContainer, localPlayerTeamId) {
	var teamPanelName = "team_" + teamId;
	var teamPanel = $.CreatePanel( "Panel", teamsContainer, teamPanelName );
	teamPanel.BLoadLayout( "file://{resources}/layout/custom_game/hero_select_overlay_team.xml", false, false );

	var teamName = teamPanel.FindChildInLayoutFile( "TeamName" );
	if ( teamName )
	{
		teamName.text = $.Localize( Game.GetTeamDetails( teamId ).team_name );
	}

	var logo_xml = GameUI.CustomUIConfig().team_logo_xml;

	if ( logo_xml )
	{
		var teamLogoPanel = teamPanel.FindChildInLayoutFile( "TeamLogo" );
		teamLogoPanel.SetAttributeInt( "team_id", teamId );
		teamLogoPanel.BLoadLayout( logo_xml, false, false );
	}
	
	var teamGradient = teamPanel.FindChildInLayoutFile( "TeamGradient" );
	if ( teamGradient && GameUI.CustomUIConfig().team_colors )
	{
		var teamColor = GameUI.CustomUIConfig().team_colors[ teamId ];
		teamColor = teamColor.replace( ";", "" );
		var gradientText = 'gradient( linear, 0% 0%, 0% 100%, from( #00000000 ), to( ' + teamColor + '40 ) );';
		teamGradient.style.backgroundColor = gradientText;
	}

	if ( teamName )
	{
		teamName.text = $.Localize( Game.GetTeamDetails( teamId ).team_name );
	}
	teamPanel.AddClass( "TeamPanel" );

	if ( teamId === localPlayerTeamId )
	{
		teamPanel.AddClass( "local_player_team" );
	}
	else
	{
		teamPanel.AddClass( "not_local_player_team" );
	}
};

function OnUpdateHeroSelection()
{
	for ( var teamId of Game.GetAllTeamIDs() )
	{
		UpdateTeam( teamId );
	}
}

function UpdateTeam( teamId )
{
	var teamPanelName = "team_" + teamId;
	var teamPanel = $( "#"+teamPanelName );
	var teamPlayers = Game.GetPlayerIDsOnTeam( teamId );
	teamPanel.SetHasClass( "no_players", ( teamPlayers.length == 0 ) );
	teamPanel.SetHasClass( "many_players", ( teamPlayers.length > 5 ) );
	for ( var playerId of teamPlayers )
	{
		UpdatePlayer( teamPanel, playerId );
	}
}

function UpdatePlayer( teamPanel, playerId )
{
	var playerContainer = teamPanel.FindChildInLayoutFile( "PlayersContainer" );
	var playerPanelName = "player_" + playerId;
	var playerPanel = playerContainer.FindChild( playerPanelName );
	if ( playerPanel === null )
	{
		playerPanel = $.CreatePanel( "Image", playerContainer, playerPanelName );
		playerPanel.BLoadLayout( "file://{resources}/layout/custom_game/hero_select_overlay_player.xml", false, false );
		playerPanel.AddClass( "PlayerPanel" );
	}

	var playerInfo = Game.GetPlayerInfo( playerId );
	if ( !playerInfo )
		return;

	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( !localPlayerInfo )
		return;

	var localPlayerTeamId = localPlayerInfo.player_team_id;
	var playerPortrait = playerPanel.FindChildInLayoutFile( "PlayerPortrait" );
	
	if ( playerId == localPlayerInfo.player_id )
	{
		playerPanel.AddClass( "is_local_player" );
	}

	if ( playerInfo.player_selected_hero !== "" )
	{
		playerPortrait.SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
		playerPanel.SetHasClass( "hero_selected", true );
		playerPanel.SetHasClass( "hero_highlighted", false );
	}
	else if ( playerInfo.possible_hero_selection !== "" && ( playerInfo.player_team_id == localPlayerTeamId ) )
	{
		playerPortrait.SetImage( "file://{images}/heroes/npc_dota_hero_" + playerInfo.possible_hero_selection + ".png" );
		playerPanel.SetHasClass( "hero_selected", false );
		playerPanel.SetHasClass( "hero_highlighted", true );
	}
	else
	{
		playerPortrait.SetImage( "file://{images}/custom_game/unassigned.png" );
	}

	var playerName = playerPanel.FindChildInLayoutFile( "PlayerName" );
	playerName.text = playerInfo.player_name;

	playerPanel.SetHasClass( "is_local_player", ( playerId == Game.GetLocalPlayerID() ) );
}

function UpdateTimer()
{
	var gameTime = Game.GetGameTime();
	var transitionTime = Game.GetStateTransitionTime();

	var timerValue = Math.max( 0, Math.floor( transitionTime - gameTime ) );
	
	if ( Game.GameStateIsAfter( DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION ) )
	{
		timerValue = 0;
	}
	var timerPanel = $("#TimerPanel");
	if (timerPanel) {
		timerPanel.SetDialogVariableInt( "timer_seconds", timerValue );
	}
	// $("#TimerPanel").SetDialogVariableInt( "timer_seconds", timerValue );

	$.Schedule( 0.1, UpdateTimer );
}

