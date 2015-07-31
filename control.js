// states of controller
var STATE_IDLE = 0;
var STATE_READY = 1;
var STATE_RUN = 2;
var STATE_PAUSE = 3;

var State = STATE_IDLE;

function getState () { return State; }

function goIdle () { State = STATE_IDLE; }
function goReady () { State = STATE_READY; }
function goRun () { addLog("run"); State = STATE_RUN; }
function goPause () { addLog("pause"); State = STATE_PAUSE; }
function goResume () { addLog("resume"); State = STATE_RUN; }
