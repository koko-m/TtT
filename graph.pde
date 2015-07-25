// data for a graph

class Graph {
  Port[] ports;
  Box[] boxes;

  Graph () {
    this.ports = new Port[0];
    this.boxes = new Box[0];
  }
  
  int addPort (Port newPort) {
    this.ports = append(this.ports, newPort);
    return this.ports.length - 1; // port id
  }

  int addBox (Box newBox) {
    this.boxed = append(this.boxes, newBox);
    return this.boxed.length - 1; // box id
  }

  void connectPorts (int sourcePortId,
                     int[] targetPortIds, float[][] paths) {
    this.ports[sourcePortId].addNextPortIds(targetPortIds, paths);
  }

  void connectPorts (int sourcePortId, int[] targetPortIds) {
    this.ports[sourcePortId].addNextPortIds(targetPortIds);
  }

  Port getPort (int index) {
    return this.ports[index];
  }

  void drawAll () {
    this.draw();
    this.drawPorts();
  }

  void draw () {
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
    for (int i = 0; i < boxes.length; i++) this.boxes[i].draw();
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

  Port (float x, float y, boolean visible, String name) {
    this.x = x;
    this.y = y;
    this.nextPortIds = new int[0];
    this.paths = new float[0];
    this.visible = visible;
    this.name = name;
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
byte LABELED_RECT_ONE = 0;      // h, k_n, sum, choose
byte LABELED_RECT_PAIR = 1;     // retractions except for phi & psi
byte TRI_PAIR_JOIN = 2;         // retraction phi & psi; psi is lower
byte TRI_PAIR_SPLIT = 3;        // retraction phi & psi; phi is lower
byte TERM_RECT = 4;             // term box
byte DASHED_RECT = 5;           // dashed box

class Box {
  byte type;
  String[] names;
  float leftX;
  float bottomY;
  float boxWidth;
  float boxHeight;

  Box (byte type, String[] names,
       float leftX, float bottomY, float boxWidth, float boxHeight) {
    this.type = type;
    this.names = names;
    this.leftX = leftX;
    this.bottomY = bottomY;
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
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
      text(this.names[0], centerX, centerY);
      break;
    case LABELED_RECT_PAIR:
      stroke(#000000);
      fill(#ffffff);
      rect(centerX, centerY, this.boxWidth, this.boxHeight); // lower
      rect(centerX, -centerY, this.boxWidth, this.boxHeight); // upper
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_LABEL);
      text(names[0], centerX, centerY); // lower
      text(names[1], centerX, -centerY); // upper
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
      text(this.names[0], 0, 0);
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
    }
  }
}
