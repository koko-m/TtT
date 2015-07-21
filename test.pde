void testPrint (Object parsedTerm) {
  textAlign(LEFT, CENTER);
  text(parsedTerm.print(), 0, 20);
  text(parsedTerm.prettyPrint(), 0, 40);
}

void testDraw (Object parsedTerm) {
  switch (parsedTerm.tag) {
  case "var":
    pushMatrix();
    DrawTd drawTd;
    // FV = {this}
    String[] freeVars = new String[parsedTerm.parameters.length];
    arrayCopy(parsedTerm.parameters, freeVars);
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    // FV = {this, "yy"}
    translate(drawTd.getTdWidth() + TERM_MARGIN_LR + TEST_MARGIN_LR,
              0);
    freeVars = append(freeVars, "yy");
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    // FV = {"xx", this, "yy"}
    translate(drawTd.getTdWidth() + TERM_MARGIN_LR + TEST_MARGIN_LR,
              0);
    freeVars = concat({"xx"}, freeVars);
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    // FV = {"xx", this}
    translate(drawTd.getTdWidth() + TERM_MARGIN_LR + TEST_MARGIN_LR,
              0);
    freeVars = shorten(freeVars);
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    // FV = {"xx"}
    translate(drawTd.getTdWidth() + TERM_MARGIN_LR + TEST_MARGIN_LR,
              0);
    freeVars = shorten(freeVars);
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    // FV = {}
    translate(drawTd.getTdWidth() + TERM_MARGIN_LR + TEST_MARGIN_LR,
              0);
    freeVars = shorten(freeVars);
    drawTd = getDrawTd(parsedTerm, freeVars);
    drawTd.go();
    popMatrix();
  }
}

