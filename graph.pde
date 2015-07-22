// data for a graph

class Graph {
  Wire[] wires;
  Box[] boxes;

  Graph () {
    this.wires = new Wire[0];
    this.boxes = new Box[0];
  }

  int addWire (Wire wire) {
    this.wires = append(this.wires, wire);
    return this.wires.length;
  }

  int addBox (Box newBox) {
    this.boxed = append(this.boxes, newBox);
    return this.boxed.length;
  }
}

class Wire {
  float srcX, srcY;             // source coordinates
  float dirX, dirY;             // directional vector whose length is
                                // that of the wire
  // float length;
  // // can be calculated by mag(dirX, dirY)
  boolean enter;
  String portName;
  Wire[] nextWires;

  Wire (float srcX, float srcY, float dirX, float dirY,
        boolean enter, String portName) {
    this.srcX = srcX;
    this.srcY = srcY;
    this.dirX = dirX;
    this.dirY = dirY;
    this.enter = enter;
    this.portName = portName;
    this.nextWires = new Wire[0];
  }

  void addNextWire (Wire wire) {
    this.nextWires = append(this.nextWires, wire);
  }

  void draw () {
    stroke(#000000);
    line(srcX, srcY, srcX + dirX, srcY + dirY);
    if (portName != null) {
      fill(#ffffff);
      if (this.enter) textAlign(LEFT, BOTTOM);
      else textAlign(RIGHT, BOTTOM);
      textSize(TEXT_SIZE_PORT);
      pushMatrix();
      if (this.enter) translate(srcX, srcY + TEXT_MARGIN);
      else translate(srcX, srcY - TEXT_MARGIN);
      rotate(HALF_PI);
      text(portName, 0, 0);
      popMatrix();
    }
  }
}

rectMode(CENTER);               // specify the center point to draw
                                // a rectangle

// types of boxes (8 bits)
byte LABELED_RECT_ONE = 0;      // h, k_n, sum, choose
byte LABELED_RECT_PAIR = 1;     // retractions except for phi & psi
byte TRI_PAIR_CAP = 2;          // retraction phi & psi; psi is lower
byte TRI_PAIR_SANDGLASS = 3;    // retraction phi & psi; phi is lower
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
    float centerX = leftX + boxWidth / 2;
    float centerY = bottomY - boxHeight / 2;
    switch (this.type) {
    case LABELED_RECT_ONE:
      stroke(#000000);
      fill(#ffffff);
      rect(centerX, centerY, boxWidth, boxHeight);
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_LABEL);
      text(names[0], centerX, centerY);
      break;
    case LABELED_RECT_PAIR:
      stroke(#000000);
      fill(#ffffff);
      rect(centerX, centerY, boxWidth, boxHeight);
      rect(centerX, -centerY, boxWidth, boxHeight);
      fill(#000000);
      textAlign(CENTER, CENTER);
      textSize(TEXT_SIZE_LABEL);
      text(names[0], centerX, centerY);
      text(names[1], centerX, -centerY);
      break;
    case TRI_PAIR_CAP:
      stroke(#000000);
      fill(#ffffff);
      triangle(centerX, bottomY,
               leftX, bottomY - boxHeight,
               leftX + boxWidth, bottomY - boxHeight);
      triangle(centerX, -bottomY,
               leftX, -bottomY + boxHeight,
               leftX + boxWidth, -bottomY + boxHeight);
      break;
    case TRI_PAIR_SANDGLASS:
      stroke(#000000);
      fill(#ffffff);
      triangle(centerX, bottomY - boxHeight,
               leftX, bottomY, leftX + boxWidth, bottomY);
      triangle(centerX, -bottomY + boxHeight,
               leftX, -bottomY, leftX + boxWidth, -bottomY);
      break;
    case TERM_RECT:
      stroke(#ffffff);
      noFill();
      rect(centerX, centerY, boxWidth, boxHeight, 5);
      fill(#ffffff);
      textAlign(CENTER, BOTTOM);
      textSize(TEXT_SIZE_TERM);
      pushMatrix();
      translate(leftX, centerY);
      rotate(HALF_PI);
      text(names[0], 0, 0);
      popMatrix();
      break;
    case DASHED_RECT:
      float x, y;
      boolean on;
      // from bottom left to bottom right
      x = leftX;
      y = bottomY;
      on = true;
      beginShape(LINES);
      while (x <= leftX + boxWidth) {
        vertex(x, y);
        x += on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from bottom right to top right
      x = leftX + boxWidth;
      on = true;
      beginShape(LINES);
      while (y >= bottomY - boxHeight) {
        vertex(x, y);
        y -= on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from top right to top left
      y = bottomY - boxHeight;
      on = true;
      beginShape(LINES);
      while (x >= leftX) {
        vertex(x, y);
        x -= on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      // from top left to bottom left
      x = leftX;
      on = true;
      beginShape(LINES);
      while (y <= bottomY) {
        vertex(x, y);
        y += on ? DASHED_LINE_ON_INERVAL : DASHED_LINE_OFF_INTERVAL;
        on = !on;
      }
      endShape();
      break;
    }
  }
}
