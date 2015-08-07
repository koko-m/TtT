// data structure for internal states (memories)

boolean STATE_RIGHT = true;
boolean STATE_LEFT = false;

String printState (boolean stateRight) {
  if (stateRight) return "STATE RIGHT";
  else return "STATE LEFT";
}

class Memory {
  HashMap hm;                   // associate list with strings as keys

  Memory () {
    this.hm = new HashMap();
  }
  
  boolean isDefault (Nat n) {
    return !(this.hm.containsKey(n.rawPrint()));
  }

  boolean lookup (Nat n) {
    return this.hm.get(n.rawPrint());
  }

  void update (Nat n, boolean state) {
    this.hm.put(n.rawPrint(), state);
  }
}
