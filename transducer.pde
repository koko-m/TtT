interface DrawTd {
  float getTdWidth ();
  float getTdHeight ();         // 1/2 value
  float[] getTdPorts ();
  void go ();
}

DrawTd getDrawTdCenter (Object parsedTerm, String[] freeVars) {
  // draw transducers in the center of the canvas wrt. y-axis
  DrawTd drawTd = getDrawTd(parsedTerm, freeVars);
  return new DrawTd() {
    float getTdWidth () { return drawTd.getTdWidth(); }
    float getTdHeight () { return drawTd.getTdHeight(); }
    float[] getTdPorts () { return drawTd.getTdPorts(); }
    void go () {
      pushMatrix();
      translate(0, CENTER_Y);
      drawTd.go();
      popMatrix();
    }
  }
}

DrawTd getDrawTd (Object parsedTerm, String[] freeVars) {
  // draw transducers symmetrically wrt. y-axis
  DrawTd drawTd;
  switch (parsedTerm.tag) {
  case "var": drawTd = getDrawVarTd(parsedTerm, freeVars); break;
  case "nat": drawTd = getDrawNatTd(parsedTerm, freeVars); break;
  case "unit": drawTd = getDrawUnitTd(parsedTerm, freeVars); break;
  case "lambda": drawTd = getDrawLambdaTd(parsedTerm, freeVars);
    break;
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
  if (index < 0) {              // unknown variable
    tdWidth = textWidth(errMsg);
    tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF,
                   TEXT_SIZE_DEFAULT / 2 + 1);
  } else {
    if (index == numFreeVars - 1) { // the last var. in freeVars
      tdWidth = 20 + 15 * (numFreeVars - 1);
      tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 12.5);
    } else{
      tdWidth = 20 + 15 * numFreeVars;
      tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF, 25);
    }
  }
  float[] tdPorts = new float[numFreeVars + 1];
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
      drawTermBox(parsedTerm.prettyPrint(),
                  TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);

      translate(TERMBOX_MARGIN_LEFT, 0);
      if (index < 0) error(errMsg);
      else {
        drawPorts(tdHeight, tdPorts, freeVars);
        drawNamedRect("h", 10, 0, 20, 10);
        // primitive: h
        drawPaths({5, tdHeight, 5, 5});
        // the leftmost wires connected to h
        for (int i = 0; i < numFreeVars; i++) {
          if (i == index) {     // term (variable) itself
            if (i == numFreeVars - 1) { // the last of freeVars
              drawPaths({tdPorts[i], tdHeight, tdPorts[i], 5});
            } else {
              drawPaths({tdPorts[i], tdHeight, tdPorts[i], 10,
                    15, 10, 15, 5});
            }
            // wires for the variable itself
          } else {              // free variables
            drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                                10, 10);
            // primitives: w', w
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
      drawTermBox(name, TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);

      translate(TERMBOX_MARGIN_LEFT, 0);
      drawPorts(tdHeight, tdPorts, freeVars);
      drawNamedRect("h", hWidth / 2, 0, hWidth, 10);
      // primitive: h
      drawNamedRect("k" + name, hWidth + CROSS_MARGIN + kWidth / 2, 0,
                    kWidth, 10);
      // primitive: k_{name}
      drawPaths({5, tdHeight, 5, 5});
      // the leftmost wires connected to h
      drawPaths({15, -5, 15, -10, 20 + CROSS_PADDING_HALF, -10,
            20 + CROSS_MARGIN - CROSS_PADDING_HALF, 10,
            20 + CROSS_MARGIN + kWidth / 2, 10,
            20 + CROSS_MARGIN + kWidth / 2, 5});
      // the crossing wires
      for (int i = 0; i < numFreeVars; i++) {
        drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                            10, 10);
      }
      // primitives: w', w
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
      drawTermBox(name, TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);

      translate(TERMBOX_MARGIN_LEFT, 0);
      drawPorts(tdHeight, tdPorts, freeVars);
      drawNamedRect("h", 10, 0, 20, 10);
      // primitive: h
      drawPaths({5, tdHeight, 5, 5});
      // the leftmost wires connected to h
      drawPaths({15, -5, 15, -10, 25, -10, 25, 0});
      // the looping wire
      for (int i = 0; i < numFreeVars; i++) {
        drawPrimitiveTdPair("w'", "w", tdPorts[i], tdHeight - 5,
                            10, 10);
      }
      // primitives: w', w
      popMatrix();
    }
  }
}

DrawTd getDrawLambdaTd (Object parsedTerm, String[] freeVars) {
  int numFreeVars = freeVars.length;
  String name = parsedTerm.prettyPrint();

  String[] freeVarsAdded = new String[freeVars.length];
  arrayCopy(freeVars, freeVarsAdded);
  freeVarsAdded = append(freeVarsAdded, parsedTerm.parameters[0]);
  DrawTd drawBodyTd = getDrawTd(parsedTerm.bodies[0], freeVarsAdded);
  // recursive call of getDrawTd

  float hWidth = 20;
  float bodyTdWidth = drawBodyTd.getTdWidth();
  float bodyTdOffset = hWidth + CROSS_MARGIN + TERMBOX_MARGIN_LEFT
    + DASHEDBOX_MARGIN;
  float tdWidth = TERMBOX_MARGIN_LEFT + bodyTdOffset + bodyTdWidth
    + DASHEDBOX_MARGIN + TERMBOX_MARGIN_RIGHT;

  float bodyTdHeight = drawBodyTd.getTdHeight();
  float tdHeight = max(textWidth(name) / 2 + NAME_MARGIN_HALF,
                       bodyTdHeight + 15 + DASHEDBOX_MARGIN + 20);

  String[] bodyTdPorts = drawBodyTd.getTdPorts();
  String[] tdPorts = new String[numFreeVars + 1];
  for (i = 0; i < numFreeVars; i++) {
    tdPorts[i] = TERMBOX_MARGIN_LEFT + bodyTdOffset + bodyTdPorts[i];
  }
  tdPorts[numFreeVars] = bodyTdOffset + bodyTdPorts[numFreeVars + 1];

  return new DrawTd() {
    float getTdWidth () { return tdWidth; }
    float getTdHeight () { return tdHeight; }
    float[] getTdPorts () { return tdPorts; }
    void go () {
      pushMatrix();
      drawTermBox(parsedTerm.prettyPrint(),
                  TERMBOX_MARGIN_LR + tdWidth, tdHeight * 2);

      translate(TERMBOX_MARGIN_LEFT, 0);
      drawPorts(tdHeight, tdPorts, freeVars);
      drawNamedRect("h", hWidth / 2, 0, hWidth, 10);
      // primitive: h

      pushMatrix();
      translate(bodyTdOffset, 0);
      drawBodyTd.go();
      // body
      drawDashedRect((bodyTdWidth + TERMBOX_MARGIN_LR) / 2, 0,
                     bodyTdWidth + TERMBOX_MARGIN_LR
                     + DASHEDBOX_MARGIN * 2,
                     (bodyTdHeight + 15 + DASHEDBOX_MARGIN) * 2);
      // dashed box
      
      translate(TERMBOX_MARGIN_LEFT, 0);
      float hiddenPort = (bodyTdPorts[numFreeVars]
                          + bodyTdPorts[numFreeVars + 1]) / 2;
      drawPsiPhi(bodyTdPorts[numFreeVars + 1],
                 bodyTdPorts[numFreeVars], bodyTdHeight + 10);
      // primitives: psi, phi
      drawPaths({bodyTdPorts[numFreeVars + 1], bodyTdHeight + 5,
            bodyTdPorts[numFreeVars + 1], bodyTdHeight});
      drawPaths({bodyTdPorts[numFreeVars], bodyTdHeight + 5,
            bodyTdPorts[numFreeVars], bodyTdHeight});
      drawPaths({hiddenPort, bodyTdHeight + 15 + DASHEDBOX_MARGIN,
            hiddenPort, bodyTdHeight + 15});
      // wires connected to psi & phi
      drawPrimitiveTdPair("v", "u", hiddenPort,
                          bodyTdHeight + 15 + DASHEDBOX_MARGIN + 5,
                          10, 10);
      // primitives: v, u
      for (int i = 0; i < numFreeVars; i++) {
        drawPrimitiveTdPair("d'", "d", bodyTdPorts[i],
                            bodyTdHeight + 15 + DASHEDBOX_MARGIN + 5,
                            10, 10);
        // primitives: d', d
        drawPaths({bodyTdPorts[i],
              bodyTdHeight + 15 + DASHEDBOX_MARGIN,
              bodyTdPorts[i], bodyTdHeight});
        drawPaths({bodyTdPorts[i], tdHeight, bodyTdPorts[i],
              bodyTdHeight + 15 + DASHEDBOX_MARGIN + 10});
        // wires connected to d', d
      }
      popMatrix();

      drawPaths({5, tdHeight, 5, 5});
      // the leftmost wires connected to h
      hiddenPort += TERMBOX_MARGIN_LEFT + bodyTdOffset;
      drawPaths({15, -5, 15, -10, 20 + CROSS_PADDING_HALF, -10,
            20 + CROSS_MARGIN - CROSS_PADDING_HALF,
            bodyTdHeight + 15 + DASHEDBOX_MARGIN + 15,
            hiddenPort, bodyTdHeight + 15 + DASHEDBOX_MARGIN + 15,
            hiddenPort, bodyTdHeight + 15 + DASHEDBOX_MARGIN + 10});
      // the crossing wires
      popMatrix();
    }
  }
}
