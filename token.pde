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
  }
}

class Token {
  Nat copyIndex;
  Nat data;
  int portId;
  float x;
  float y;

  Token (Nat data, int portId, float x, float y) {
    this.copyIndex = new Nat(); // dummy value
    this.data = data;
    this.portId = portId;
    this.x = x;
    this.y = y;
  }

  int getNextPortIndex (byte computeType, float value, int portIndex,
                        Memory memory) {
    // addLog(this.copyIndex.prettyPrint() + ", "
    //        + this.data.prettyPrint() + " at "
    //        + this.portId + "("
    //        + printComputeType(computeType) + ":" + portIndex + ")");
    String errMsgIndex =
      "error getNextPortIndex: invalid portIndex "
      + portIndex + " for "
      + printComputeType(computeType);
    String errMsgData =
      "error getNextPortIndex: invalid data "
      + this.data.rawPrint() + " for "
      + printComputeType(computeType) + ": " + portIndex;
    String errMsgCopy =
      "error getNextPortIndex: invalid copy index "
      + this.copyIndex.rawPrint() + " for "
      + printComputeType(computeType) + ": " + portIndex;
    switch (computeType) {
    case COMPUTE_U:
      switch (portIndex) {
      case 0:
        if (this.copyIndex.isPair()) {
          this.data = pair(snd(this.copyIndex), this.data);
          this.copyIndex = fst(this.copyIndex);
          return 0;             // (<i,j>,n):0 --> (i,<j,n>):0
        } else {
          console.log(errMsgCopy);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_V:
      switch (portIndex) {
      case 0:
        if (this.data.isPair()) {
          this.copyIndex = pair(this.copyIndex, fst(this.data));
          this.data = snd(this.data);
          return 0;             // (i,<j,n>):0 --> (<i,j>,n):0
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_PHI:
      switch (portIndex) {
      case 0:
        this.data = droit(this.data);
        return 0;               // n:0 --> dn:0
      case 1:
        this.data = gauche(this.data);
        return 0;               // n:1 --> gn:0
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_PSI:
      switch (portIndex) {
      case 0:
        if (this.data.isDroit()) {
          this.data = unDroit(this.data);
          return 0;             // dn:0 --> n:0
        } else if (this.data.isGauche()) {
          this.data = unGauche(this.data);
          return 1;             // gn:0 --> n:1
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_E:
      switch (portIndex) {
      case 0:
        this.data = pair(fromInt(0), this.data);
        return 0;                 // n:0 --> <0,n>:0
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_E_PRIME:
      switch (portIndex) {
      case 0:
        if (this.data.isPair()) {
          this.data = snd(this.data);
          return 0;             // <i,n>:0 --> n:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_D:
      switch (portIndex) {
      case 0:
        if (this.data.isPair() && this.copyIndex.isPair()) {
          this.data = pair(pair(snd(this.copyIndex), fst(this.data)),
                           snd(this.data));
          this.copyIndex = fst(this.copyIndex);
          return 0;             // (<h,i>,<j,n>):0 --> (h,<<i,j>,n>):0
        } else if (!this.data.isPair()) {
          console.log(errMsgData);
          return -1;
        } else {
          console.log(errMsgCopy);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_D_PRIME:
      switch (portIndex) {
      case 0:
        if (this.data.isPair() && fst(this.data).isPair()) {
          this.copyIndex = pair(this.copyIndex, fst(fst(this.data)));
          this.data = pair(snd(fst(this.data)), snd(this.data));
          return 0;             // (h,<<i,j>,n>):0 --> (<h,i>,<j,n>):0
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_C:
      switch (portIndex) {
      case 0:
        if (this.data.isPair()) {
          this.data = pair(droit(fst(this.data)), snd(this.data));
          return 0;             // <i,n>:0 --> <di,n>:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      case 1:
        if (this.data.isPair()) {
          this.data = pair(gauche(fst(this.data)), snd(this.data));
          return 0;             // <i,n>:0 --> <gi,n>:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_C_PRIME:
      switch (portIndex) {
      case 0:
        if (this.data.isPair() && fst(this.data).isDroit()) {
          this.data = pair(unDroit(fst(this.data)), snd(this.data));
          return 0;             // <di,n>:0 --> <i,n>:0
        } else if (this.data.isPair() && fst(this.data).isGauche()) {
          this.data = pair(unGauche(fst(this.data)), snd(this.data));
          return 1;             // <gi,n>:0 --> <i,n>:1
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_W:
      switch (portIndex) {
      case 0:
        console.log("token absorbed!");
        return -1;
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_W_PRIME:
      switch (portIndex) {
      case 0:
        console.log("where are you from?");
        return -1;
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_H:
      switch (portIndex) {
      case 0:
        this.data = droit(droit(this.data));
        return 1;               // n:0 --> ddn:1
      case 1:
        if (this.data.isGauche()) {
          this.data = droit(this.data);
          return 1;             // gn:1 --> dgn:1
        } else if (this.data.isDroit()
                   && unDroit(this.data).isGauche()) {
          this.data = unDroit(this.data);
          return 1;             // dgn:1 --> gn:1
        } else if (this.data.isDroit()
                   && unDroit(this.data).isDroit()) {
          this.data = unDroit(unDroit(this.data));
          return 0;             // ddn:1 --> n:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_K:
      switch (portIndex) {
      case 0:
        this.data = pair(fst(this.data), fromInt(int(value)));
        return 0;                 // n:0 --> value:0
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_SUM:
      switch (portIndex) {
      case 0:
        if (this.data.isPair()) {
          this.data = pair(this.data, snd(this.data));
          return 0;             // <i,n>:0 --> <<i,n>,n>:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      case 1:
        if (this.data.isPair() && fst(this.data).isPair()) {
          this.data = pair(fst(fst(this.data)),
                           sum(snd(fst(this.data)), snd(this.data)));
          return 0;             // <<i,n>,m>:1 --> <i,n+m>:0
        } else {
          console.log(errMsgData);
          return -1;
        }
      case 2:
        return 0;             // n:2 --> n:0
      default:
        console.log(errMsgIndex);
        return -1;
      }
    case COMPUTE_CHOOSE:
      if (memory.isDefault(this.copyIndex)) {
        float rand = random(0,1);
        if (rand > value) {
          addLog("probabilistic choice (" + value + ") RIGHT");
          console.log("probabilistic choice (" + value + ") RIGHT");
          memory.update(this.copyIndex, STATE_RIGHT);
          return 0;             // go to right
        } else {
          addLog("probabilistic choice (" + value + ") LEFT");
          console.log("probabilistic choice (" + value + ") LEFT");
          memory.update(this.copyIndex, STATE_LEFT);
          return 1;             // go to left
        }
      } else {
        if (memory.lookup(this.copyIndex) == STATE_RIGHT)
          return 0;             // go to right
        else
          return 1;             // go to left
      }
    case COMPUTE_TERM: case COMPUTE_NOP:
      return 0;
    }
  }

  void draw () {
    stroke(#ff0000);
    fill(#ff0000);
    ellipseMode(CENTER);
    ellipse(this.x, this.y, TOKEN_DIAMETER, TOKEN_DIAMETER);
    textSize(TEXT_SIZE_TOKEN);
    textAlign(RIGHT, CENTER);
    text("{" + this.copyIndex.prettyPrint() + "}",
         this.x - TOKEN_DIAMETER / 2 - TEXT_MARGIN, this.y);
    textAlign(LEFT, CENTER);
    text(this.data.prettyPrint(),
         this.x + TOKEN_DIAMETER / 2 + TEXT_MARGIN, this.y);
  }
}
