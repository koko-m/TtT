var parser = PEG.buildParser(grammar);

var parsedTerm = undefined;
var parsed = false;

function isParsed () { return parsed; }
function getParsedTerm () { return parsedTerm; }
function setParsedTerm () {
    parsedTerm = parser.parse(document.getElementById("term").value);
    parsed = true;
};
