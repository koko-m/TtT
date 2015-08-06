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
    document.getElementById("speedNum").value = 100;
}

function changeSpeedR () {
    Speed = Number(document.getElementById("speedRange").value);
    document.getElementById("speedNum").value = Speed;
}

function changeSpeedN () {
    Speed = Number(document.getElementById("speedNum").value);
    document.getElementById("speedRange").value = Speed;
}

// size of the canvas (see style.css)

function getCanvasWidth () {
    return document.getElementById("head").clientWidth;
}
function getCanvasHeight () {
    var bodyHeight = document.body.clientHeight;
    // head has no margin but paddings outside
    var headHeight = document.getElementById("head").clientHeight;
    var headPaddingTop = parseInt
    (window.getComputedStyle(document.getElementById("head"),
			     null).paddingTop);
    var headPaddingBottom = parseInt
    (window.getComputedStyle(document.getElementById("head"),
			     null).paddingBottom);
    // topBlock has margins
    var topBlockHeight =
	document.getElementById("topBlock").clientHeight;
    var topBlockMarginTop = parseInt
    (window.getComputedStyle(document.getElementById("topBlock"),
			     null).marginTop);
    var topBlockMarginBottom = parseInt
    (window.getComputedStyle(document.getElementById("topBlock"),
			     null).marginBottom);
    // bottomBlock has margin-top only
    var bottomBlockHeight =
	document.getElementById("bottomBlock").clientHeight;
    var bottomBlockMarginTop = parseInt
    (window.getComputedStyle(document.getElementById("bottomBlock"),
			     null).marginTop);
    return bodyHeight
	- headPaddingTop
	- headHeight - headPaddingBottom
	- topBlockMarginTop
	- topBlockHeight - topBlockMarginBottom
	- bottomBlockMarginTop
	- bottomBlockHeight;
}
