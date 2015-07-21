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

void drawPaths (float[] path) {
  for (int i = 0; i < path.length / 2 - 1; i++) {
    line(path[2 * i], path[2 * i + 1],
         path[2 * (i + 1)], path[2 * (i + 1) + 1]);
    line(path[2 * i], -path[2 * i + 1],
         path[2 * (i + 1)], -path[2 * (i + 1) + 1]);
  }
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

void drawPorts (float tdHeight, float[] tdPorts, String[] freeVars) {
  if (tdPorts.length != freeVars.length + 1) return;
  textSize(10);
  for (i = 0; i < freeVars.length; i++) {
    pushMatrix();
    translate(tdPorts[i], tdHeight + NAME_MARGIN_HALF);
    rotate(HALF_PI);
    textAlign(LEFT, BOTTOM);
    text(freeVars[i], 0, 0);
    popMatrix();

    pushMatrix();
    translate(tdPorts[i], -tdHeight - NAME_MARGIN_HALF);
    rotate(HALF_PI);
    textAlign(RIGHT, BOTTOM);
    text(freeVars[i], 0, 0);
    popMatrix();
  }
  textSize(12);
}
