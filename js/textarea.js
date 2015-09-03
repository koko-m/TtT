function clearLog () {
    var logArea = document.getElementById("logArea");
    logArea.value = "";
}

function addLog (txt) {
    var logArea = document.getElementById("logArea");
    logArea.value = txt + "\n" + logArea.value;
}

function clearConsole () {
    // var consoleArea = document.getElementById("consoleArea");
    // consoleArea.value = "";
}

function addConsole (txt) {
    // var consoleArea = document.getElementById("consoleArea");
    // consoleArea.value = txt + "\n" + consoleArea.value;
}
