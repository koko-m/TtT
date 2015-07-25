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

// sequentially compose the pair (e,e') at the `portIndex-th ports
// e' is lower
Transducer _seqCompPrimPairE (Graph graph, Transducer td,
                              int portIndex) {
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = graph.getPort(inTd).x; // must be equal to
                                            // graph.getPort(outTd).x
  float boxHalfWidth = MARGIN_UNIT;
  if (portIndex > 0) {
    float rightPortX = graph.getPort(td.inPortIds[portIndex - 1]).x;
    boxHalfWidth = min(boxHalfWidth, (rightPortX - boxCenterX) / 2);
    // avoid overlapping with the right ports
  }
  if (portIndex < td.inPortIds.length - 1) {
    float leftPortX = graph.getPort(td.inPortIds[portIndex + 1]).x;
    boxHalfWidth = min(boxHalfWidth, (boxCenterX - leftPortX) / 2);
    // avoid overlapping with the left ports
  }
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
  return new Transducer(min(td.leftX, boxCenterX - boxHalfWidth),
                        max(td.rightX, boxCenterX + boxHalfWidth),
                        boxBottomY, td.inPortIds, td.outPortIds);
}

// boolean constants to specify primitive pairs that *change*
// the number of ports
boolean PAIR_P = true;      // (phi,psi)
boolean PAIR_C = false;     // (c,c')

// boolean constants to specify whether to compose swappings with the
// pair (c,c')
boolean SWAP = true;
boolean UNSWAP = false;

// sequentially compose the pair (phi,psi) or (c,c') at the
// `portLeftIndex ports and 'portRightIndex ports
// psi or c' is lower: the ports are joined
Transducer _seqCompPrimPairJoin (Graph graph, Transducer td,
                                 int portRightIndex,
                                 int portLeftIndex,
                                 boolean pair) {
  return
    this(graph, td, portRightIndex, portLeftIndex, pair, UNSWAP);
}
Transducer _seqCompPrimPairJoin (Graph graph, Transducer td,
                                 int portRightIndex,
                                 int portLeftIndex,
                                 boolean pair, boolean swap) {
  if (!(portLeftIndex > portRightIndex)) {
    console.log("error _seqCompPrimPairJoin: portLeftIndex "
                + portLeftIndex + " exceeds portRightIndex "
                + portRightIndex);
    return null;
  }
  int inTdRight = td.inPortIds[portRightIndex];
  int outTdRight = td.outPortIds[portRightIndex];
  int inTdLeft = td.inPortIds[portLeftIndex];
  int outTdLeft = td.outPortIds[portLeftIndex];
  float inTdRightX = graph.getPort(inTdRight).x;
  float inTdLeftX = graph.getPort(inTdLeft).x;
  // these must be equal to those of outTdRight/outTdLeft
  float boxCenterX, boxHalfWidth;
  switch (pair) {
  case PAIR_P:
    // put each of the pair in the center of given two ports; they are
    // next to each other
    ////////////////////////
    // inTdLeft inTdRight //
    //       _|_|_        //
    //       \   /        //
    //        \_/         //
    //         |          //
    //    (boxCenterX)    //
    ////////////////////////
    boxCenterX = (inTdRightX + inTdLeftX) / 2;
    boxHalfWidth = (inTdRightX - inTdLeftX) / 2 + MARGIN_UNIT;
    if (portRightIndex > 0) {
      float rightPortX =
        graph.getPort(td.inPortIds[portRightIndex - 1]).x;
      boxHalfWidth = min(boxHalfWidth,
                         (rightPortX - inTdLeftX) / 2);
      // avoid overlapping with the right ports
    }
    if (portLeftIndex < td.inPortIds.length - 1) {
      float leftPortX =
        graph.getPort(td.inPortIds[portLeftIndex + 1]).x;
      boxHalfWidth = min(boxHalfWidth,
                         (inTdRightX - leftPortX) / 2);
      // avoid overlapping with the left ports
    }
    break;
  case PAIR_C:
    // put each of the pair near the given right port; given two ports
    // are (assumed) not next to each other
    if (swap) {
      /////////////////////////////
      // inTdLeft  inTdRight     //
      //     |_________|_____    //
      //              _|_____|_  //
      //             |    c'   | //
      //             |_________| //
      //                  |      //
      //            (boxCenterX) //
      /////////////////////////////
      boxCenterX = inTdRightX + MARGIN_UNIT;
      boxHalfWidth = MARGIN_UNIT * 2;
      if (portRightIndex > 0) {
        float rightPortX =
          graph.getPort(td.inPortIds[portRightIndex - 1]).x;
        boxCenterX = min(boxCenterX,
                         inTdRightX + (rightPortX - inTdRightX) / 4);
        boxHalfWidth = min(boxHalfWidth,
                           (rightPortX - inTdRightX) / 2);
        // avoid overlapping with the right ports
      }
      if (portRightIndex < td.inPortIds.length - 1) {
        float leftPortX =
          graph.getPort(td.inPortIds[portRightIndex + 1]).x;
        boxHalfWidth = min(boxHalfWidth,
                           MARGIN_UNIT
                           + (inTdRightX - leftPortX) / 2);
        // avoid overlapping with the left ports
      }
    } else {
      /////////////////////////
      // inTdLeft  inTdRight //
      //     |___      |     //
      //        _|_____|_    //
      //       |    c'   |   //
      //       |_________|   //
      //            |        //
      //       (boxCenterX)  //
      /////////////////////////
      boxCenterX = inTdRightX - MARGIN_UNIT;
      boxHalfWidth = MARGIN_UNIT * 2;
      if (portRightIndex > 0) {
        float rightPortX =
          graph.getPort(td.inPortIds[portRightIndex - 1]).x;
        boxHalfWidth = min(boxHalfWidth,
                           MARGIN_UNIT
                           + (rightPortX - inTdRightX) / 2);
        // avoid overlapping with the right ports
      }
      if (portRightIndex < td.inPortIds.length - 1) {
        float leftPortX =
          graph.getPort(td.inPortIds[portRightIndex + 1]).x;
        boxCenterX = max(boxCenterX,
                         inTdRightX - (inTdRightX - leftPortX) / 4);
        boxHalfWidth = min(boxHalfWidth,
                           (inTdRightX - leftPortX) / 2);
        // avoid overlapping with the left ports
      }
    }
    break;
  }
  float boxHeight = MARGIN_UNIT * 2;
  float boxBottomY;
  switch (pair) {
  case PAIR_P:
    boxBottomY = td.bottomY + MARGIN_UNIT + boxHeight;
    graph.addBox(new Box(TRI_PAIR_JOIN, null,
                         boxCenterX - boxHalfWidth, boxBottomY,
                         boxHalfWidth * 2, boxHeight));
    break;
  case PAIR_C:
    boxBottomY = td.bottomY + MARGIN_UNIT * 2 + boxHeight;
    graph.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                         boxCenterX - boxHalfWidth, boxBottomY,
                         boxHalfWidth * 2, boxHeight));
    break;
  }
  int inLower = graph.addPort(new Port(boxCenterX, boxBottomY,
                                       HIDDEN));
  int outLowerRight, outLowerLeft, inUpperRight, inUpperLeft;
  switch (pair) {
  case PAIR_P:
    outLowerRight = graph.addPort(new Port(inTdRightX,
                                           boxBottomY - boxHeight));
    outLowerLeft = graph.addPort(new Port(inTdLeftX,
                                          boxBottomY - boxHeight));
    inUpperRight = graph.addPort(new Port(inTdRightX,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    inUpperLeft = graph.addPort(new Port(inTdLeftX,
                                         -boxBottomY + boxHeight,
                                         HIDDEN));
    break;
  case PAIR_C:
    outLowerRight = graph.addPort(new Port(boxCenterX
                                           + boxHalfWidth / 2,
                                           boxBottomY - boxHeight));
    outLowerLeft = graph.addPort(new Port(boxCenterX
                                          - boxHalfWidth / 2,
                                          boxBottomY - boxHeight));
    inUpperRight = graph.addPort(new Port(boxCenterX
                                          + boxHalfWidth / 2,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    inUpperLeft = graph.addPort(new Port(boxCenterX
                                         - boxHalfWidth / 2,
                                         -boxBottomY + boxHeight,
                                         HIDDEN));
    break;
  }
  int outUpper = graph.addPort(new Port(boxCenterX, -boxBottomY));
  graph.connectPorts(inLower, {outLowerRight, outLowerLeft});
  switch (pair) {
  case PAIR_P:
    graph.connectPorts(outLowerRight, {inTdRight});
    graph.connectPorts(outLowerLeft, {inTdLeft});
    graph.connectPorts(outTdRight, {inUpperRight});
    graph.connectPorts(outTdLeft, {inUpperLeft});
    break;
  case PAIR_C:
    if (swap) {
      graph.connectPorts(outLowerRight, {inTdLeft},
                         {{boxCenterX + boxHalfWidth / 2,
                               boxBottomY - boxHeight - MARGIN_UNIT,
                               inTdLeftX, td.bottomY + MARGIN_UNIT}});
      graph.connectPorts(outLowerLeft, {inTdRight});
      graph.connectPorts(outTdRight, {inUpperLeft});
      graph.connectPorts(outTdLeft, {inUpperRight},
                         {{inTdLeftX, -td.bottomY - MARGIN_UNIT,
                               boxCenterX + boxHalfWidth / 2,
                               -boxBottomY + boxHeight
                               + MARGIN_UNIT}});
    } else {
      graph.connectPorts(outLowerRight, {inTdRight});
      graph.connectPorts(outLowerLeft, {inTdLeft},
                         {{boxCenterX - boxHalfWidth / 2,
                               boxBottomY - boxHeight - MARGIN_UNIT,
                               inTdLeftX, td.bottomY + MARGIN_UNIT}});
      graph.connectPorts(outTdRight, {inUpperRight});
      graph.connectPorts(outTdLeft, {inUpperLeft},
                         {{inTdLeftX, -td.bottomY - MARGIN_UNIT,
                               boxCenterX - boxHalfWidth / 2,
                               -boxBottomY + boxHeight
                               + MARGIN_UNIT}});
    }
    break;
  }
  graph.connectPorts(inUpperRight, {outUpper});
  graph.connectPorts(inUpperLeft, {outUpper});

  td.inPortIds[portRightIndex] = inLower;
  td.inPortIds = concat(subset(td.inPortIds, 0, portLeftIndex),
                        subset(td.inPortIds, portLeftIndex + 1));
  td.outPortIds[portRightIndex] = outUpper;
  td.outPortIds = concat(subset(td.outPortIds, 0, portLeftIndex),
                        subset(td.outPortIds, portLeftIndex + 1));
  return new Transducer(min(td.leftX, boxCenterX - boxHalfWidth),
                        max(td.rightX, boxCenterX + boxHalfWidth),
                        boxBottomY, td.inPortIds, td.outPortIds);
}

// compose the pair (phi,psi) or (c,c') at the
// `portIndex-th ports
// phi or c is lower: the ports are split
Transducer _seqCompPrimPairSplit (Graph graph, Transducer td,
                                  int portIndex, boolean pair) {
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = graph.getPort(inTd).x; // must be equal to
                                            // graph.getPort(outTd).x
  float boxHalfWidth = MARGIN_UNIT * 2;
  if (portIndex > 0) {
    float rightPortX = graph.getPort(td.inPortIds[portIndex - 1]).x;
    boxHalfWidth = min(boxHalfWidth, (rightPortX - boxCenterX) / 2);
    // avoid overlapping with the right ports
  }
  if (portIndex < td.inPortIds.length - 1) {
    float leftPortX = graph.getPort(td.inPortIds[portIndex + 1]).x;
    boxHalfWidth = min(boxHalfWidth, (boxCenterX - leftPortX) / 2);
    // avoid overlapping with the left ports
  }
  float boxHeight = MARGIN_UNIT * 2;
  float boxBottomY = td.bottomY + MARGIN_UNIT + boxHeight;
  switch (pair) {
  case PAIR_P:
    graph.addBox(new Box(TRI_PAIR_SPLIT, null,
                         boxCenterX - boxHalfWidth, boxBottomY,
                         boxHalfWidth * 2, boxHeight));
    break;
  case PAIR_C:
    graph.addBox(new Box(LABELED_RECT_PAIR, {"c", "c'"},
                         boxCenterX - boxHalfWidth, boxBottomY,
                         boxHalfWidth * 2, boxHeight));
    break;
  }
  int inLowerRight = graph.addPort(new Port(boxCenterX
                                            + boxHalfWidth / 2,
                                            boxBottomY,
                                            HIDDEN));
  int inLowerLeft = graph.addPort(new Port(boxCenterX
                                           - boxHalfWidth / 2,
                                            boxBottomY,
                                            HIDDEN));
  int outLower = graph.addPort(new Port(boxCenterX,
                                        boxBottomY - boxHeight));
  int inUpper = graph.addPort(new Port(boxCenterX,
                                       -boxBottomY + boxHeight,
                                       HIDDEN));
  int outUpperRight = graph.addPort(new Port(boxCenterX
                                             + boxHalfWidth / 2,
                                             -boxBottomY));
  int outUpperLeft = graph.addPort(new Port(boxCenterX
                                            - boxHalfWidth / 2,
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

// compose the pair (w,w') in parallel at the right of the
// `portIndex-th ports
// w' is lower: new ports are added
Transducer _parCompPrimPairW (Graph graph, Transducer td,
                              int portIndex) {
  float boxCenterX, boxHalfWidth;
  if (portIndex > 0) {
    float leftPortX = graph.getPort(td.inPortIds[portIndex]).x;
    float rightPortX = graph.getPort(td.inPortIds[portIndex - 1]).x;
    boxCenterX = (rightPortX + leftPortX) / 2;
    boxHalfWidth = min(MARGIN_UNIT, (rightPortX - leftPortX) / 4);
    // avoid overlapping with the left ports
  } else {
    boxCenterX = td.rightX + MARGIN_UNIT * 2;
    boxHalfWidth = MARGIN_UNIT;
  }
  float boxHeight = MARGIN_UNIT * 2;
  float boxBottomY = MARGIN_UNIT + boxHeight;
  if (portIndex > 0) boxBottomY += td.bottomY;
  graph.addBox(new Box(LABELED_RECT_PAIR, {"w'", "w"},
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
  graph.connectPorts(inUpper, {outUpper});
  td.inPortIds = splice(td.inPortIds, inLower, portIndex);
  td.outPortIds = splice(td.outPortIds, outUpper, portIndex);
  return new Transducer(min(td.leftX, boxCenterX - boxHalfWidth),
                        max(td.rightX, boxCenterX + boxHalfWidth),
                        boxBottomY, td.inPortIds, td.outPortIds);
}

// compose given two transducers and make a cross connection
Transducer _makeCross(Graph graph,
                      Transducer leftTd, int portRightIndex,
                      Transducer rightTd, int portLeftIndex) {
  float interval = rightTd.leftX - leftTd.rightX;
  if (interval <= 0) {
    console.log("error _makeCross: leftTd.rightX "
                + leftTd.rightX + " exceeds rightTd.leftX "
                + rightTd.leftX);
    return null;
  }
  int inRightTd = rightTd.inPortIds[portRightIndex];
  int outRightTd = rightTd.outPortIds[portRightIndex];
  int inLeftTd = leftTd.inPortIds[portLeftIndex];
  int outLeftTd = leftTd.outPortIds[portLeftIndex];
  graph.connectPorts(outLeftTd, {inRightTd},
                     {{graph.getPort(outLeftTd).x,
                           -leftTd.bottomY - MARGIN_UNIT,
                           leftTd.rightX + interval / 6,
                           -leftTd.bottomY - MARGIN_UNIT,
                           rightTd.leftX - interval / 6,
                           rightTd.bottomY + MARGIN_UNIT,
                           graph.getPort(inRightTd).x,
                           rightTd.bottomY + MARGIN_UNIT}});
  graph.connectPorts(outRightTd, {inLeftTd},
                     {{graph.getPort(outRightTd).x,
                           -rightTd.bottomY - MARGIN_UNIT,
                           rightTd.leftX - interval / 6,
                           -rightTd.bottomY - MARGIN_UNIT,
                           leftTd.rightX + interval / 6,
                           leftTd.bottomY + MARGIN_UNIT,
                           graph.getPort(inLeftTd).x,
                           leftTd.bottomY + MARGIN_UNIT}});
  int[] rightInPortIds
    = concat(subset(rightTd.inPortIds, 0, portRightIndex),
             subset(rightTd.inPortIds, portRightIndex + 1));
  int[] rightOutPortIds
    = concat(subset(rightTd.outPortIds, 0, portRightIndex),
             subset(rightTd.outPortIds, portRightIndex + 1));
  int[] leftInPortIds
    = concat(subset(leftTd.inPortIds, 0, portLeftIndex),
             subset(leftTd.inPortIds, portLeftIndex + 1));
  int[] leftOutPortIds
    = concat(subset(leftTd.outPortIds, 0, portLeftIndex),
             subset(leftTd.outPortIds, portLeftIndex + 1));
  return new Transducer(leftTd.leftX, rightTd.rightX,
                        max(leftTd.bottomY, rightTd.bottomY) +
                        MARGIN_UNIT,
                        concat(rightInPortIds, leftInPortIds),
                        concat(rightOutPortIds, leftOutPortIds));
}

// make self loops with swapping
Transducer _makeSwapLoops (Graph graph, Transducer td,
                           int portRightIndex, int portLeftIndex) {
  if (!(portLeftIndex > portRightIndex)) {
    console.log("error _makeSwapLoops: portLeftIndex "
                + portLeftIndex + " exceeds portRightIndex "
                + portRightIndex);
    return null;
  }
  int inRight = td.inPortIds[portRightIndex];
  int outRight = td.outPortIds[portRightIndex];
  int inLeft = td.inPortIds[portLeftIndex];
  int outLeft = td.outPortIds[portLeftIndex];
  graph.connectPorts(outRight, {inLeft},
                     {{graph.getPort(outRight).x,
                           -td.bottomY - MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           -td.bottomY - MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           -MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT * 2,
                           MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT * 2,
                           td.bottomY + MARGIN_UNIT * 2,
                           graph.getPort(inLeft).x,
                           td.bottomY + MARGIN_UNIT * 2}});
  graph.connectPorts(outLeft, {inRight},
                     {{graph.getPort(outLeft).x,
                           -td.bottomY - MARGIN_UNIT * 2,
                           td.rightX + MARGIN_UNIT * 2,
                           -td.bottomY - MARGIN_UNIT * 2,
                           td.rightX + MARGIN_UNIT * 2,
                           -MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           td.bottomY + MARGIN_UNIT,
                           graph.getPort(inRight).x,
                           td.bottomY + MARGIN_UNIT}});
  td.inPortIds = concat(subset(td.inPortIds, 0, portLeftIndex),
                        subset(td.inPortIds, portLeftIndex + 1));
  td.inPortIds = concat(subset(td.inPortIds, 0, portRightIndex),
                        subset(td.inPortIds, portRightIndex + 1));
  td.outPortIds = concat(subset(td.outPortIds, 0, portLeftIndex),
                        subset(td.outPortIds, portLeftIndex + 1));
  td.outPortIds = concat(subset(td.outPortIds, 0, portRightIndex),
                        subset(td.outPortIds, portRightIndex + 1));
  return new Transducer(td.leftX, td.rightX + MARGIN_UNIT * 2,
                        td.bottomY + MARGIN_UNIT * 2,
                        td.inPortIds, td.outPortIds);
}

// make a self loop
Transducer _makeLoop (Graph graph, Transducer td, int portIndex) {
  int inn = td.inPortIds[portIndex];
  int out = td.outPortIds[portIndex];
  graph.connectPorts(out, {inn},
                     {{graph.getPort(out).x,
                           -td.bottomY - MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           -td.bottomY - MARGIN_UNIT,
                           td.rightX + MARGIN_UNIT,
                           td.bottomY + MARGIN_UNIT,
                           graph.getPort(inn).x,
                           td.bottomY + MARGIN_UNIT}});
  td.inPortIds = concat(subset(td.inPortIds, 0, portIndex),
                        subset(td.inPortIds, portIndex + 1));
  td.outPortIds = concat(subset(td.outPortIds, 0, portIndex),
                        subset(td.outPortIds, portIndex + 1));
  return new Transducer(td.leftX, td.rightX + MARGIN_UNIT,
                        td.bottomY + MARGIN_UNIT,
                        td.inPortIds, td.outPortIds);
}
