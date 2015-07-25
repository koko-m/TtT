void testParse () {
  if (isTermReady()) {
    text(getTerm().print(), 100, 120);
    text(getTerm().prettyPrint(), 100, 140);
  }
}

void testGraph () {
  Graph graph = new Graph();
  int p0 = graph.addPort(new Port(0, 15));
  int p1 = graph.addPort(new Port(0, 5, HIDDEN, "in"));
  int p2 = graph.addPort(new Port(0, -5, VISIBLE, "out"));
  int p3 = graph.addPort(new Port(0, -15, HIDDEN));
  graph.connectPorts(p0, {p1});
  graph.connectPorts(p1, {p2});
  graph.connectPorts(p2, {p3});
  graph.addBox(new Box(LABELED_RECT_ONE, {"f"}, -10, 5, 20, 10));
  graph.addBox(new Box(LABELED_RECT_PAIR, {"c", "c'"},
                       20, 15, 20, 10));
  graph.addBox(new Box(TRI_PAIR_JOIN, {}, 50, 15, 20, 10));
  graph.addBox(new Box(TRI_PAIR_SPLIT, {}, 80, 15, 30, 10));
  textSize(TEXT_SIZE_TERM);
  graph.addBox(new Box(TERM_RECT, {"(lambda(x)(+x x))"},
                       120, 20, 20,
                       textWidth("(lambda(x)(+x x))")
                       + TEXT_MARGIN * 2));
  graph.addBox(new Box(DASHED_RECT, {}, 150, 20, 50, 40));
  graph.drawAll();
}

void testTdConstructorsPrim (first) {
  Graph graph = new Graph();
  Transducer td = _putPrimH(graph, {MARGIN_UNIT * 3, MARGIN_UNIT});
  td.debug(first);
  td = _putPrimK(graph, td.rightX + MARGIN_UNIT, 3029486);
  td.debug(first);
  td = _putPrimK(graph, td.rightX + MARGIN_UNIT, 0);
  td.debug(first);
  td = _putPrimSum(graph, td.rightX + MARGIN_UNIT);
  td.debug(first);
  td = _putPrimSwap(graph, {td.rightX + MARGIN_UNIT + MARGIN_UNIT * 2,
                            td.rightX + MARGIN_UNIT});
  td.debug(first);
  graph.drawAll();
}

void testTdConstructorsSeqComp (first) {
  Graph graph = new Graph();
  Transducer td = _seqCompPrimPairE(graph,
                                    _putPrimK(graph, 0, 3029486),
                                    0);
  td.debug(first);
  td = _seqCompPrimPairE(graph,
                         _putPrimK(graph, td.rightX + MARGIN_UNIT,
                                   1),
                         0);
  td.debug(first);
  td = _seqCompPrimPairE(graph,
                         _putPrimSwap(graph, {
                             td.rightX + MARGIN_UNIT + MARGIN_UNIT,
                             td.rightX + MARGIN_UNIT}),
                         1);
  td.debug(first);
  td = _seqCompPrimPairE(graph,
                         _putPrimSwap(graph, {
                             td.rightX + MARGIN_UNIT + MARGIN_UNIT,
                             td.rightX + MARGIN_UNIT}),
                         0);
  td.debug(first);
  td = _seqCompPrimPairJoin(graph,
                            _putPrimH(graph, {
                                td.rightX + MARGIN_UNIT * 2
                                + MARGIN_UNIT * 6,
                                td.rightX + MARGIN_UNIT * 2}),
                            0, 1, PAIR_P);
  td.debug(first);
  td = _seqCompPrimPairJoin(graph,
                            _putPrimSum(graph,
                                        td.rightX + MARGIN_UNIT),
                            0, 1, PAIR_P);
  td.debug(first);
  td = _seqCompPrimPairJoin(graph,
                            _putPrimSwap(graph, {
                                td.rightX + MARGIN_UNIT * 2
                                + MARGIN_UNIT,
                                td.rightX + MARGIN_UNIT * 2}),
                            0, 1, PAIR_P);
  td.debug(first);
  td = _seqCompPrimPairJoin(graph,
                            _putPrimSum(graph,
                                        td.rightX + MARGIN_UNIT),
                            1, 2, PAIR_C, SWAP);
  td.debug(first);
  td = _seqCompPrimPairJoin(graph,
                            _putPrimSum(graph,
                                        td.rightX + MARGIN_UNIT),
                            0, 2, PAIR_C, UNSWAP);
  td.debug(first);
  td = _seqCompPrimPairSplit(graph,
                             _putPrimSum(graph,
                                         td.rightX + MARGIN_UNIT),
                             1, PAIR_P);
  td.debug(first);
  td = _seqCompPrimPairSplit(graph,
                             _putPrimH(graph, {
                                 td.rightX + MARGIN_UNIT * 2
                                 + MARGIN_UNIT * 6,
                                 td.rightX + MARGIN_UNIT * 2}),
                             0, PAIR_C);
  td.debug(first);
  graph.drawAll();
}

void testTdConstructorsParComp (first) {
  Graph graph = new Graph();
  Transducer td = _parCompPrimPairW(graph,
                                    _putPrimH(graph, {
                                        MARGIN_UNIT
                                        + MARGIN_UNIT * 2,
                                        MARGIN_UNIT}),
                                    0);
  td.debug(first);
  Transducer td = _parCompPrimPairW(graph,
                                    _putPrimH(graph, {
                                        td.rightX + MARGIN_UNIT * 2
                                        + MARGIN_UNIT * 2,
                                        td.rightX + MARGIN_UNIT * 2}),
                                    1);
  td.debug(first);
  td = _parCompPrimPairW(graph,
                         _putPrimH(graph, {
                             td.rightX + MARGIN_UNIT * 2
                             + MARGIN_UNIT * 3,
                             td.rightX + MARGIN_UNIT * 2}),
                         1);
  td.debug(first);
  td = _parCompPrimPairW(graph,
                         _parCompPrimPairW(graph,
                                           _putPrimH(graph, {
                                               td.rightX
                                               + MARGIN_UNIT * 2
                                               + MARGIN_UNIT * 2,
                                               td.rightX
                                               + MARGIN_UNIT * 2}),
                                           0),
                         0);
  td.debug(first);
  graph.drawAll();
}
