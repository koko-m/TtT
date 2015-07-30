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

  void setComputeInfo (byte computeType, float value, Memory memory) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType,
                                                     value, i,
                                                     memory);
    }
  }
  
  void setComputeInfo (byte computeType, float value) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType,
                                                     value, i);
    }
  }

  void setComputeInfo (byte computeType) {
    for (int i = 0; i < this.inPortIds.length; i++) {
      this.getPort(this.inPortIds[i]).setComputeInfo(computeType, i);
    }
  }

  void initToken (Nat data) {
    this.token = new Token(data,
                           this.inPortIds[this.inPortIds.length - 1]);
  }
  
  void run () {
    this.initToken(encodeNatQuery());
    addLog("run");
    while (this.token.portId
           != this.outPortIds[this.outPortIds.length - 1]) {
      Port p = this.getPort(this.token.portId);
      this.token.portId =
        p.nextPortIds[this.token.getNextPortIndex(p.computeType,
                                                  p.value,
                                                  p.portIndex,
                                                  p.memory)];
    }
    addLog(this.token.copyIndex.prettyPrint() + ", "
           + this.token.data.prettyPrint() + " at "
           + this.token.portId);
    addLog("Result: " + decodeNatAnswer(this.token.data).prettyPrint()
           + " in copy " + this.token.copyIndex.prettyPrint());
  }
  
  void drawAll () {
    this.draw();
    this.drawPorts();
  }

  void draw () {
    for (int i = 0; i < boxes.length; i++) this.boxes[i].draw();
    for (int i = 0; i < ports.length; i++) {
      Port p = this.ports[i];
      if (p.visible) {
        if (p.nextPortIds.length != p.paths.length) {
          console.log("error draw (port id: " + i
                      + "): nextPortIds.length "
                      + nextPortIds.length
                      + " is not equal to paths.length "
                      + paths.length);
          break;
        }
        for (int j = 0; j < p.nextPortIds.length; j++) {
          float[] path = p.paths[j];
          if (path.length % 2 != 0) {
            console.log("error draw (port id: " + i
                        + " , next port id: " + j
                        + "): path.length " + path.length
                        + " is not even");
            break;
          }
          if (path.length > 0) {
            float x = p.x;
            float y = p.y;
            for (int k = 0; k < path.length / 2; k++) {
              stroke(#000000);
              line(x, y, path[k * 2], path[k * 2 + 1]);
              x = path[k * 2];
              y = path[k * 2 + 1];
            }
            stroke(#000000);
            line(x, y,
                 this.ports[p.nextPortIds[j]].x,
                 this.ports[p.nextPortIds[j]].y);
          } else {
            stroke(#000000);
            line(p.x, p.y,
                 this.ports[p.nextPortIds[j]].x,
                 this.ports[p.nextPortIds[j]].y);
          }
        }
      }
      this.ports[i].drawName();
    }
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

      // console.log(i + " " + printComputeType(p.computeType) + " "
      //             + p.portIndex + " " + p.memory);
    }
  }

  void debug (boolean go) {
    if (go) console.log("width: " + this.tdWidth,
                        "half height: " + this.tdHalfHeight,
                        "input ports: " + this.inPortIds,
                        "output ports: " + this.outPortIds);
  }
}

// boolean constants to specify whether to draw outgoing edges
boolean VISIBLE = true;
boolean HIDDEN = false;

class Port {
  float x;
  float y;
  int[] nextPortIds;
  float[][] paths;
  boolean visible;
  String name;

  // for computation: see token.pde
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
    for (i = 0; i < this.paths.length; i++) {
      float[] path = this.paths[i];
      for (j = 0; j < path.length / 2; j++) {
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
}

rectMode(CENTER);               // specify the center point to draw
                                // a rectangle

// types of boxes (8 bits)
byte LABELED_RECT_ONE = 0;      // h, k_n, sum
byte LABELED_RECT_PAIR = 1;     // retractions except for phi & psi
byte TRI_PAIR_JOIN = 2;         // retraction phi & psi; psi is lower
byte TRI_PAIR_SPLIT = 3;        // retraction phi & psi; phi is lower
byte TERM_RECT = 4;             // term box
byte DASHED_RECT = 5;           // dashed box
byte CHOOSE_RECT = 6;           // choose

class Box {
  byte type;
  String[] labels;
  float labelCenterX;           // valid only for CHOOSE_RECT
  float leftX;
  float bottomY;
  float boxWidth;
  float boxHeight;

  Box (byte type, String[] labels, float labelCenterX,
       float leftX, float bottomY, float boxWidth, float boxHeight) {
    this.type = type;
    this.labels = labels;
    this.labelCenterX = labelCenterX;
    this.leftX = leftX;
    this.bottomY = bottomY;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
  }

  Box (byte type, String[] labels,
       float leftX, float bottomY, float boxWidth, float boxHeight) {
    this(type, labels, leftX + boxWidth / 2,
         leftX, bottomY, boxWidth, boxHeight);
  }

  void shiftX (float shiftX) {
    this.leftX += shiftX;
    this.labelCenterX += shiftX;
  }

  void draw () {
    float centerX = this.leftX + this.boxWidth / 2;
    float centerY = this.bottomY - this.boxHeight / 2;
    switch (this.type) {
    case LABELED_RECT_ONE:
      stroke(#000000);
      fill(#ffffff);
      rect(centerX, centerY, this.boxWidth, this.boxHeight);
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_LABEL);
      text(this.labels[0], centerX, centerY);
      break;
    case LABELED_RECT_PAIR:
      stroke(#000000);
      fill(#ffffff);
      rect(centerX, centerY, this.boxWidth, this.boxHeight); // lower
      rect(centerX, -centerY, this.boxWidth, this.boxHeight); // upper
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_LABEL);
      text(labels[0], centerX, centerY); // lower
      text(labels[1], centerX, -centerY); // upper
      break;
    case TRI_PAIR_JOIN:
      stroke(#000000);
      fill(#ffffff);
      triangle(centerX, this.bottomY,
               this.leftX, this.bottomY - this.boxHeight,
               this.leftX + this.boxWidth,
               this.bottomY - this.boxHeight); // lower
      triangle(centerX, -this.bottomY,
               this.leftX, -this.bottomY + this.boxHeight,
               this.leftX + this.boxWidth,
               -this.bottomY + this.boxHeight); // upper
      break;
    case TRI_PAIR_SPLIT:
      stroke(#000000);
      fill(#ffffff);
      triangle(centerX, this.bottomY - this.boxHeight,
               this.leftX, this.bottomY,
               this.leftX + this.boxWidth, this.bottomY); // lower
      triangle(centerX, -this.bottomY + this.boxHeight,
               this.leftX, -this.bottomY,
               this.leftX + this.boxWidth, -this.bottomY); // upper
      break;
    case TERM_RECT:
      stroke(#ffffff);
      noFill();
      rect(centerX, centerY, this.boxWidth, this.boxHeight, 5);
      fill(#ffffff);
      textAlign(CENTER, BOTTOM);
      textSize(TEXT_SIZE_TERM);
      pushMatrix();
      translate(this.leftX, centerY);
      rotate(HALF_PI);
      text(this.labels[0], 0, 0);
      popMatrix();
      break;
    case DASHED_RECT:
      float x, y;
      boolean on;
      // from bottom left to bottom right
      x = this.leftX;
      y = this.bottomY;
      on = true;
      beginShape(LINES);
      while (x <= this.leftX + this.boxWidth) {
        vertex(x, y);
        x += on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from bottom right to top right
      x = this.leftX + this.boxWidth;
      on = true;
      beginShape(LINES);
      while (y >= this.bottomY - this.boxHeight) {
        vertex(x, y);
        y -= on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from top right to top left
      y = this.bottomY - this.boxHeight;
      on = true;
      beginShape(LINES);
      while (x >= this.leftX) {
        vertex(x, y);
        x -= on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from top left to bottom left
      x = this.leftX;
      on = true;
      beginShape(LINES);
      while (y <= this.bottomY) {
        vertex(x, y);
        y += on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      break;
    case CHOOSE_RECT:
      stroke(#000000);
      strokeWeight(2);
      // fill(#ffffff);
      noFill();
      rect(centerX, centerY, this.boxWidth, this.boxHeight);
      strokeWeight(1);          // restore default value
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_PROB);
      text(this.labels[0], this.labelCenterX, centerY);
      break;
    }
  }
}
