// data structure for internal states (memories)

boolean STATE_RIGHT = true;
boolean STATE_LEFT = false;

String printState (boolean stateRight) {
  if (stateRight) return "RIGHT";
  else return "LEFT";
}

class Memory {
  HashMap hm;                   // associate list with strings as keys

  Memory () {
    this.hm = new HashMap();
  }
  
  boolean isDefault (Nat n) {
    return !(this.hm.containsKey(n.prettyPrint()));
  }

  boolean lookup (Nat n) {
    return this.hm.get(n.prettyPrint());
  }

  void update (Nat n, boolean state) {
    this.hm.put(n.prettyPrint(), state);
  }

  int memSize () {
    if (this.hm.containsKey("-")) {
      return this.hm.size();
    } else {
      return this.hm.size() + 1;
    }
  }

  String prettyPrint () {
    if (this.hm.isEmpty()) {
      return "-:DEFAULT";
    }
    String str = "";
    for (String nPrettyPrinted : this.hm.keySet()) {
      str = str + "\n" + nPrettyPrinted + ":"
        + printState(this.hm.get(nPrettyPrinted));
    }
    str = str.substring(1);   // remove the first '\n'
    if (!this.hm.containsKey("-")) {
      str = str + "\n-:DEFAULT";
    }
    return str;
  }
}
