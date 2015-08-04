// states of controller
var STATE_IDLE = 0;
var STATE_READY = 1;
var STATE_RUN = 2;
var STATE_PAUSE = 3;

var State = STATE_IDLE;

function getState () { return State; }

function goIdle () { addLog("terminate"); State = STATE_IDLE; }
function goReady () { State = STATE_READY; }
function goRun () { addLog("run"); State = STATE_RUN; }
function goPause () { addLog("pause"); State = STATE_PAUSE; }
function goResume () { addLog("resume"); State = STATE_RUN; }

function startClicked () {
    switch (State) {
    case STATE_PAUSE:
	var button = document.getElementById("startStopButton");
	button.value = "stop";
	button.onclick = new Function("stopClicked();");
	goRun();
	break;
    default: break;
    }
}

function stopClicked () {
    switch (State) {
    case STATE_RUN: case STATE_PAUSE:
	var button = document.getElementById("startStopButton");
	button.value = "start";
	button.onclick = new Function("startClicked();");
	addLog("terminate");
	goReady();
	break;
    default: break;
    }
}

function pauseClicked () {
    switch (State) {
    case STATE_RUN:
	var button = document.getElementById("pauseResumeButton");
	button.value = "resume";
	button.onclick = new Function("resumeClicked();");
	goPause();
	break;
    default: break;
    }
}

function resumeClicked () {
    switch (State) {
    case STATE_PAUSE:
	var button = document.getElementById("pauseResumeButton");
	button.value = "pause";
	button.onclick = new Function("pauseClicked();");
	goResume();
	break;
    default: break;
    }
}
