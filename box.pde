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
