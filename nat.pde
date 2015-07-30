// data structure for encoded natural numbers
// for example dd<g42,137> is represented as a string "dd<g42,137>"

class Nat {
  String valStr;

  Nat (String valStr) {
    this.valStr = valStr;
  }

  Nat () {                      // dummy value for token.copyIndex
    this.valStr = "x";
  }

  boolean isDummy () {
    return this.valStr.equals("x");
  }
  
  int toInt () {
    return int(this.valStr);
  }
  
  String rawPrint () {
    return this.valStr;
  }
  
  String prettyPrint () {
    if (this.isGauche()) {
      return "g" + unGauche(this).prettyPrint();
    } else if (this.isDroit()) {
      return "d" + unDroit(this).prettyPrint();
    } else if (this.isPair()) {
      if (fst(this).isDummy()) {
        return snd(this).prettyPrint();
      } else if (snd(this).isDummy()) {
        return fst(this).prettyPrint();
      } else {
        return "<" + fst(this).prettyPrint() + ","
          + snd(this).prettyPrint() + ">";
      }
    } else if (this.isDummy()) {
      return "-";
    } else {
      return this.valStr;
    }
  }

  int _findComma (int fromIndex, int depth) {
    // for example "<42,137>,137>"._findComma(0) returns 8
    // for example "<42,137>,137>"._findComma(1) returns 3
    // for example "42,137>,137>"._findComma(1) returns 8
    int langle = this.valStr.substring(fromIndex).indexOf('<');
    int comma = this.valStr.substring(fromIndex).indexOf(',');
    if (comma < 0) return -1;   // no comma
    if (langle < 0 || comma < langle) {
      if (depth > 0) {
        return this._findComma(comma + 1 + fromIndex, depth - 1);
      } else {
        return comma + fromIndex;
      }
    } else {
      return this._findComma(langle + 1 + fromIndex, depth + 1);
    }
  }

  boolean isPair () {
    return this.valStr.charAt(0).equals("<")
      && this.valStr.charAt(this.valStr.length() - 1).equals(">")
      && this._findComma(1, 0) > 1
      && this._findComma(1, 0) < this.valStr.length() - 2;
  }
  
  boolean isGauche () {
    return this.valStr.charAt(0).equals("g");
  }
  
  boolean isDroit () {
    return this.valStr.charAt(0).equals("d");
  }
}

Nat fromInt (int n) {
  return new Nat(str(n));
}

Nat pair (Nat n, Nat m) {
  return new Nat("<" + n.valStr + "," + m.valStr + ">");
}

Nat fst (Nat n) {
  if (!n.isPair()) {
    console.log("error fst: " + n.rawPrint());
    return null;
  }
  return new Nat(n.valStr.substring(1, n._findComma(1, 0)));
}

Nat snd (Nat n) {
  if (!n.isPair()) {
    console.log("error snd: " + n.rawPrint());
    return null;
  }
  return new Nat(n.valStr.substring(n._findComma(1, 0) + 1,
                                    n.valStr.length() - 1));
}

Nat gauche (Nat n) {
  return new Nat("g" + n.valStr);
}

Nat droit (Nat n) {
  return new Nat("d" + n.valStr);
}

Nat unGauche (Nat n) {
  if (!n.isGauche()) {
    console.log("error unGauche: " + n.rawPrint());
    return null;
  }
  return new Nat(n.valStr.substring(1));
}

Nat unDroit (Nat n) {
  if (!n.isDroit()) {
    console.log("error unDroit: " + n.rawPrint());
    return null;
  }
  return new Nat(n.valStr.substring(1));
}

Nat sum (Nat n, Nat m) {
  return new Nat(str(n.toInt() + m.toInt()));
}

Nat encodeNatQuery () {
  return droit(droit(pair(fromInt(42), fromInt(137))));
}

Nat decodeNatAnswer (Nat n) {
  return snd(unDroit(unDroit(n)));
}
