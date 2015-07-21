rectMode(CENTER);

int lookupStrArray (String[] strArray, String str) {
  int index = -1;
  for (i = 0; i < strArray.length; i++) {
    if (strArray[i] == str) {
      index = i;
      // break;
      // // take the last one
    }
  }
  return index;                 // negative value indicates error
}

void error (String msg) {
  textAlign(LEFT, CENTER);
  text(msg, 0, 0);
}

void drawNamedRect (String name,
                    float centerX, float centerY,
                    float rectWidth, float rectHeight) {
  rect(centerX, centerY, rectWidth, rectHeight);
  fill(#000000);
  textAlign(CENTER, CENTER);
  textSize(TEXT_SIZE_SMALL);
  text(name, centerX, centerY);
  textSize(TEXT_SIZE_DEFAULT);
  fill(#ffffff);
}

void drawPrimitiveTdPair (String nameLower, String nameUpper,
                          float centerX, float centerY,
                          float rectWidth, float rectHeight) {
  drawNamedRect(nameLower, centerX, centerY, rectWidth, rectHeight);
  drawNamedRect(nameUpper, centerX, -centerY, rectWidth, rectHeight);
}

void drawLines (float x1, float y1, float x2, float y2) {
  line(x1, y1, x2, y2);
  line(x1, -y1, x2, -y2);
}

void drawVerticalLines (float x, float y1, float y2) {
  return drawLines(x, y1, x, y2);
}

void drawHorizontalLines (float x1, float x2, float y) {
  return drawLines(x1, y, x2, y);
}

void drawTermBox (String name,
                  float rectWidth, float rectHeight) {
  stroke(#ffffff);
  noFill();
  rect(rectWidth / 2, 0, rectWidth, rectHeight, 5);
  stroke(#000000);
  fill(#ffffff);

  pushMatrix();
  rotate(HALF_PI);
  textAlign(CENTER, BOTTOM);
  text(name,0,0);
  popMatrix();
}

void drawPorts (float tdHeight,
                float[] tdPorts, String[] freeVars, String name) {
  // String[] portNames = append(freeVars, name);
  // // This changes freeVars!!
  // if (tdPorts.length != portNames.length) return;
  if (tdPorts.length != freeVars.length + 1) return;
  textSize(10);
  for (i = 0; i < tdPorts.length; i++) {
    String str = (i == freeVars.length) ? name : freeVars[i];
    pushMatrix();
    translate(tdPorts[i], tdHeight);
    rotate(HALF_PI);
    textAlign(LEFT, BOTTOM);
    text(str, 0, 0);
    popMatrix();

    pushMatrix();
    translate(tdPorts[i], -tdHeight);
    rotate(HALF_PI);
    textAlign(RIGHT, BOTTOM);
    text(str, 0, 0);
    popMatrix();
  }
  textSize(12);
}
