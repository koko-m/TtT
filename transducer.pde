interface DrawTd {
  float getTdWidth ();
  float getTdHeight ();         // 1/2 value
  float[] getTdPorts ();
  void go ();
}

DrawTd getDrawTd (Object parsedTerm, String[] freeVars) {
  DrawTd drawTd;
  switch (parsedTerm.tag) {
  case "var": drawTd = getDrawVarTd (parsedTerm, freeVars);
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
    tdHeight = max(textWidth(name) / 2 + TERM_MARGIN_BOTTOM,
                   TEXT_SIZE_DEFAULT / 2 + 1);
    tdPorts = null;
  } else {
    if (index == numFreeVars - 1) { // the last var. in freeVars
      tdWidth = 20 + 15 * (numFreeVars - 1);
      tdHeight = max(textWidth(name) / 2 + TERM_MARGIN_BOTTOM, 12.5);
    } else{
      tdWidth = 20 + 15 * numFreeVars;
      tdHeight = max(textWidth(name) / 2 + TERM_MARGIN_BOTTOM, 25);
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
      translate(0,300);
      drawTermBox(parsedTerm.prettyPrint(),
                  TERM_MARGIN_LR + tdWidth, tdHeight * 2);
      translate(TERM_MARGIN_LEFT, 0);
      if (index < 0) error(errMsg);
      else {
        drawPorts(tdHeight, tdPorts, freeVars, name);
        drawNamedRect("h", 10, 0, 20, 10);
        drawVerticalLines(5, tdHeight, 5);
        for (int i = 0; i < numFreeVars; i++) {
          if (i == index) {     // term (variable) itself
            if (i == numFreeVars - 1) { // the last of freeVars
              drawVerticalLines(tdPorts[i], tdHeight, 5);
            } else {
              drawVerticalLines(tdPorts[i], tdHeight, 10);
              drawHorizontalLines(tdPorts[i], 15, 10);
              drawVerticalLines(15, 10, 5);
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
