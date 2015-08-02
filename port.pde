// boolean constants to specify whether to draw outgoing edges
boolean VISIBLE = true;
boolean HIDDEN = false;

class Port {
  float x;
  float y;
  int[] nextPortIds;
  float[][] paths;              // to be completed
                                // by Transducer.collectPaths()
  boolean visible;
  String name;

  // for computation
  byte computeType;
  float value;                  // valid only for COMPUTE_K and
                                // COMPUTE_CHOOSE
  int portIndex;
  Memory memory;
  
  Port (float x, float y, boolean visible, String name) {
    this.x = x;
    this.y = y;
    this.nextPortIds = new int[0];
    this.paths = new float[0];
    this.visible = visible;
    this.name = name;
    this.computeType = COMPUTE_NOP;
    this.memory = null;
  }

  Port (float x, float y, boolean visible) {
    this(x, y, visible, null);  // no name
  }

  // Port (float x, float y, String name) {
  //   this(x, y, VISIBLE, name);
  // }

  Port (float x, float y) {
    this(x, y, VISIBLE, null);
  }

  void setComputeInfo (byte computeType, float value, int portIndex,
                       Memory memory) {
    this.computeType = computeType;
    this.value = value;
    this.portIndex = portIndex;
    this.memory = memory;
  }
  
  void setComputeInfo (byte computeType, float value, int portIndex) {
    this.computeType = computeType;
    this.value = value;
    this.portIndex = portIndex;
  }
  
  void setComputeInfo (byte computeType, int portIndex) {
    this.computeType = computeType;
    this.portIndex = portIndex;
  }

  void setEnd () {
    this.computeType = COMPUTE_END;
  }
  
  void addNextPortIds (int[] portIds, float[][] paths) {
    if (portIds.length != paths.length) {
      console.log("error addNextPortIds: portIds.length "
                  + portIds.length + " is not equal to paths.length "
                  + paths.length);
      return;
    }
    this.nextPortIds = concat(this.nextPortIds, portIds);
    this.paths = concat(this.paths, paths);
  }
  
  void addNextPortIds (int[] portIds) {
    float[][] paths = new float[portIds.length][0];
    this.addNextPortIds(portIds, paths);
  }

  void shiftX (float shiftX) {
    this.x += shiftX;
    for (int i = 0; i < this.paths.length; i++) {
      float[] path = this.paths[i];
      for (int j = 0; j < path.length / 2; j++) {
        path[j * 2] += shiftX;
      }
    }
  }

  void hide () {
    this.visible = HIDDEN;
  }

  void drawName () {
    if (this.name != null) {
      fill(#ffffff);
      if (this.y > 0) textAlign(LEFT, BOTTOM);
      if (this.y < 0) textAlign(RIGHT, BOTTOM);
      textSize(TEXT_SIZE_PORT);
      pushMatrix();
      if (this.y > 0) translate(this.x, this.y + TEXT_MARGIN);
      if (this.y < 0) translate(this.x, this.y - TEXT_MARGIN);
      rotate(HALF_PI);
      text(this.name, 0, 0);
      popMatrix();
    }
  }

  boolean setNextPort (Token token) {
    addLog(token.copyIndex.prettyPrint() + ", "
           + token.data.prettyPrint() + " at "
           + token.portId + "("
           + printComputeType(this.computeType) + ":" + this.portIndex
           + ")");
    String errMsgIndex =
      "error getNextPortId: invalid portIndex "
      + this.portIndex + " for "
      + printComputeType(this.computeType);
    String errMsgData =
      "error getNextPortId: invalid data "
      + token.data.rawPrint() + " for "
      + printComputeType(this.computeType) + ": " + this.portIndex;
    String errMsgCopy =
      "error getNextPortId: invalid copy index "
      + token.copyIndex.rawPrint() + " for "
      + printComputeType(this.computeType) + ": " + this.portIndex;
    switch (this.computeType) {
    case COMPUTE_U:
      switch (this.portIndex) {
      case 0:
        if (token.copyIndex.isPair()) {
          token.data = pair(snd(token.copyIndex), token.data);
          token.copyIndex = fst(token.copyIndex);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // (<i,j>,n):0 --> (i,<j,n>):0
        } else {
          console.log(errMsgCopy);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_V:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair()) {
          token.copyIndex = pair(token.copyIndex, fst(token.data));
          token.data = snd(token.data);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // (i,<j,n>):0 --> (<i,j>,n):0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_PHI:
      switch (this.portIndex) {
      case 0:
        token.data = droit(token.data);
        token.setNextPort(this.nextPortIds[0], this.paths[0]);
        return CONTINUE;        // n:0 --> dn:0
      case 1:
        token.data = gauche(token.data);
        token.setNextPort(this.nextPortIds[0], this.paths[0]);
        return CONTINUE;        // n:1 --> gn:0
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_PSI:
      switch (this.portIndex) {
      case 0:
        if (token.data.isDroit()) {
          token.data = unDroit(token.data);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // dn:0 --> n:0
        } else if (token.data.isGauche()) {
          token.data = unGauche(token.data);
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // gn:0 --> n:1
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_E:
      switch (this.portIndex) {
      case 0:
        token.data = pair(fromInt(0), token.data);
        token.setNextPort(this.nextPortIds[0], this.paths[0]);
        return CONTINUE;        // n:0 --> <0,n>:0
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_E_PRIME:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair()) {
          token.data = snd(token.data);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <i,n>:0 --> n:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_D:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair() && token.copyIndex.isPair()) {
          token.data = pair(pair(snd(token.copyIndex),
                                 fst(token.data)),
                            snd(token.data));
          token.copyIndex = fst(token.copyIndex);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // (<h,i>,<j,n>):0 --> (h,<<i,j>,n>):0
        } else if (!token.data.isPair()) {
          console.log(errMsgData);
          return TERMINATE;
        } else {
          console.log(errMsgCopy);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_D_PRIME:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair() && fst(token.data).isPair()) {
          token.copyIndex = pair(token.copyIndex,
                                 fst(fst(token.data)));
          token.data = pair(snd(fst(token.data)), snd(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // (h,<<i,j>,n>):0 --> (<h,i>,<j,n>):0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_C:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair()) {
          token.data = pair(droit(fst(token.data)), snd(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <i,n>:0 --> <di,n>:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      case 1:
        if (token.data.isPair()) {
          token.data = pair(gauche(fst(token.data)), snd(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <i,n>:1 --> <gi,n>:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_C_PRIME:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair() && fst(token.data).isDroit()) {
          token.data = pair(unDroit(fst(token.data)),
                            snd(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <di,n>:0 --> <i,n>:0
        } else if (token.data.isPair()
                   && fst(token.data).isGauche()) {
          token.data = pair(unGauche(fst(token.data)),
                            snd(token.data));
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // <gi,n>:0 --> <i,n>:1
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_W:
      switch (this.portIndex) {
      case 0:
        console.log("token absorbed!");
        return TERMINATE;
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_W_PRIME:
      switch (this.portIndex) {
      case 0:
        console.log("where are you from?");
        return TERMINATE;
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_H:
      switch (this.portIndex) {
      case 0:
        token.data = droit(droit(token.data));
        token.setNextPort(this.nextPortIds[1], this.paths[1]);
        return CONTINUE;        // n:0 --> ddn:1
      case 1:
        if (token.data.isGauche()) {
          token.data = droit(token.data);
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // gn:1 --> dgn:1
        } else if (token.data.isDroit()
                   && unDroit(token.data).isGauche()) {
          token.data = unDroit(token.data);
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // dgn:1 --> gn:1
        } else if (token.data.isDroit()
                   && unDroit(token.data).isDroit()) {
          token.data = unDroit(unDroit(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // ddn:1 --> n:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_K:
      switch (this.portIndex) {
      case 0:
        token.data = pair(fst(token.data), fromInt(int(this.value)));
        token.setNextPort(this.nextPortIds[0], this.paths[0]);
        return CONTINUE;        // n:0 --> value:0
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_SUM:
      switch (this.portIndex) {
      case 0:
        if (token.data.isPair()) {
          token.data = pair(token.data, snd(token.data));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <i,n>:0 --> <<i,n>,n>:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      case 1:
        if (token.data.isPair() && fst(token.data).isPair()) {
          token.data = pair(fst(fst(token.data)),
                            sum(snd(fst(token.data)),
                                snd(token.data)));
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // <<i,n>,m>:1 --> <i,n+m>:0
        } else {
          console.log(errMsgData);
          return TERMINATE;
        }
      case 2:
        token.setNextPort(this.nextPortIds[0], this.paths[0]);
        return CONTINUE;        // n:2 --> n:0
      default:
        console.log(errMsgIndex);
        return TERMINATE;
      }
    case COMPUTE_CHOOSE:
      if (this.memory.isDefault(token.copyIndex)) {
        float rand = random(0,1);
        if (rand > this.value) {
          addLog("probabilistic choice ("
                 + this.value + ") RIGHT");
          console.log("probabilistic choice ("
                      + this.value + ") RIGHT");
          this.memory.update(token.copyIndex, STATE_RIGHT);
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // go to right
        } else {
          addLog("probabilistic choice ("
                 + this.value + ") LEFT");
          console.log("probabilistic choice ("
                      + this.value + ") LEFT");
          this.memory.update(token.copyIndex, STATE_LEFT);
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // go to left
        }
      } else {
        if (this.memory.lookup(token.copyIndex) == STATE_RIGHT) {
          token.setNextPort(this.nextPortIds[0], this.paths[0]);
          return CONTINUE;      // go to right
        } else {
          token.setNextPort(this.nextPortIds[1], this.paths[1]);
          return CONTINUE;      // go to left
        }
      }
    case COMPUTE_TERM: case COMPUTE_NOP:
      token.setNextPort(this.nextPortIds[0], this.paths[0]);
      return CONTINUE;
    case COMPUTE_END:
      token.x = this.x;
      token.y = this.y;
      return TERMINATE;
    }
  }
}

// boolean constants that indicate whether execution terminates
boolean TERMINATE = true;
boolean CONTINUE = false;

// 8 bits constants to specify computation type
byte COMPUTE_U = 0;
byte COMPUTE_V = 1;
byte COMPUTE_PHI = 2;
byte COMPUTE_PSI = 3;
byte COMPUTE_E = 4;
byte COMPUTE_E_PRIME = 5;
byte COMPUTE_D = 6;
byte COMPUTE_D_PRIME = 7;
byte COMPUTE_C = 8;
byte COMPUTE_C_PRIME = 9;
byte COMPUTE_W = 10;
byte COMPUTE_W_PRIME = 11;
byte COMPUTE_H = 12;
byte COMPUTE_K = 13;
byte COMPUTE_SUM = 14;
byte COMPUTE_TERM = 15;
byte COMPUTE_CHOOSE = 16;
byte COMPUTE_NOP = 17;
byte COMPUTE_END = 18;

String printComputeType (byte computeType) {
  switch (computeType) {
  case COMPUTE_U: return "U";
  case COMPUTE_V: return "V";
  case COMPUTE_PHI: return "PHI";
  case COMPUTE_PSI: return "PSI";
  case COMPUTE_E: return "E";
  case COMPUTE_E_PRIME: return "E'";
  case COMPUTE_D: return "D";
  case COMPUTE_D_PRIME: return "D'";
  case COMPUTE_C: return "C";
  case COMPUTE_C_PRIME: return "C'";
  case COMPUTE_W: return "W";
  case COMPUTE_W_PRIME: return "W'";
  case COMPUTE_H: return "H";
  case COMPUTE_K: return "K";
  case COMPUTE_SUM: return "SUM";
  case COMPUTE_TERM: return "TERM";
  case COMPUTE_CHOOSE: return "CHOOSE";
  case COMPUTE_NOP: return "NOP";
  case COMPUTE_END: return "END";
  }
}
