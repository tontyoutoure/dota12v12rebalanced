// button callback that emits "begin_voting"
function onBeginVotingButtonClicked() {
    // get player ID and target player ID
    var playerId = Game.GetLocalPlayerID();
    var subjectId = $.GetContextPanel().GetAttributeInt( "player_id", -1 );

    if ( playerId !== -1 ) {
        GameEvents.SendCustomGameEventToServer("begin_voting", {playerId: playerId, subjectId: subjectId});
    } else {
        $.Msg("Vote Button Failed!");
        GameUI.SendCustomHUDError("Vote.js: Vote button failed.", "");
    }
}


// button callback that emits "vote"
function onVote() {

}

// event callback that handles "request_votes"
function handleVoteRequest ( event ) {

    /*
    local event = {
        playerId = playerId,
        subjectId = subjectId,
        voteOptions = VOTE_OPTIONS
    };
    */
    // display "aleady voted" dialog for playerId
        // need to keep reference to destroy
    // display "vote in progress" dialog for subjectId
        // need to keep reference to destroy
    // display vote dialog for other players on team
        // need callback for vote button
        // need to keep reference
    $.Msg("HEEEEEEEELLLLLLLLLLLOOOOOOOOOOOO");
    $.Msg("HEEEEEEEELLLLLLLLLLLOOOOOOOOOOOO");
    $.Msg("HEEEEEEEELLLLLLLLLLLOOOOOOOOOOOO");
    $.Msg("HEEEEEEEELLLLLLLLLLLOOOOOOOOOOOO");
    $.Msg($("#VoteContainer"));

    var votePanel = $.CreatePanel("Panel", $("#VoteContainer"), "")
    votePanel.BLoadLayoutSnippet("VoteSnippet");

    GameUI.SendCustomHUDError("vote requested", "");
}


// event callback that handles "end_voting"
function endVoteDialog ( event ) {
    // event.subjectId
    GameUI.SendCustomHUDError("voting ended", "");
}


// event callback that handles "update_vote"
function updateVoteDialog ( event ) {
    /*
        event.numVoters
        event.numVotes
        event.numYes
        event.votes
    */
    GameUI.SendCustomHUDError("voting updated", "");
}


// initialize by registering callbacks
(function () {
    GameEvents.Subscribe("request_votes", handleVoteRequest);
    GameEvents.Subscribe("end_voting", endVoteDialog);
    GameEvents.Subscribe("update_vote", updateVoteDialog);
})();