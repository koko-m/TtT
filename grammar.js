/* term constructions */

// core fragments

var Var = function (name) {
    this.type = "Var";
    this.name = name;
    this.env = [];
    this.print = "(" + this.type + " " + this.name + " " + this.env
	+ ")";
}

var Abs = function (arg, body) {
    this.type = "Abs";
    this.arg = arg;
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.arg + " "
	+ this.body.print + " " + this.env + ")";
}

var Rec = function (name, arg, body) {
    this.type = "Rec";
    this.name = name;
    this.arg = arg;
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.name + " " + this.arg
	+ " " + this.body.print + " " + this.env + ")";
}

// probabilistic choice

var Choose = function (prob, left, right) {
    this.type = "Choose";
    this.prob = prob;
    this.left = left;
    this.right = right;
    this.env = [];
    this.print = "(" + this.type + " " + this.prob + " "
	+ this.left.print + " "	+ this.right.print + " "
	+ this.env + ")";
}

// product types

var Unit = function (env) {
    this.type = "Unit";
    this.env = [];
    this.print = "(" + this.type + " " + this.env + ")";
}

var Fst = function (body) {
    this.type = "Fst";
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.body.print + " "
	+ this.env + ")";
}

var Snd = function (body) {
    this.type = "Snd";
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.body.print + " "
	+ this.env + ")";
}

var Pair = function (left, right) {
    this.type = "Pair";
    this.left = left;
    this.right = right;
    this.env = [];
    this.print = "(" + this.type + " " + this.left.print + " "
	+ this.right.print + " " + this.env + ")";
}

// coproduct types

var Inl = function (body) {
    this.type = "Inl";
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.body.print + " "
	+ this.env + ")";
}

var Inr = function (body) {
    this.type = "Inr";
    this.body = body;
    this.env = [];
    this.print = "(" + this.type + " " + this.body.print + " "
	+ this.env + ")";
}

var Case = function (pat, varL, left, varR, right) {
    this.type = "Case";
    this.pat = pat;
    this.varL = varL;
    this.left = left;
    this.varR = varR;
    this.right = right;
    this.env = [];
    this.print = "(" + this.type + " " + this.pat.print + " "
	+ this.varL + " " + this.left.print + " " + this.varR
	+ " " + this.right.print + " " + this.env + ")";
}

// arithmetic primitives

var Nat = function (nat) {
    this.type = "Nat";
    this.nat = nat;
    this.env = [];
    this.print = "(" + this.type + " " + this.nat + " " + this.env
	+ ")";
}

var Sum = function (left, right) {
    this.type = "Sum";
    this.left = left;
    this.right = right;
    this.env = [];
    this.print = "(" + this.type + " " + this.left.print + " "
	+ this.right.print + " " + this.env + ")";
}

/* PEG Rules */

var rules = [
    "start = expr",
    "lpar = '('",
    "rpar = ')'",
    "spS = ' '*",
    "spP = ' '+",
    "expr = var / const / abs / rec / choose",
    "//     / car / cdr / cons",
    "//     / inl / inr / match / sum",
    "//     / app",
    "varRaw = str:[a-z/A-Z]+ {return str.join('');}",
    "var = str:varRaw {return new Var(str);}",
    "const = '*' {return new Unit();}",
    "      / nat:[0-9]+ {return new Nat(parseInt(nat, 10));}",
    "abs = lpar spS 'lambda' spS lpar spS arg:varRaw spS rpar spS",
    "      body:expr spS rpar {return new Abs(arg, body);}",
    "rec = lpar spS 'rec' spS lpar spS name:varRaw spP arg:varRaw",
    "      spS rpar spS body:expr spS rpar",
    "      {return new Rec(name, arg, body);}",
    "choose = lpar spS 'choose' spS lpar spS prob:prob spS rpar spS",
    "         left:expr spP right:expr spS rpar",
    "         {return new Choose(prob, left, right);}",
    "prob = '0.' frac:[0-9]* {return parseFloat(text());}",
    "     / '0' {return 0;}",
    "     / '1' {return 1;}"
];

var grammar = rules.join("\n");
