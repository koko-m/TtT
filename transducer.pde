interface DrawTd {
  float getTdWidth ();
  float getTdHeight ();         // 1/2 value
  float[] getTdPorts ();
  void go ();
}

DrawTd getDrawTd (Object parsedTerm, String[] freeVars) {
  DrawTd drawTd;
  switch (parsedTerm.tag) {
  case "var": drawTd = getDrawVarTd(parsedTerm, freeVars); break;
  case "nat": drawTd = getDrawNatTd(parsedTerm, freeVars); break;
  case "unit": drawTd = getDrawUnitTd(parsedTerm, freeVars); break;
  }
  return drawTd;
}

DrawTd getDrawVarTd (Object parsedTerm, String[] freeVars) {
  int numFreeVars = freeVars.length;
  String name = parsedTerm.parameters[0];
  int index = lookupStrArray(freeVars, name);
  String errMsg = "error in getDrawVarTd: unknown variable";
  float tdWidth;
  float tdHeight;
  float[] tdPorts;
  if (index < 0) {              // unknown variable
    tdWidth = textWidth(errMsg);
    tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF,
                   TEXT_SIZE_DEFAULT / 2 + 1);
    tdPorts = null;
  } else {
    if (index == numFreeVars - 1) { // the last var. in freeVars
      tdWidth = 20 + 15 * (numFreeVars - 1);
      tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 12.5);
    } else{
      tdWidth = 20 + 15 * numFreeVars;
      tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 25);
    }
    tdPorts = new float[numFreeVars + 1];
    for (int i = 0; i < numFreeVars; i++) {
      tdPorts[i] = tdWidth - 5 - 15 * i;
    }
    tdPorts[numFreeVars] = 5;
  }
  return new DrawTd() {
    float getTdWidth () { return tdWidth; }
    float getTdHeight () { return tdHeight; }
    float[] getTdPorts () { return tdPorts; }
    void go () {
      pushMatrix();
      translate(0, CENTER_Y);
      drawTermBox(parsedTerm.prettyPrint(),
                  TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);
      translate(TERMBOX_MARGIN_LEFT, 0);
      if (index < 0) error(errMsg);
      else {
        drawPorts(tdHeight, tdPorts, freeVars);
        drawNamedRect("h", 10, 0, 20, 10);
        drawPaths({5, tdHeight, 5, 5});
        for (int i = 0; i < numFreeVars; i++) {
          if (i == index) {     // term (variable) itself
            if (i == numFreeVars - 1) { // the last of freeVars
              drawPaths({tdPorts[i], tdHeight, tdPorts[i], 5});
            } else {
              drawPaths({tdPorts[i], tdHeight, tdPorts[i], 10,
                    15, 10, 15, 5});
            }
          } else {              // free variables
            drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                                10, 10);
          }
        }
      }
      popMatrix();
    }
  };
}

DrawTd getDrawNatTd (Object parsedTerm, String[] freeVars) {
  int numFreeVars = freeVars.length;
  int value = parsedTerm.parameters[0];
  String name = parsedTerm.prettyPrint();
  textSize(TEXT_SIZE_SMALL);
  float hWidth = 20;
  float kWidth = textWidth("k" + name) + NAME_MARGIN_HALF * 2;
  textSize(TEXT_SIZE_DEFAULT);
  float tdWidth = hWidth + CROSS_MARGIN + kWidth + 15 * numFreeVars;
  float tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 15);
  String[] tdPorts = new float[numFreeVars + 1];
  for (int i = 0; i < numFreeVars; i++) {
    tdPorts[i] = tdWidth - 5 - 15 * i;
  }
  tdPorts[numFreeVars] = 5;
  return new DrawTd() {
    float getTdWidth () { return tdWidth; }
    float getTdHeight () { return tdHeight; }
    float[] getTdPorts () { return tdPorts; }
    void go () {
      pushMatrix();
      translate(0, CENTER_Y);
      drawTermBox(name, TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);
      translate(TERMBOX_MARGIN_LEFT, 0);
      drawPorts(tdHeight, tdPorts, freeVars);
      drawNamedRect("h", hWidth / 2, 0, hWidth, 10);
      drawNamedRect("k" + name, hWidth + CROSS_MARGIN + kWidth / 2, 0,
                    kWidth, 10);
      drawPaths({5, tdHeight, 5, 5});
      drawPaths({15, -5, 15, -10, 20 + CROSS_PADDING_HALF, -10,
            20 + CROSS_MARGIN - CROSS_PADDING_HALF, 10,
            20 + CROSS_MARGIN + kWidth / 2, 10,
            20 + CROSS_MARGIN + kWidth / 2, 5});
      for (int i = 0; i < numFreeVars; i++) {
        drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                            10, 10);
      }
      popMatrix();
    }
  }
}

DrawTd getDrawUnitTd (Object parsedTerm, String[] freeVars) {
  int numFreeVars = freeVars.length;
  String name = parsedTerm.prettyPrint();
  float tdWidth = 25 + 15 * numFreeVars;
  float tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 15);
  String[] tdPorts = new float[numFreeVars + 1];
  for (int i = 0; i < numFreeVars; i++) {
    tdPorts[i] = tdWidth - 5 - 15 * i;
  }
  tdPorts[numFreeVars] = 5;
  return new DrawTd() {
    float getTdWidth () { return tdWidth; }
    float getTdHeight () { return tdHeight; }
    float[] getTdPorts () { return tdPorts; }
    void go () {
      pushMatrix();
      translate(0, CENTER_Y);
      drawTermBox(name, TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);
      translate(TERMBOX_MARGIN_LEFT, 0);
      drawPorts(tdHeight, tdPorts, freeVars);
      drawNamedRect("h", 10, 0, 20, 10);
      drawPaths({5, tdHeight, 5, 5});
      drawPaths({15, -5, 15, -10, 25, -10, 25, 0});
      for (int i = 0; i < numFreeVars; i++) {
        drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                            10, 10);
      }
      popMatrix();
    }
  }
}
