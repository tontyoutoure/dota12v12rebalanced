// Should be run only once
function registerVoteListeners() {
    $.Msg("Registering Vote Event Listeners...");
    GameEvents.Subscribe("request_votes", handleVoteRequest);
    GameEvents.Subscribe("end_voting", endVoteDialog);
    // GameEvents.Subscribe("update_votes", updateVoteDialog);
}

// button callback that emits "vote"
function onVote( yesButton, noButton, voteOptions, subjectId, vote ) {
    // TODO disable buttons
    var voteHud = $.GetContextPanel();
    voteHud.AddClass("Transparent");
    yesButton.enabled = false;
    noButton.enabled = false;
    if (vote == voteOptions.YES) {
        Game.EmitSound("Custom_Game.Vote_Kick.Yes"); // vote yes
    } else if (vote == voteOptions.NO) {
        Game.EmitSound("Custom_Game.Vote_Kick.No"); // vote no
    }
    GameEvents.SendCustomGameEventToServer("vote_submitted", {voterId: Game.GetLocalPlayerID(), subjectId: subjectId, vote: vote});
}


// event callback that handles "request_votes"
function handleVoteRequest ( event ) {

    /*
    local event = {
        playerId = playerId,
        subjectId = subjectId,
        subjectSteamId = subjectSteamId,
        subjectHero = subjectHero,
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

    var timeOutBar = voteHud.FindChildTraverse("TimeoutBar"); 
    // timeOutBar.AddClass("Shrink");

    // set timeOut animation
    timeOutBar.style.transitionDuration = "0s";
    timeOutBar.style.width = "100%";
    timeOutBar.style.transitionDuration = event.timeOut.toString() + "s";
    timeOutBar.style.width = "0%";

    // setIntervalUntil(UpdateTimeOutBar, 0.1, event.timeOut); 

    // set player info
    var steamIdElement = voteHud.FindChildTraverse("SteamId");
    steamIdElement.text = event.subjectName;
    var heroElement = voteHud.FindChildTraverse("HeroIcon");
    heroElement.heroname = event.subjectHero;

    // hook up buttons
    var yesButton = voteHud.FindChildTraverse("YesButton");
    var noButton = voteHud.FindChildTraverse("NoButton");
    yesButton.SetPanelEvent("onactivate", function () {
        onVote(yesButton, noButton, event.voteOptions, event.subjectId, event.voteOptions.YES);
    });

    noButton.SetPanelEvent("onactivate", function () {
        onVote(yesButton, noButton, event.voteOptions, event.subjectId, event.voteOptions.NO)
    });

    var localPlayerId = Game.GetLocalPlayerID();
    if (localPlayerId != event.playerId && localPlayerId != event.subjectId) {
        voteHud.RemoveClass("Transparent");
        yesButton.enabled = true;
        noButton.enabled = true;
    } else {
        voteHud.AddClass("Transparent");
        yesButton.enabled = false;
        noButton.enabled = false;
    }


    // GameUI.SendCustomHUDError("Vote requested.", "");

    // render
    voteHud.AddClass("SlideIn");
    Game.EmitSound("ui.ready_check.popup"); // vote begins
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
    // GameUI.SendCustomHUDError("Voting ended.", "");
}


// event callback that handles "update_vote"
function updateVoteDialog ( event ) {
    /*
        event.numVoters
        event.numVotes
        event.numYes
        event.votes // who voted what
    */
   
    $.Msg("VOTE RECIEVED BY SERVER");
    // GameUI.SendCustomHUDError(event.numYes.toString() + "/" + event.numVotes.toString() + "voted yes.", "");
}
