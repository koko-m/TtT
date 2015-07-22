/* term constructor */

function Term (tag, parameters, bodies) {
    this.tag = tag;
    this.parameters = parameters;
    this.bodies = bodies;
    this.freeVars = [];
}
Term.prototype.print = function () {
    var str = "(" + this.tag + " " + this.parameters;
    for (var i = 0; i < this.bodies.length; i++) {
	str += " " + this.bodies[i].print();
    }
    return  str + " [" + this.freeVars + "])";
}
Term.prototype.prettyPrint = function () {
    switch (this.tag) {
    case "var": return this.freeVars[this.parameters[0]]; break;
    case "nat": return this.parameters[0]; break;
    case "unit": return "*"; break;
    case "match":
	return "(match " + this.bodies[0].prettyPrint()
	    + " ((inl " + this.parameters[0] + ") "
	    + this.bodies[1].prettyPrint() + ")"
	    + " ((inr " + this.parameters[1] + ") "
	    + this.bodies[2].prettyPrint() + "))";
	break;
    case "app":
	return "("
	    + this.bodies.map(function(t){return t.prettyPrint();})
	    .join(" ")
	    + ")";
	break;
    default:
	if (this.parameters.length == 0) {
	    return "(" + this.tag.toLowerCase() + " "
		+ this.bodies.map(function(t){
		    return t.prettyPrint();
		}).join(" ")
		+ ")";
	    break;
	} else {
	    return "(" + this.tag.toLowerCase() + "("
		+ this.parameters.join(" ") + ")"
		+ this.bodies.map(function(t){
		    return t.prettyPrint();
		}).join(" ")
		+ ")";
	    break;
	}
    }
}

/* PEG Rules */

var rules = [
    "start = expr",
    // spaces
    "spS = ' '*",
    "spP = ' '+",
    // terms (expressions)
    "expr = base / composed",
    "base = var / const",
    "composed =  lambda / rec / choose",
    "         / car / cdr / cons",
    "         / inl / inr / match / sum",
    "         / app",
    // variables & constants
    "varRaw = [a-z/A-Z]+ {return text();}",
    "var = str:varRaw {return new Term('var', [str], []);}",
    "const = '*' {return new Term('unit', ['*'], []);}",
    "      / [0-9]+",
    "        {return new Term('nat', [parseInt(text(), 10)], []);}",
    // functions
    "lambda = '(' spS 'lambda' spS '(' spS bvar:varRaw spS ')' spS",
    "      body:expr spS ')'",	// one bounded variable only
    "      {return new Term('lambda', [bvar], [body]);}",
    "rec = '(' spS 'rec' spS '(' spS name:varRaw spP bvar:varRaw",
    "      spS ')' spS body:expr spS ')'", // one bounded var. only
    "      {return new Term('rec', [name, bvar], [body]);}",
    // probabilistic choice
    "choose = '(' spS 'choose' spS '(' spS prob:prob spS ')' spS",
    "         args:arg2 spS ')'",
    "         {return new Term('choose', [prob], args);}",
    "prob = '0.' [0-9]* {return parseFloat(text());}",
    "     / '1.' '0'* {return 1;}",
    "     / '0' {return 0;}",
    "     / '1' {return 1;}",
    // pairs (product types)
    "car = '(' spS 'car' arg:argSp1 spS ')'",
    "      {return new Term('car', [], arg);}",
    "cdr = '(' spS 'cdr' arg:argSp1 spS ')'",
    "      {return new Term('cdr', [], arg);}",
    "cons = '(' spS 'cons' args:argSp2 spS ')'",
    "       {return new Term('cons', [], args);}",
    // pattern match (coproduct types)
    "inl = '(' spS 'inl' arg:argSp1 spS ')'",
    "      {return new Term('inl', [], arg);}",
    "inr = '(' spS 'inr' arg:argSp1 spS ')'",
    "      {return new Term('inr', [], arg);}",
    "match = '(' spS 'match' pat:argSp1 spS",
    "        '(' spS '(' spS 'inl' spP varL:varRaw spS ')'",
    "        spS left:expr spS ')' spS",
    "        '(' spS '(' spS 'inr' spP varR:varRaw spS ')'",
    "        spS right:expr spS ')' spS ')'",
    "        {return new Term('match', [varL, varR],",
    "                             pat.concat([left, right]));}",
    // summation (arithmetic primitive)
    "sum = '(' spS '+' args:argSp2 spS ')'",
    "      {return new Term('+', [], args);}",
    // application
    "app = '(' spS args:arg2 spS ')'",
    "      {return new Term('app', [], args);}",
    // for arguments
    "arg2 = left:base spP right:base {return [left, right];}",
    "     / left:base spS right:composed {return [left, right];}",
    "     / left:composed spS right:expr {return [left, right];}",
    "argSp1 = spP body:base {return [body];}",
    "       / spS body:composed {return [body];}",
    "argSp2 = spP left:base spP right:base {return [left, right];}",
    "       / spP left:base spS right:composed",
    "         {return [left, right];}",
    "       / spS left:composed spS right:expr",
    "         {return [left, right];}"
];

var grammar = rules.join("\n");
