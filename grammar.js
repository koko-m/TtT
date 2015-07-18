/* term constructors */

function Base (type, body) {
    this.type = type;
    this.body = body;
    this.env = [];
}
Base.prototype.print = function () {
    return "(" + this.type + " " + this.body + " " + this.env + ")";
}

function Composed (operation, parameters, args) {
    this.operation = operation;
    this.parameters = parameters;
    this.args = args;
    this.env = [];
}
Composed.prototype.print = function () {
    var str = "(" + this.operation + " " + this.parameters;
    for (var i = 0; i < this.args.length; i++) {
	str += " " + this.args[i].print();
    }
    return  str + " " + this.env + ")";
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
    "composed =  abs / rec / choose",
    "         / car / cdr / cons",
    "         / inl / inr / match / sum",
    "         / app",
    // base
    "varRaw = [a-z/A-Z]+ {return text();}",
    "var = str:varRaw {return new Base('Var', str);}",
    "const = '*' {return new Base('Unit', '*');}",
    "      / [0-9]+ {return new Base('Nat', parseInt(text(), 10));}",
    // composed
    "abs = '(' spS 'lambda' spS '(' spS bvar:varRaw spS ')' spS",
    "      body:expr spS ')'",	// one bounded variable only
    "      {return new Composed('Abs', [bvar], [body]);}",
    "rec = '(' spS 'rec' spS '(' spS name:varRaw spP bvar:varRaw",
    "      spS ')' spS body:expr spS ')'", // one bounded var. only
    "      {return new Composed('Rec', [name, bvar], [body]);}",
    "choose = '(' spS 'choose' spS '(' spS prob:prob spS ')' spS",
    "         args:arg2 spS ')'",
    "         {return new Composed('Choose', [prob], args);}",
    "prob = '0.' [0-9]* {return parseFloat(text());}",
    "     / '1.' '0'* {return 1;}",
    "     / '0' {return 0;}",
    "     / '1' {return 1;}",
    // composed: product types
    "car = '(' spS 'car' arg:argSp1 spS ')'",
    "      {return new Composed('Car', [], arg);}",
    "cdr = '(' spS 'cdr' arg:argSp1 spS ')'",
    "      {return new Composed('Cdr', [], arg);}",
    "cons = '(' spS 'cons' args:argSp2 spS ')'",
    "       {return new Composed('Cons', [], args);}",
    // composed: coproduct types
    "inl = '(' spS 'inl' arg:argSp1 spS ')'",
    "      {return new Composed('Inl', [], arg);}",
    "inr = '(' spS 'inr' arg:argSp1 spS ')'",
    "      {return new Composed('Inr', [], arg);}",
    "match = '(' spS 'match' pat:argSp1 spS",
    "        '(' spS '(' spS 'inl' spP varL:varRaw spS ')'",
    "        spS left:expr spS ')' spS",
    "        '(' spS '(' spS 'inr' spP varR:varRaw spS ')'",
    "        spS right:expr spS ')' spS ')'",
    "        {return new Composed('Match', [varL, varR],",
    "                             pat.concat([left, right]));}",
    // composed
    "sum = '(' spS '+' args:argSp2 spS ')'",
    "      {return new Composed('Sum', [], args);}",
    // composed
    "app = '(' spS args:arg2 spS ')'",
    "      {return new Composed('App', [], args);}",
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
