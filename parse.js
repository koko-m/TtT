var parser = PEG.buildParser(grammar);

var term = undefined;
var termReady = false;

function isTermReady () { return termReady; }
function termProcessed () { termReady = false; }

function getTerm () { return term; }
function setTerm () {
    try {
	var errMsg = document.getElementById("errMsg");
	errMsg.textContent = null;
	term =
	    collectFreeVars(
		eliminateTermSum(
		    parser.parse(
			document.getElementById("term").value)));
	termReady = true;
    } catch (err) {
	switch (err.name) {
	case "SyntaxError":
	    errMsg.textContent =
		err.name + " at (" + err.line + "," + err.column + "): "
		+ err.message;
	    break;
	case "Error":
	    errMsg.textContent = err.name + ": " + err.message;
	    break;
	}
    }
}

var count = 0;

function eliminateTermSum (parsedTerm) {
    if (parsedTerm.tag == "+") {
	if (isEqual(parsedTerm.bodies[0], parsedTerm.bodies[1])) {
	    var newVar = "C" + count;
	    count++;
	    var varSumFunc =
		new Term("lambda", [newVar],
			 [new Term("+1", [newVar], [])]);
	    parsedTerm =
		new Term("app", [],
			 [varSumFunc,
			  eliminateTermSum(parsedTerm.bodies[0])]);
	} else {
	    var newVarLeft = "L" + count;
	    count++;
	    var newVarRight = "R" + count;
	    count++;
	    var varSumFunc =
		new Term("lambda", [newVarLeft],
			 [new Term("lambda", [newVarRight],
				   [new Term("+2",
					     [newVarLeft,
					      newVarRight], [])])]);
	    parsedTerm =
		new Term("app", [],
			 [new Term("app", [],
				   [varSumFunc,
				    eliminateTermSum
				    (parsedTerm.bodies[0])]),
			  eliminateTermSum(parsedTerm.bodies[1])]);
	}
    } else {
	for (var i = 0; i < parsedTerm.bodies.length; i++) {
	    parsedTerm.bodies[i] =
		eliminateTermSum(parsedTerm.bodies[i]);
	}
    }
    return parsedTerm;
}

function collectFreeVars (parsedTerm) {
    switch (parsedTerm.tag) {
    case "var":
	var varIt = parsedTerm.parameters[0];
	var index = -1;
	for (var i = 0; i < parsedTerm.freeVars.length; i++) {
	    if (parsedTerm.freeVars[i] == varIt)
		index = i;	// take the last one
	}
	if (index < 0)
	    throw new Error("unknown variable \"" + varIt + "\"");
	else parsedTerm.parameters[0] = index;
	break;
    case "lambda": case "rec":
	parsedTerm.bodies[0].freeVars =
	    parsedTerm.freeVars.concat(parsedTerm.parameters);
	parsedTerm.bodies[0] = collectFreeVars(parsedTerm.bodies[0]);
	break;
    case "match":
	parsedTerm.bodies[0].freeVars = parsedTerm.freeVars;
	parsedTerm.bodies[0] = collectFreeVars(parsedTerm.bodies[0]);
	for (var i = 0; i <= 1; i++) {
	    parsedTerm.bodies[i + 1].freeVars =
		parsedTerm.freeVars.concat(parsedTerm.parameters[i]);
	    parsedTerm.bodies[i + 1] =
		collectFreeVars(parsedTerm.bodies[i + 1]);
	}
	break;
    default:
	for (var i = 0; i < parsedTerm.bodies.length; i++) {
	    parsedTerm.bodies[i].freeVars = parsedTerm.freeVars;
	    parsedTerm.bodies[i] =
		collectFreeVars(parsedTerm.bodies[i]);
	}
	break;
    }
    return parsedTerm;
}
