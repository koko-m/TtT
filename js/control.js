// states of controller

var STATE_IDLE = 0;
var STATE_READY = 1;
var STATE_RUN = 2;
var STATE_PAUSE = 3;

var State = STATE_IDLE;

function getState () { return State; }

function goIdle () {
    addConsole("terminate");
    var prButton = document.getElementById("pauseResumeButton");
    prButton.src = "icons/pause.png";
    prButton.alt = "pause";
    prButton.title = "pause";
    prButton.onclick = new Function("goPause();");
    prButton.disabled = true;
    State = STATE_IDLE;
}

function goReady () { State = STATE_READY; }

function goRun () {
    clearLog();
    var sButton = document.getElementById("startButton");
    if (sButton.alt == "start") {
	addConsole("start");
	blinkButton(sButton,
		    "icons/startOn.png", "icons/restart.png");
    } else {
	addConsole("restart");
	blinkButton(sButton,
		    "icons/restartOn.png", "icons/restart.png");
    }
    sButton.alt = "restart";
    sButton.title = "restart";
    var prButton = document.getElementById("pauseResumeButton");
    prButton.src = "icons/pause.png";
    prButton.alt = "pause";
    prButton.title = "pause";
    prButton.onclick = new Function("goPause();");
    prButton.disabled = false;
    State = STATE_RUN;
}

function goPause () {
    switch (State) {
    case STATE_RUN:
	addConsole("pause");
	var prButton = document.getElementById("pauseResumeButton");
	blinkButton(prButton, "icons/pauseOn.png", "icons/start.png");
	prButton.alt = "resume";
	prButton.title = "resume";
	prButton.onclick = new Function("goResume();");
	State = STATE_PAUSE;
	break;
    default: break;
    }
}

function goResume () {
    switch (State) {
    case STATE_PAUSE:
	addConsole("resume");
	var prButton = document.getElementById("pauseResumeButton");
	blinkButton(prButton, "icons/startOn.png", "icons/pause.png");
	prButton.alt = "pause";
	prButton.title = "pause";
	prButton.onclick = new Function("goPause();");
	State = STATE_RUN;
	break;
    default: break;
    }
}

// blink buttons when clicked

function blinkButton (button, file, nextFile) {
    button.className = "buttonOnImg";
    button.src = file;
    setTimeout(function ()
	       {button.className = "buttonOffImg";
		button.src = nextFile;
	       }, 180);
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

// modes of animation

var MODE_NORMAL = 0;
var MODE_SKIP = 1;
var MODE_FBF = 2;		// frame by frame

var Mode = MODE_NORMAL;

function getMode () { return Mode; }

function goSkip () {
    var skipSwitch = document.getElementById("skipSwitch");
    switch (Mode) {
    case MODE_NORMAL:		// skip mode on
	addConsole("skip mode on");
	skipSwitch.className = "buttonOnImg";
	skipSwitch.src = "icons/skipOn.png";
	Mode = MODE_SKIP;
	break;
    case MODE_SKIP:		// skip mode off
	addConsole("skip mode off");
	skipSwitch.className = "buttonOffImg";
	skipSwitch.src = "icons/skip.png";
	Mode = MODE_NORMAL;
	break;
    case MODE_FBF:		// frame-by-frame mode off
                                // skip mode on
	var fbfSwitch = document.getElementById("FbFSwitch");
	addConsole("frame-by-frame mode off");
	fbfSwitch.className = "buttonOffImg";
	fbfSwitch.src = "icons/fbf.png";
	addConsole("skip mode on");
	skipSwitch.className = "buttonOnImg";
	skipSwitch.src = "icons/skipOn.png";
	Mode = MODE_SKIP;
	break;
    }
}

function goFbF () {
    var fbfSwitch = document.getElementById("FbFSwitch");
    switch (Mode) {
    case MODE_NORMAL:		// frame-by-frame mode on
	addConsole("frame-by-frame mode on");
	fbfSwitch.className = "buttonOnImg";
	fbfSwitch.src = "icons/fbfOn.png";
	Mode = MODE_FBF;
	break;
    case MODE_SKIP:		// skip mode off
                                // frame-by-frame mode on
	var skipSwitch = document.getElementById("skipSwitch");
	addConsole("skip mode off");
	skipSwitch.className = "buttonOffImg";
	skipSwitch.src = "icons/skip.png";
	addConsole("frame-by-frame mode on");
	fbfSwitch.className = "buttonOnImg";
	fbfSwitch.src = "icons/fbfOn.png";
	Mode = MODE_FBF;
	break;
    case MODE_FBF:		// frame-by-frame mode off
	addConsole("frame-by-frame mode off");
	fbfSwitch.className = "buttonOffImg";
	fbfSwitch.src = "icons/fbf.png";
	Mode = MODE_NORMAL;
	break;
    }
}

// clear zoom/move (centering)

var centerFlag = false;

function toCenter () { return centerFlag; }

function centered () { centerFlag = false; }

function center () {
    blinkButton(document.getElementById("centerButton"),
		"icons/centerOn.png", "icons/center.png");
    centerFlag = true;
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
