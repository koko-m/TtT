void testParse () {
  if (isTermReady()) {
    text(getTerm().print(), 100, 120);
    text(getTerm().prettyPrint(), 100, 140);
  }
}

void testTransducer () {
  Transducer td = new Transducer(1000, 50);
  int p0 = td.addPort(new Port(10, 15));
  int p1 = td.addPort(new Port(10, 5, HIDDEN, "in"));
  int p2 = td.addPort(new Port(10, -5, VISIBLE, "out"));
  int p3 = td.addPort(new Port(10, -15, HIDDEN));
  td.connectPorts(p0, {p1});
  td.connectPorts(p1, {p2});
  td.connectPorts(p2, {p3});
  td.addBox(new Box(LABELED_RECT_ONE, {"f"}, 0, 5, 20, 10));
  td.addBox(new Box(LABELED_RECT_PAIR, {"c", "c'"},
                    30, 15, 20, 10));
  td.addBox(new Box(TRI_PAIR_JOIN, {}, 60, 15, 20, 10));
  td.addBox(new Box(TRI_PAIR_SPLIT, {}, 90, 15, 30, 10));
  textSize(TEXT_SIZE_TERM);
  td.addBox(new Box(TERM_RECT, {"(lambda(x)(+x x))"},
                    130, 20, 20,
                    textWidth("(lambda(x)(+x x))")
                    + TEXT_MARGIN * 2));
  td.addBox(new Box(DASHED_RECT, {}, 160, 20, 50, 40));
  td.drawAll();
}

void testTdConstructorsPrim (boolean first) {
  console.log("******** test: primitives ********");
  pushMatrix();
  Transducer td = primH(UNIT_LENGTH * 2);
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = primK(3029486);
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = primK(0);
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = primSum(UNIT_LENGTH);
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = primSwap(UNIT_LENGTH);
  td.drawAll();
  td.debug(first);
  popMatrix();
}

void testTdConstructorsSeqComp (boolean first) {
  console.log("******** test: sequential composition ********");
  pushMatrix();
  Transducer td = seqCompPrimPairE(0, primK(3029486));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairE(0, primK(0));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairE(1, primSwap(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairE(0, primSwap(UNIT_LENGTH * 2));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 1, PAIR_P, SWAP,
                           primH(UNIT_LENGTH * 6));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(1, 2, PAIR_P, UNSWAP,
                           primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 1, PAIR_P, UNSWAP,
                           primSwap(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 1, PAIR_C, SWAP,
                           primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 1, PAIR_C, UNSWAP,
                           primSwap(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 2, PAIR_P, SWAP,
                           primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 2, PAIR_C, SWAP,
                           primSum(UNIT_LENGTH * 2));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 2, PAIR_P, UNSWAP,
                           primSum(UNIT_LENGTH * 2));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairJoin(0, 2, PAIR_C, UNSWAP,
                           primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairSplit(1, PAIR_P,
                            primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairSplit(1, PAIR_P,
                            primSum(UNIT_LENGTH * 3));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = seqCompPrimPairSplit(0, PAIR_C,
                            primH(UNIT_LENGTH * 5));
  td.drawAll();
  td.debug(first);
  popMatrix();
}

void testTdConstructorsParComp (boolean first) {
  console.log("******** test: parallel composition ********");
  pushMatrix();
  Transducer td = parCompPrimPairW(0, primH(UNIT_LENGTH * 2));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = parCompPrimPairW(1, primH(UNIT_LENGTH * 2));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = parCompPrimPairW(1, primH(UNIT_LENGTH * 3));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = parCompPrimPairW(0,
                        parCompPrimPairW(0, primH(UNIT_LENGTH * 2)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = parCompTd(UNIT_LENGTH * 2, primK(3029486),
                 parCompPrimPairW(1, primH(UNIT_LENGTH * 6)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = pullOutPort(1,
                   parCompPrimPairW(1, primH(UNIT_LENGTH * 2)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td =
    pullOutPort(2,
                parCompPrimPairW(0,
                                 parCompPrimPairW(0,
                                                  primH(UNIT_LENGTH
                                                        * 2))));
  td.drawAll();
  td.debug(first);
  popMatrix();
}

void testTdConstructorsConnect (boolean first) {
  console.log("******** test: connection ********");
  pushMatrix();
  Transducer td =
    makeCross(1,
              primH(UNIT_LENGTH * 2),
              1,
              seqCompPrimPairSplit(0, PAIR_C,
                                   primH(UNIT_LENGTH * 6)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = makeSwapLoops(1, 2,
                     seqCompPrimPairSplit(0, PAIR_C,
                                          primH(UNIT_LENGTH * 6)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = makeSwapLoops(0, 2,
                     seqCompPrimPairSplit(0, PAIR_P,
                                          primH(UNIT_LENGTH * 6)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = makeSwapLoops(0, 1,
                     primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = makeLoop(1,
                seqCompPrimPairSplit(0, PAIR_P,
                                     primH(UNIT_LENGTH * 6)));
  td.drawAll();
  td.debug(first);
  popMatrix();
}

void testTdConstructorsAddBox (boolean first) {
  console.log("******** test: box addition ********");
  pushMatrix();
  Transducer td =
    addChoiceBox(0.4,
                 primH(UNIT_LENGTH * 2),
                 seqCompPrimPairSplit(0, PAIR_P,
                                      primK(0)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addChoiceBox(0.00625,
                    primSum(UNIT_LENGTH),
                    seqCompPrimPairSplit(0, PAIR_C,
                                         primH(UNIT_LENGTH * 4)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addBangBox(primSum(UNIT_LENGTH));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addBangBox(primSum(UNIT_LENGTH * 4));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addBangBox(seqCompPrimPairSplit(0, PAIR_C,
                                       primK(0)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addBangBox(primK(0));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addBangBox(seqCompPrimPairSplit(0, PAIR_P,
                                       primH(UNIT_LENGTH * 2)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addTermBox("term", {"x", "y"},
                  seqCompPrimPairSplit(0, PAIR_P,
                                       primH(UNIT_LENGTH * 2)));
  td.drawAll();
  td.debug(first);
  translate(td.tdWidth + UNIT_LENGTH, 0);
  td = addTermBox("termtermtermtermterm", {"x"},
                  seqCompPrimPairSplit(0, PAIR_P,
                                       primH(UNIT_LENGTH * 2)));
  td.drawAll();
  td.debug(first);
  popMatrix();
}
