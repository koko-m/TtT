function setLogAreaSize () {
    var logArea = document.getElementById("logArea");
    logArea.style.width = getLogAreaWidth() + "px";
    logArea.style.height = getLogAreaHeight() + "px";
}

function clearLog () {
    var logArea = document.getElementById("logArea");
    logArea.value = "";
}

function addLog (txt) {
    var logArea = document.getElementById("logArea");
    logArea.value = txt + "\n" + logArea.value;
}

function changeColor () {
    var logArea = document.getElementById("logArea");
    logArea.style.color = "#ae4f55";
}

function resetColor () {
    var logArea = document.getElementById("logArea");
    logArea.style.color = "#292d24";
}
