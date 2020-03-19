"use strict";

var g_ScoreboardHandle = null;

function SetFlyoutScoreboardVisible( bVisible )
{
	// var x = "Hero_Axe.Culling_Blade_Fail";
	var y = "Hero_Zuus.GodsWrath.PreCast";
	// var x = "ui.report_negative";
	// $.Msg("emitting: " + y);
	// var h = Game.EmitSound(y);
	$.GetContextPanel().SetHasClass( "flyout_scoreboard_visible", bVisible );
	if ( bVisible )
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, true );
	}
	else
	{
		ScoreboardUpdater_SetScoreboardActive( g_ScoreboardHandle, false );
	}
}

(function()
{
	if ( ScoreboardUpdater_InitializeScoreboard === null ) { $.Msg( "WARNING: This file requires shared_scoreboard_updater.js to be included." ); }

	var scoreboardConfig =
	{
		"teamXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_team.xml",
		"playerXmlName" : "file://{resources}/layout/custom_game/multiteam_flyout_scoreboard_player.xml",
	};
	g_ScoreboardHandle = ScoreboardUpdater_InitializeScoreboard( scoreboardConfig, $( "#TeamsContainer" ) );
	
	SetFlyoutScoreboardVisible( false );
	
	$.RegisterEventHandler( "DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible );
})();
