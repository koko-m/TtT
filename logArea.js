function setLogAreaSize () {
    var logArea = document.getElementById("logArea");
    logArea.style.width = getLogAreaWidth() + "px";
    logArea.style.height = getLogAreaHeight() + "px";
}

function clearLog () {
    logArea.value = "";
}

function addLog (txt) {
    logArea.value = txt + "\n" + logArea.value;
}
