class Transducer {
  // the bottom left corner of the bounding rectangle has coordinate
  // (0, tdHalfHeight)
  // input and output ports are symmetry wrt. the x-axis
  // ports are arranged from right to left
  Port[] ports;
  Box[] boxes;
  float tdWidth;
  float tdHalfHeight;
  int[] inPortIds;
  int[] outPortIds;
  Token token;

  Transducer (float tdWidth, float tdHalfHeight) {
    this.ports = new Port[0];
    this.boxes = new Box[0];
    this.tdWidth = tdWidth;
    this.tdHalfHeight = tdHalfHeight;
    this.inPortIds = new int[0];
    this.outPortIds = new int[0];
    this.token = null;
  }

  int addPort (Port newPort) {
    this.ports = append(this.ports, newPort);
    return this.ports.length - 1; // port id
  }

  int addBox (Box newBox) {
    this.boxes = append(this.boxes, newBox);
    return this.boxes.length - 1; // box id
  }

  int addBoxHead (Box newBox) {
    this.boxes = concat({newBox}, this.boxes);
    return 0;                   // box id
  }

  void connectPorts (int sourcePortId,
                     int[] targetPortIds, float[][] paths) {
    this.ports[sourcePortId].addNextPortIds(targetPortIds, paths);
  }

  void connectPorts (int sourcePortId, int[] targetPortIds) {
    this.ports[sourcePortId].addNextPortIds(targetPortIds);
  }

  Port getPort (int id) {
    return this.ports[id];
  }

  void setInPortIds (int[] inPortIds) {
    this.inPortIds = concat(this.inPortIds, inPortIds);
  }

  void setOutPortIds (int[] outPortIds) {
    this.outPortIds = concat(this.outPortIds, outPortIds);
  }

  void replaceInPortId (int portIndex, Port inPortId) {
    this.inPortIds[portIndex] = inPortId;
  }

  void replaceOutPortId (int portIndex, Port outPortId) {
    this.outPortIds[portIndex] = outPortId;
  }

  void removeInPortId (int portIndex) {
    this.inPortIds = concat(subset(this.inPortIds, 0, portIndex),
                            subset(this.inPortIds, portIndex + 1));
  }

  void removeOutPortId (int portIndex) {
    this.outPortIds = concat(subset(this.outPortIds, 0, portIndex),
                             subset(this.outPortIds, portIndex + 1));
  }

  void insertInPortId (int portId, int portIndex) {
    this.inPortIds = splice(this.inPortIds, portId, portIndex);
  }

  void insertOutPortId (int portId, int portIndex) {
    this.outPortIds = splice(this.outPortIds, portId, portIndex);
  }

  void shiftX (float shiftX) {
    for (int i = 0; i < this.ports.length; i++) {
      this.ports[i].shiftX(shiftX);
    }
    for (int i = 0; i < this.boxes.length; i++) {
      this.boxes[i].shiftX(shiftX);
    }
  }

  void shiftId (int shiftId) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.inPortIds[i] += shiftId;
    }
    for (int i = 0; i < this.outPortIds.length; i++) {
      this.outPortIds[i] += shiftId;
    }
    for (int i = 0; i < this.ports.length; i++) {
      Port p = this.ports[i];
      for (int j = 0; j < p.nextPortIds.length; j++) {
        p.nextPortIds[j] += shiftId;
      }
    }
  }

  void setInPortComputeInfo (byte computeType,
                             String value, Memory memory) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType,
                                                     value, i,
                                                     memory);
    }
  }
  
  void setInPortComputeInfo (byte computeType, String value) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType,
                                                     value, i);
    }
  }

  void setOutPortComputeInfo (byte computeType, String value) {
    for (int i = 0; i < this.outPortIds.length; i++) {
      this.getPort(this.outPortIds[i]).setComputeInfo(computeType,
                                                      value, i);
    }
  }

  void setInPortComputeInfo (byte computeType) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType, i);
    }
  }

  void initToken (Nat data) {
    int inPortId = this.inPortIds[this.inPortIds.length - 1];
    Port inPort = this.getPort(inPortId);
    this.token = new Token(data);
    this.token.setNextPort(inPortId,
                           {inPort.x, inPort.y, inPort.x, inPort.y});
    this.ports[this.outPortIds[this.outPortIds.length - 1]].setEnd();
  }

  void collectPaths () {
    // set each p.paths to be {p.x,p.y,x1,y1,...,nextP.x,nextP.y}
    for (int i = 0; i < this.ports.length; i++) {
      Port p = this.ports[i];
      for (int j = 0; j < p.nextPortIds.length; j++) {
        Port nextP = this.ports[p.nextPortIds[j]];
        p.paths[j] = concat({p.x, p.y},
                            concat(p.paths[j], {nextP.x, nextP.y}));
      }
    }
  }
  
  boolean run () {
    boolean terminate = false;
    if (toSkip()) {
      this.token.distance = 0;
      this.token.put();
      terminate =
        this.getPort(this.token.portId).setNextPort(this.token);
      if (terminate) {
        addLog("Result: "
               + decodeNatAnswer(this.token.data).prettyPrint()
               + " in copy " + this.token.copyIndex.prettyPrint());
      }
      skipped();
      return terminate;
    }
    if (isFrameByFrameMode()
        && FrameByFrameCounter <= FRAME_BY_FRAME_SEC * frameRate) {
      FrameByFrameCounter++;
      return terminate;
    }
    FrameByFrameCounter = 0;
    this.token.step();
    while (this.token.distance < 0) {
      this.token.updatePointIndex();
      if (this.token.distance >= 0) break;
      terminate =
        this.getPort(this.token.portId).setNextPort(this.token);
      if (terminate) {
        addLog("Result: "
               + decodeNatAnswer(this.token.data).prettyPrint()
               + " in copy " + this.token.copyIndex.prettyPrint());
        break;
      }
    }
    if (!terminate) this.token.put();
    return terminate;
  }
  
  void drawAll () {
    this.draw();
    this.drawPorts();
  }

  void draw () {
    for (int i = 0; i < boxes.length; i++) this.boxes[i].draw();
    for (int i = 0; i < ports.length; i++) {
      this.ports[i].drawName();
      this.ports[i].drawPaths();
    }
    this.token.draw();
  }
  
  void drawPorts () {
    for (int i = 0; i < ports.length; i++) {
      Port p = this.ports[i];
      color strokeColor = #0000ff;
      color fillColor;
      if (p.visible) fillColor = strokeColor;
      else fillColor = #ffffff;
      stroke(strokeColor);
      fill(fillColor);
      ellipseMode(CENTER);
      ellipse(p.x, p.y, 4, 4);
      fill(strokeColor);
      if (p.y > 0) textAlign(RIGHT, TOP);
      else textAlign(RIGHT, BOTTOM);
      textSize(TEXT_SIZE_DEBUG);
      text(i, p.x, p.y);
    }
  }

  void debug (boolean go) {
    if (go) console.log("width: " + this.tdWidth,
                        "half height: " + this.tdHalfHeight,
                        "input ports: " + this.inPortIds,
                        "output ports: " + this.outPortIds);
  }
}
