class Transducer {
  float leftX;
  float rightX;
  float bottomY;
  int[] inPortIds;          // arranged from right to left
  int[] outPortIds;         // arranged from right to left

  Transducer (float leftX, float rightX, float bottomY,
              int[] inPortIds, int[] outPortIds) {
    this.leftX = leftX;
    this.rightX = rightX;
    this.bottomY = bottomY;
    this.inPortIds = inPortIds;
    this.outPortIds = outPortIds;
  }

  void debug (boolean go) {
    if (go) console.log(this, this.inPortIds, this.outPortIds);
  }
}

// transducer constructors (who update given graphs)

Transducer _putPrimH (Graph graph, float[] portXs) {
  float leftX = portXs[1] - MARGIN_UNIT;
  float rightX = portXs[0] + MARGIN_UNIT;
  float boxWidth = rightX - leftX;
  float bottomY = MARGIN_UNIT;
  graph.addBox(new Box(LABELED_RECT_ONE, {"h"},
                       leftX, bottomY, boxWidth, bottomY * 2));
  int inRight = graph.addPort(new Port(portXs[0], bottomY, HIDDEN));
  int outRight = graph.addPort(new Port(portXs[0], -bottomY));
  int inLeft = graph.addPort(new Port(portXs[1], bottomY, HIDDEN));
  int outLeft = graph.addPort(new Port(portXs[1], -bottomY));
  graph.connectPorts(inRight, {outRight, outLeft});
  graph.connectPorts(inLeft, {outRight, outLeft});
  return new Transducer(leftX, rightX, bottomY,
                        {inRight, inLeft}, {outRight, outLeft});
}

Transducer _putPrimK (Graph graph, float leftX, String value) {
  String label = "k" + value;
  textSize(TEXT_SIZE_LABEL);
  float boxWidth = textWidth(label) + TEXT_MARGIN * 2;
  float bottomY = MARGIN_UNIT;
  graph.addBox(new Box(LABELED_RECT_ONE, {label},
                       leftX, bottomY, boxWidth, bottomY * 2));
  float centerX = leftX + boxWidth / 2;
  int inn = graph.addPort(new Port(centerX, bottomY, HIDDEN));
  int out = graph.addPort(new Port(centerX, -bottomY));
  graph.connectPorts(inn, {out});
  return new Transducer(leftX, leftX + boxWidth, bottomY,
                        {inn}, {out});
}

Transducer _putPrimSum (Graph graph, float leftX) {
  float boxWidth = MARGIN_UNIT * 6;
  float bottomY = MARGIN_UNIT;
  graph.addBox(new Box(LABELED_RECT_ONE, {"sum"},
                       leftX, bottomY, boxWidth, bottomY * 2));
  int inRight = graph.addPort(new Port(leftX + MARGIN_UNIT * 5,
                                       bottomY, HIDDEN));
  int outRight = graph.addPort(new Port(leftX + MARGIN_UNIT * 5,
                                       -bottomY));
  int inCenter = graph.addPort(new Port(leftX + MARGIN_UNIT * 3,
                                        bottomY, HIDDEN));
  int outCenter = graph.addPort(new Port(leftX + MARGIN_UNIT * 3,
                                         -bottomY));
  int inLeft = graph.addPort(new Port(leftX + MARGIN_UNIT,
                                      bottomY, HIDDEN));
  int outLeft = graph.addPort(new Port(leftX + MARGIN_UNIT,
                                       -bottomY));
  graph.connectPorts(inRight, {outCenter});
  graph.connectPorts(inCenter, {outLeft});
  graph.connectPorts(inLeft, {outRight});
  return new Transducer(leftX, leftX + boxWidth, bottomY,
                        {inRight, inCenter, inLeft},
                        {outRight, outCenter, outLeft});
}

Transducer _putPrimSwap (Graph graph, float[] portXs) {
  float bottomY = MARGIN_UNIT;
  int inRight = graph.addPort(new Port(portXs[0], bottomY));
  int outRight = graph.addPort(new Port(portXs[0], -bottomY));
  int inLeft = graph.addPort(new Port(portXs[1], bottomY));
  int outLeft = graph.addPort(new Port(portXs[1], -bottomY));
  graph.connectPorts(inRight, {outLeft});
  graph.connectPorts(inLeft, {outRight});
  return new Transducer(portXs[1], portXs[0], bottomY,
                        {inRight, inLeft}, {outRight, outLeft});
}

// compose the pair (e,e') to the 'portIndex-th ports
// e' is lower
Transducer _seqCompPrimPairE (Graph graph, Transducer td,
                              int portIndex) {
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = graph.getPort(inTd).x; // must be equal to
                                            // graph.getPort(outTd).x
  float boxHalfWidth = MARGIN_UNIT;
  float boxHeight = MARGIN_UNIT * 2;
  float boxBottomY = td.bottomY + MARGIN_UNIT + boxHeight;
  graph.addBox(new Box(LABELED_RECT_PAIR, {"e'", "e"},
                       boxCenterX - boxHalfWidth, boxBottomY,
                       boxHalfWidth * 2, boxHeight));
  int inLower = graph.addPort(new Port(boxCenterX, boxBottomY,
                                       HIDDEN));
  int outLower = graph.addPort(new Port(boxCenterX,
                                        boxBottomY - boxHeight));
  int inUpper = graph.addPort(new Port(boxCenterX,
                                       -boxBottomY + boxHeight,
                                       HIDDEN));
  int outUpper = graph.addPort (new Port(boxCenterX, -boxBottomY));
  graph.connectPorts(inLower, {outLower});
  graph.connectPorts(outLower, {inTd});
  graph.connectPorts(outTd, {inUpper});
  graph.connectPorts(inUpper, {outUpper});
  td.inPortIds[portIndex] = inLower;
  td.outPortIds[portIndex] = outUpper;
  return new Transducer(td.leftX, td.rightX, boxBottomY,
                        td.inPortIds, td.outPortIds);
}

// compose the pair (phi,psi) to the 'portIndex-th ports
// phi is lower: the ports are split
Transducer _seqCompPrimPairPhiPsi (Graph graph, Transducer td,
                                   int portIndex) {
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = graph.getPort(inTd).x; // must be equal to
                                            // graph.getPort(outTd).x
  float boxHalfWidth = MARGIN_UNIT * 2;
  float boxHeight = MARGIN_UNIT * 2;
  float boxBottomY = td.bottomY + MARGIN_UNIT + boxHeight;
  graph.addBox(new Box(TRI_PAIR_SPLIT, null,
                       boxCenterX - boxHalfWidth, boxBottomY,
                       boxHalfWidth * 2, boxHeight));
  int inLowerRight = graph.addPort(new Port(boxCenterX + MARGIN_UNIT,
                                            boxBottomY,
                                            HIDDEN));
  int inLowerLeft = graph.addPort(new Port(boxCenterX - MARGIN_UNIT,
                                            boxBottomY,
                                            HIDDEN));
  int outLower = graph.addPort(new Port(boxCenterX,
                                        boxBottomY - boxHeight));
  int inUpper = graph.addPort(new Port(boxCenterX,
                                       -boxBottomY + boxHeight,
                                       HIDDEN));
  int outUpperRight = graph.addPort(new Port(boxCenterX + MARGIN_UNIT,
                                             -boxBottomY));
  int outUpperLeft = graph.addPort(new Port(boxCenterX - MARGIN_UNIT,
                                            -boxBottomY));
  graph.connectPorts(inLowerRight, {outLower});
  graph.connectPorts(inLowerLeft, {outLower});
  graph.connectPorts(outLower, {inTd});
  graph.connectPorts(outTd, {inUpper});
  graph.connectPorts(inUpper, {outUpperRight});
  graph.connectPorts(inUpper, {outUpperLeft});
  td.inPortIds[portIndex] = inLowerLeft;
  td.inPortIds = splice(td.inPortIds, inLowerRight, portIndex);
  td.outPortIds[portIndex] = outUpperLeft;
  td.outPortIds = splice(td.outPortIds, outUpperRight, portIndex);
  return new Transducer(min(td.leftX, boxCenterX - boxHalfWidth),
                        max(td.rightX, boxCenterX + boxHalfWidth),
                        boxBottomY, td.inPortIds, td.outPortIds);
}

// boolean constants to specify connection wrt. the pair (c,c')
byte C_SWAP = true;
byte C_UNSWAP = false;

