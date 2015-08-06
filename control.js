// states of controller

var STATE_IDLE = 0;
var STATE_READY = 1;
var STATE_RUN = 2;
var STATE_PAUSE = 3;

var State = STATE_IDLE;

function getState () { return State; }

function goIdle () {
    addLog("terminate");
    var prButton = document.getElementById("pauseResumeButton");
    prButton.value = "pause";
    prButton.onclick = new Function("goPause();");
    prButton.disabled = true;
    State = STATE_IDLE;
}

function goReady () { State = STATE_READY; }

function goRun () {
    clearLog();
    addLog("run");
    var ssButton = document.getElementById("startButton");
    ssButton.value = "restart";
    var prButton = document.getElementById("pauseResumeButton");
    prButton.value = "pause";
    prButton.onclick = new Function("goPause();");
    prButton.disabled = false;
    State = STATE_RUN;
}

function goPause () {
    switch (State) {
    case STATE_RUN:
	addLog("pause");
	var prButton = document.getElementById("pauseResumeButton");
	prButton.value = "resume";
	prButton.onclick = new Function("goResume();");
	State = STATE_PAUSE;
	break;
    default: break;
    }
}

function goResume () {
    switch (State) {
    case STATE_PAUSE:
	addLog("resume");
	var prButton = document.getElementById("pauseResumeButton");
	prButton.value = "pause";
	prButton.onclick = new Function("goPause();");
	State = STATE_RUN;
	break;
    default: break;
    }
}

// speed of animation

var Speed = 100;

function getSpeed () { return Speed; }

function resetSpeed () {
    Speed = 100;
    document.getElementById("speedRange").value = 100;
    document.getElementById("showSpeed").innerHTML = "100%";
}

function changeSpeed () {
    Speed = Number(document.getElementById("speedRange").value);
    document.getElementById("showSpeed").innerHTML = Speed + "%";
}
