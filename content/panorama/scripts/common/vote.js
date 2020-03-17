// Should be run only once
function registerVoteListeners() {
    $.Msg("Registering Vote Event Listeners...");
    GameEvents.Subscribe("request_votes", handleVoteRequest);
    GameEvents.Subscribe("end_voting", endVoteDialog);
    GameEvents.Subscribe("update_vote", updateVoteDialog);
}

// button callback that emits "vote"
function onVote() {

}

// Game.EmitSound("ui.click_alt"); // vote yes
// Game.EmitSound("ui.click_back"); // vote no

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


    var voteHud = $.GetContextPanel();
    // $.Msg(voteHud);
    voteHud.AddClass("SlideIn");
    Game.EmitSound("ui.ready_check.popup"); // vote begins

    var timeOut = CustomNetTables.GetTableValue("vote", "settings").timeOut;

    var timeOutBar = voteHud.FindChildTraverse("TimeoutBar"); 
    // timeOutBar.AddClass("Shrink");

    timeOutBar.style.transitionDuration = "0s";
    timeOutBar.style.width = "100%";
    timeOutBar.style.transitionDuration = timeOut.toString() + "s";
    timeOutBar.style.width = "0%";

    // setIntervalUntil(UpdateTimeOutBar, 0.1, timeOut); // TODO use time set on server


    GameUI.SendCustomHUDError("Vote requested.", "");
}


/*
// dont use, lags client
function UpdateTimeOutBar(curr, init) {
    var voteHud = $.GetContextPanel();
    // get timeoutbar
    // set width
    $.Msg(voteHud.FindChildTraverse("TimeoutBar"));
    var timeOutBar = voteHud.FindChildTraverse("TimeoutBar"); 
    timeOutBar.style.width = ((curr/init) * 100).toString() + "%";
}
*/


// event callback that handles "end_voting"
function endVoteDialog ( event ) {
    // event.subjectId
    var voteHud = $.GetContextPanel();
    voteHud.RemoveClass("SlideIn");
    GameUI.SendCustomHUDError("Voting ended.", "");
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
