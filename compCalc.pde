// transducer constructors (destructive)

Transducer primH (float portInterval) {
  textSize(TEXT_SIZE_LABEL);
  float tdWidth = portInterval + UNIT_LENGTH * 2;
  float tdHalfHeight = UNIT_LENGTH;
  Transducer td = new Transducer(tdWidth, tdHalfHeight);
  td.addBox(new Box(LABELED_RECT_ONE, {"h"},
                    0, tdHalfHeight, tdWidth, tdHalfHeight * 2));
  int inRight = td.addPort(new Port(UNIT_LENGTH + portInterval,
                                    tdHalfHeight, HIDDEN));
  int outRight = td.addPort(new Port(UNIT_LENGTH + portInterval,
                                     -tdHalfHeight));
  int inLeft = td.addPort(new Port(UNIT_LENGTH, tdHalfHeight, HIDDEN));
  int outLeft = td.addPort(new Port(UNIT_LENGTH, -tdHalfHeight));
  td.connectPorts(inRight, {outRight, outLeft});
  td.connectPorts(inLeft, {outRight, outLeft});
  td.setInPortIds({inRight, inLeft});
  td.setOutPortIds({outRight, outLeft});
  return td;
}

Transducer primK (String value) {
  textSize(TEXT_SIZE_LABEL);
  float tdWidth = textWidth(value) + TEXT_MARGIN * 2;
  float tdHalfHeight = UNIT_LENGTH;
  Transducer td = new Transducer(tdWidth, tdHalfHeight);
  td.addBox(new Box(LABELED_RECT_ONE, {"k" + value},
                    0, tdHalfHeight, tdWidth, tdHalfHeight * 2));
  int inn = td.addPort(new Port(tdWidth / 2, tdHalfHeight, HIDDEN));
  int out = td.addPort(new Port(tdWidth / 2, -tdHalfHeight));
  td.connectPorts(inn, {out});
  td.setInPortIds({inn});
  td.setOutPortIds({out});
  return td;
}

Transducer primSum (float portInterval) {
  textSize(TEXT_SIZE_LABEL);
  float tdWidth = portInterval * 2 + UNIT_LENGTH * 2;
  float tdHalfHeight = UNIT_LENGTH;
  Transducer td = new Transducer(tdWidth, tdHalfHeight);
  td.addBox(new Box(LABELED_RECT_ONE, {"sum"},
                    0, tdHalfHeight, tdWidth, tdHalfHeight * 2));
  int inRight = td.addPort(new Port(UNIT_LENGTH + portInterval * 2,
                                    tdHalfHeight, HIDDEN));
  int outRight = td.addPort(new Port(UNIT_LENGTH + portInterval * 2,
                                     -tdHalfHeight));
  int inCenter = td.addPort(new Port(UNIT_LENGTH + portInterval,
                                     tdHalfHeight, HIDDEN));
  int outCenter = td.addPort(new Port(UNIT_LENGTH + portInterval,
                                      -tdHalfHeight));
  int inLeft = td.addPort(new Port(UNIT_LENGTH, tdHalfHeight,
                                   HIDDEN));  
  int outLeft = td.addPort(new Port(UNIT_LENGTH, -tdHalfHeight));
  td.connectPorts(inRight, {outCenter});
  td.connectPorts(inCenter, {outLeft});
  td.connectPorts(inLeft, {outRight});
  td.setInPortIds({inRight, inCenter, inLeft});
  td.setOutPortIds({outRight, outCenter, outLeft});
  return td;
}

Transducer primSwap (float portInterval) {
  textSize(TEXT_SIZE_LABEL);
  float tdWidth = portInterval;
  float tdHalfHeight = UNIT_LENGTH;
  Transducer td = new Transducer(tdWidth, tdHalfHeight);
  int inRight = td.addPort(new Port(portInterval, tdHalfHeight));
  int outRight = td.addPort(new Port(portInterval, -tdHalfHeight));
  int inLeft = td.addPort(new Port(0, tdHalfHeight));
  int outLeft = td.addPort(new Port(0, -tdHalfHeight));
  td.connectPorts(inRight, {outLeft});
  td.connectPorts(inLeft, {outRight});
  td.setInPortIds({inRight, inLeft});
  td.setOutPortIds({outRight, outLeft});
  return td;
}

// sequentially compose the primitive pair (e,e') at the
// portIndex-th ports
// e' is lower
Transducer seqCompPrimPairE (int portIndex, Transducer td) {
  //////////////  //////////////
  // | td  |  //  // outUpper //
  // |_____|  //  //   _|_    //
  //    |     //  //  | e |   //
  //  inTd    //  //  |___|   //
  //    |     //  //    |     //
  // outLower //  // inUpper  //
  //   _|_    //  //    |     //
  //  | e'|   //  //  outTd   //
  //  |___|   //  //  __|__   //
  //    |     //  // |     |  //
  // inLower  //  // | td  |  //
  //////////////  //////////////
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = td.getPort(inTd).x; // must be equal to that of
                                         // outTd
  float boxHalfWidth = UNIT_LENGTH;
  if (portIndex > 0) {
    // portIndex-th ports have neighbors on the right
    boxHalfWidth = min(boxHalfWidth,
                       (td.getPort(td.inPortIds[portIndex - 1]).x
                        - td.getPort(td.inPortIds[portIndex]).x) / 2);
    // avoid overlapping with the right ports
  }
  if (portIndex < td.inPortIds.length - 1) {
    // portIndex-th ports have neighbors on the left
    boxHalfWidth = min(boxHalfWidth,
                       (td.getPort(td.inPortIds[portIndex]).x
                        - td.getPort(td.inPortIds[portIndex + 1]).x)
                       / 2);
    // avoid overlapping with the left ports
  }
  float boxHeight = UNIT_LENGTH * 2;
  float boxBottomY = td.tdHalfHeight + UNIT_LENGTH + boxHeight;
  td.addBox(new Box(LABELED_RECT_PAIR, {"e'", "e"},
                    boxCenterX - boxHalfWidth, boxBottomY,
                    boxHalfWidth * 2, boxHeight));
  int inLower = td.addPort(new Port(boxCenterX, boxBottomY, HIDDEN));
  int outLower = td.addPort(new Port(boxCenterX,
                                     boxBottomY - boxHeight));
  int inUpper = td.addPort(new Port(boxCenterX,
                                    -boxBottomY + boxHeight, HIDDEN));
  int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
  td.connectPorts(inLower, {outLower});
  td.connectPorts(outLower, {inTd});
  td.connectPorts(outTd, {inUpper});
  td.connectPorts(inUpper, {outUpper});
  td.replaceInPortId(portIndex, inLower);
  td.replaceOutPortId(portIndex, outUpper);
  td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
  if (boxCenterX - boxHalfWidth < 0) {
    td.shiftX(-(boxCenterX - boxHalfWidth));
    td.tdWidth += -(boxCenterX - boxHalfWidth);
  }
  td.tdHalfHeight = boxBottomY;
  return td;
}

// boolean constants to specify primitive pairs that *change*
// the number of ports
boolean PAIR_P = true;      // (phi,psi)
boolean PAIR_C = false;     // (c,c')

// boolean constants to specify whether to compose swappings with the
// primitive pair
boolean SWAP = true;
boolean UNSWAP = false;

// sequentially compose the primitive pair (phi,psi) or (c,c') at the
// portLeftIndex-ports and the portRightIndex-ports
// the pair is put in the center of given two ports
// psi or c' is lower: the ports are joined
Transducer seqCompPrimPairJoinCenter (int portRightIndex,
                                      int portLeftIndex,
                                      boolean pair, boolean swap,
                                      Transducer td) {
  int inTdRight = td.inPortIds[portRightIndex];
  int outTdRight = td.outPortIds[portRightIndex];
  int inTdLeft = td.inPortIds[portLeftIndex];
  int outTdLeft = td.outPortIds[portLeftIndex];
  ////////////////////////////////  ////////////////////////////////
  //        |   td    |         //  //          outUpper          //
  //        |_________|         //  //           __|__            //
  //            | |             //  //          |     | phi or c  //
  //     inTdLeft inTdRight     //  //          |_____|           //
  //            | |             //  //            | |             //
  //    (swapping, possibly)    //  //  inUpperLeft inUpperRight  //
  //            | |             //  //            | |             //
  // outLowerLeft outLowerRight //  //    (swapping, possibly)    //
  //           _|_|_            //  //            | |             //
  //          |     |           //  //    outTdLeft outTdRight    //
  //          |_____| psi or c' //  //         ___|_|___          //
  //             |              //  //        |         |         //
  //          inLower           //  //        |   td    |         //
  ////////////////////////////////  ////////////////////////////////
  float boxCenterX =
    (td.getPort(inTdRight).x + td.getPort(inTdLeft).x) / 2;
  float widthMargin = UNIT_LENGTH;
  if (portRightIndex > 0) {
    // portRightIndex-th ports have neighbors on the right
    widthMargin =
      min(widthMargin,
          (td.getPort(td.inPortIds[portRightIndex - 1]).x
           - td.getPort(td.inPortIds[portRightIndex]).x) / 2);
    // avoid overlapping with the right ports
  }
  if (portLeftIndex < td.inPortIds.length - 1) {
    // portLeftIndex-th ports have neighbors on the left
    widthMargin =
      min(widthMargin,
          (td.getPort(td.inPortIds[portLeftIndex]).x
           - td.getPort(td.inPortIds[portLeftIndex + 1]).x) / 2);
    // avoid overlapping with the left ports
  }
  float boxHalfWidth =
    (td.getPort(inTdRight).x - td.getPort(inTdLeft).x) / 2
    + widthMargin;
  float boxHeight;
  switch (pair) {
  case PAIR_P: boxHeight = UNIT_LENGTH; break;
  case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
  }
  float boxBottomY = td.tdHalfHeight + UNIT_LENGTH + boxHeight;
  if (swap) boxBottomY += UNIT_LENGTH * 2;
  switch (pair) {
  case PAIR_P:
    td.addBox(new Box(TRI_PAIR_JOIN, {},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    break;
  case PAIR_C:
    td.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    break;
  }
  int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                    HIDDEN));
  int outLowerRight = td.addPort(new Port(td.getPort(inTdRight).x,
                                          boxBottomY - boxHeight));
  int outLowerLeft = td.addPort(new Port(td.getPort(inTdLeft).x,
                                         boxBottomY - boxHeight));
  int inUpperRight = td.addPort(new Port(td.getPort(outTdRight).x,
                                         -boxBottomY + boxHeight,
                                         HIDDEN));
  int inUpperLeft = td.addPort(new Port(td.getPort(outTdLeft).x,
                                        -boxBottomY + boxHeight,
                                        HIDDEN));
  int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
  td.connectPorts(inLower, {outLowerRight, outLowerLeft});
  if (swap) {
    td.connectPorts(outLowerRight, {inTdLeft},
                    {{td.getPort(inTdRight).x,
                          td.tdHalfHeight + UNIT_LENGTH * 2,
                          td.getPort(inTdLeft).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outLowerLeft, {inTdRight},
                    {{td.getPort(inTdLeft).x,
                          td.tdHalfHeight + UNIT_LENGTH * 2,
                          td.getPort(inTdRight).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outTdRight, {inUpperLeft},
                    {{td.getPort(inTdRight).x,
                          - td.tdHalfHeight - UNIT_LENGTH,
                          td.getPort(inTdLeft).x,
                          -td.tdHalfHeight - UNIT_LENGTH * 2}});
    td.connectPorts(outTdLeft, {inUpperRight},
                    {{td.getPort(inTdLeft).x,
                          - td.tdHalfHeight - UNIT_LENGTH,
                          td.getPort(inTdRight).x,
                          -td.tdHalfHeight - UNIT_LENGTH * 2}});
  } else {
    td.connectPorts(outLowerRight, {inTdRight});
    td.connectPorts(outLowerLeft, {inTdLeft});
    td.connectPorts(outTdRight, {inUpperRight});
    td.connectPorts(outTdLeft, {inUpperLeft});
  }
  td.connectPorts(inUpperRight, {outUpper});
  td.connectPorts(inUpperLeft, {outUpper});
  td.replaceInPortId(portRightIndex, inLower);
  td.removeInPortId(portLeftIndex);
  td.replaceOutPortId(portRightIndex, outUpper);
  td.removeOutPortId(portLeftIndex);
  td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
  if (boxCenterX - boxHalfWidth < 0) {
    td.shiftX(-(boxCenterX - boxHalfWidth));
    td.tdWidth += -(boxCenterX - boxHalfWidth);
  }
  td.tdHalfHeight = boxBottomY;
  return td;
}

// sequentially compose the primitive pair (phi,psi) or (c,c') at the
// portLeftIndex-ports and the portRightIndex-ports
// the pair is put near the portRightIndex-ports
// psi or c' is lower: the ports are joined
Transducer seqCompPrimPairJoinRight (int portRightIndex,
                                     int portLeftIndex,
                                     boolean pair, boolean swap,
                                     Transducer td) {
  int inTdRight = td.inPortIds[portRightIndex];
  int outTdRight = td.outPortIds[portRightIndex];
  int inTdLeft = td.inPortIds[portLeftIndex];
  int outTdLeft = td.outPortIds[portLeftIndex];
  if (swap) {
    ////////////////////////////////  ////////////////////////////////
    //    |   td    |             //  //          outUpper          //
    //    |_________|             //  //           __|__            //
    //      |     |               //  //          |     | phi or c  //
    //   inTdLeft inTdRight       //  //          |_____|           //
    //      |_____|_              //  //            | |             //
    //            | |             //  //  inUpperLeft inUpperRight  //
    // outLowerLeft outLowerRight //  //       _____|_|             //
    //           _|_|_            //  //      |     |               //
    //          |     |           //  //  outTdLeft outTdRight      //
    //          |_____| psi or c' //  //     _|_____|_              //
    //             |              //  //    |         |             //
    //          inLower           //  //    |   td    |             //
    ////////////////////////////////  ////////////////////////////////
    float boxCenterX = td.getPort(inTdRight).x + UNIT_LENGTH;
    float boxHalfWidth = UNIT_LENGTH * 2;
    if (portRightIndex > 0) {
      // portRightIndex-th ports have neighbors on the right
      boxCenterX =
        min(boxCenterX,
            td.getPort(inTdRight).x
            + (td.getPort(td.inPortIds[portRightIndex - 1]).x
               - td.getPort(td.inPortIds[portRightIndex]).x) / 4);
      boxHalfWidth =
        min(boxHalfWidth,
            (td.getPort(td.inPortIds[portRightIndex - 1]).x
             - td.getPort(td.inPortIds[portRightIndex]).x) / 2);
      // avoid overlapping with the right ports
    }
    if (portRightIndex < td.inPortIds.length - 1) {
      // portRightIndex-th ports have neighbors on the left
      boxCenterX =
        min(boxCenterX,
            td.getPort(inTdRight).x
            + (td.getPort(td.inPortIds[portRightIndex]).x
               - td.getPort(td.inPortIds[portRightIndex + 1]).x) / 2);
      boxHalfWidth =
        min(boxHalfWidth,
            td.getPort(td.inPortIds[portRightIndex]).x
            - td.getPort(td.inPortIds[portRightIndex + 1]).x);
      // avoid overlapping with the left ports
    }
    float boxHeight;
    switch (pair) {
    case PAIR_P: boxHeight = UNIT_LENGTH; break;
    case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
    }
    float boxBottomY = td.tdHalfHeight + UNIT_LENGTH * 2 + boxHeight;
    switch (pair) {
    case PAIR_P:
      td.addBox(new Box(TRI_PAIR_JOIN, {},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    case PAIR_C:
      td.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    }
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLowerRight = td.addPort(new Port(boxCenterX
                                            + boxHalfWidth / 2,
                                            boxBottomY - boxHeight));
    int outLowerLeft = td.addPort(new Port(td.getPort(inTdRight).x,
                                           boxBottomY - boxHeight));
    int inUpperRight = td.addPort(new Port(boxCenterX
                                           + boxHalfWidth / 2,
                                           -boxBottomY + boxHeight,
                                           HIDDEN));
    int inUpperLeft = td.addPort(new Port(td.getPort(outTdRight).x,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLowerRight, outLowerLeft});
    td.connectPorts(outLowerRight, {inTdLeft},
                    {{boxCenterX + boxHalfWidth / 2,
                          td.tdHalfHeight + UNIT_LENGTH,
                          td.getPort(inTdLeft).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outLowerLeft, {inTdRight});
    td.connectPorts(outTdRight, {inUpperLeft});
    td.connectPorts(outTdLeft, {inUpperRight},
                    {{td.getPort(outTdLeft).x,
                          -td.tdHalfHeight - UNIT_LENGTH,
                          boxCenterX + boxHalfWidth / 2,
                          -td.tdHalfHeight - UNIT_LENGTH}});
    td.connectPorts(inUpperRight, {outUpper});
    td.connectPorts(inUpperLeft, {outUpper});
    td.replaceInPortId(portRightIndex, inLower);
    td.removeInPortId(portLeftIndex);
    td.replaceOutPortId(portRightIndex, outUpper);
    td.removeOutPortId(portLeftIndex);
    td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
    if (boxCenterX - boxHalfWidth < 0) {
      td.shiftX(-(boxCenterX - boxHalfWidth));
      td.tdWidth += -(boxCenterX - boxHalfWidth);
    }
    td.tdHalfHeight = boxBottomY;
    return td;
  } else {
    ////////////////////////////////  ////////////////////////////////
    //      |   td    |           //  //          outUpper          //
    //      |_________|           //  //           __|__            //
    //        |     |             //  //          |     | phi or c  //
    //     inTdLeft inTdRight     //  //          |_____|           //
    //        |___  |             //  //            | |             //
    //            | |             //  //  inUpperLeft inUpperRight  //
    // outLowerLeft outLowerRight //  //         ___| |             //
    //           _|_|_            //  //        |     |             //
    //          |     |           //  //    outTdLeft outTdRight    //
    //          |_____| psi or c' //  //       _|_____|_            //
    //             |              //  //      |         |           //
    //          inLower           //  //      |   td    |           //
    ////////////////////////////////  ////////////////////////////////
    float boxCenterX = td.getPort(inTdRight).x - UNIT_LENGTH;
    float boxHalfWidth = UNIT_LENGTH * 2;
    if (portRightIndex > 0) {
      // portRightIndex-th ports have neighbors on the right
      boxCenterX =
        max(boxCenterX,
            td.getPort(inTdRight).x
            - (td.getPort(td.inPortIds[portRightIndex - 1]).x
               - td.getPort(td.inPortIds[portRightIndex]).x) / 2);
      boxHalfWidth =
        min(boxHalfWidth,
            td.getPort(td.inPortIds[portRightIndex - 1]).x
            - td.getPort(td.inPortIds[portRightIndex]).x);
      // avoid overlapping with the right ports
    }
    if (portRightIndex < td.inPortIds.length - 1) {
      // portRightIndex-th ports have neighbors on the left
      boxCenterX =
        max(boxCenterX,
            td.getPort(inTdRight).x
            - (td.getPort(td.inPortIds[portRightIndex]).x
               - td.getPort(td.inPortIds[portRightIndex + 1]).x) / 4);
      boxHalfWidth =
        min(boxHalfWidth,
            (td.getPort(td.inPortIds[portRightIndex]).x
             - td.getPort(td.inPortIds[portRightIndex + 1]).x) / 2);
      // avoid overlapping with the left ports
    }
    float boxHeight;
    switch (pair) {
    case PAIR_P: boxHeight = UNIT_LENGTH; break;
    case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
    }
    float boxBottomY = td.tdHalfHeight + UNIT_LENGTH * 2 + boxHeight;
    switch (pair) {
    case PAIR_P:
      td.addBox(new Box(TRI_PAIR_JOIN, {},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    case PAIR_C:
      td.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    }
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLowerRight = td.addPort(new Port(td.getPort(inTdRight).x,
                                            boxBottomY - boxHeight));
    int outLowerLeft = td.addPort(new Port(boxCenterX
                                           - boxHalfWidth / 2,
                                           boxBottomY - boxHeight));
    int inUpperRight = td.addPort(new Port(td.getPort(outTdRight).x,
                                           -boxBottomY + boxHeight,
                                           HIDDEN));
    int inUpperLeft = td.addPort(new Port(boxCenterX
                                          - boxHalfWidth / 2,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLowerRight, outLowerLeft});
    td.connectPorts(outLowerRight, {inTdRight});
    td.connectPorts(outLowerLeft, {inTdLeft},
                    {{boxCenterX - boxHalfWidth / 2,
                          td.tdHalfHeight + UNIT_LENGTH,
                          td.getPort(inTdLeft).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outTdRight, {inUpperRight});
    td.connectPorts(outTdLeft, {inUpperLeft},
                    {{td.getPort(outTdLeft).x,
                          -td.tdHalfHeight - UNIT_LENGTH,
                          boxCenterX - boxHalfWidth / 2,
                          -td.tdHalfHeight - UNIT_LENGTH}});
    td.connectPorts(inUpperRight, {outUpper});
    td.connectPorts(inUpperLeft, {outUpper});
    td.replaceInPortId(portRightIndex, inLower);
    td.removeInPortId(portLeftIndex);
    td.replaceOutPortId(portRightIndex, outUpper);
    td.removeOutPortId(portLeftIndex);
    td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
    if (boxCenterX - boxHalfWidth < 0) {
      td.shiftX(-(boxCenterX - boxHalfWidth));
      td.tdWidth += -(boxCenterX - boxHalfWidth);
    }
    td.tdHalfHeight = boxBottomY;
    return td;
  }
}

// sequentially compose the primitive pair (phi,psi) or (c,c') at the
// portLeftIndex-ports and the portRightIndex-ports
// the pair is put near the portLeftIndex-ports
// psi or c' is lower: the ports are joined
Transducer seqCompPrimPairJoinLeft (int portRightIndex,
                                    int portLeftIndex,
                                    boolean pair, boolean swap,
                                    Transducer td) {
  int inTdRight = td.inPortIds[portRightIndex];
  int outTdRight = td.outPortIds[portRightIndex];
  int inTdLeft = td.inPortIds[portLeftIndex];
  int outTdLeft = td.outPortIds[portLeftIndex];
  if (swap) {
    ////////////////////////////////  ////////////////////////////////
    //            |   td    |     //  //         outUpper           //
    //            |_________|     //  //           __|__            //
    //              |     |       //  //          |     | phi or c  //
    //       inTdLeft  inTdRight  //  //          |_____|           //
    //             _|_____|       //  //            | |             //
    //            | |             //  //  inUpperLeft inUpperRight  //
    // outLowerLeft outLowerRight //  //            |_|_____        //
    //           _|_|_            //  //              |     |       //
    //          |     |           //  //      outTdLeft  outTdRight //
    //          |_____| psi or c' //  //             _|_____|_      //
    //             |              //  //            |         |     //
    //          inLower           //  //            |   td    |     //
    ////////////////////////////////  ////////////////////////////////
    float boxCenterX = td.getPort(inTdLeft).x - UNIT_LENGTH;
    float boxHalfWidth = UNIT_LENGTH * 2;
    if (portLeftIndex > 0) {
      // portLeftIndex-th ports have neighbors on the right
      boxCenterX =
        max(boxCenterX,
            td.getPort(inTdLeft).x
            - (td.getPort(td.inPortIds[portLeftIndex - 1]).x
               - td.getPort(td.inPortIds[portLeftIndex]).x) / 2);
      boxHalfWidth =
        min(boxHalfWidth,
            td.getPort(td.inPortIds[portLeftIndex - 1]).x
            - td.getPort(td.inPortIds[portLeftIndex]).x);
      // avoid overlapping with the right ports
    }
    if (portLeftIndex < td.inPortIds.length - 1) {
      // portLeftIndex-th ports have neighbors on the left
      boxCenterX =
        max(boxCenterX,
            td.getPort(inTdLeft).x
            - (td.getPort(td.inPortIds[portLeftIndex]).x
               - td.getPort(td.inPortIds[portLeftIndex + 1]).x) / 4);
      boxHalfWidth =
        min(boxHalfWidth,
            (td.getPort(td.inPortIds[portLeftIndex]).x
             - td.getPort(td.inPortIds[portLeftIndex + 1]).x) / 2);
      // avoid overlapping with the left ports
    }
    float boxHeight;
    switch (pair) {
    case PAIR_P: boxHeight = UNIT_LENGTH; break;
    case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
    }
    float boxBottomY = td.tdHalfHeight + UNIT_LENGTH * 2 + boxHeight;
    switch (pair) {
    case PAIR_P:
      td.addBox(new Box(TRI_PAIR_JOIN, {},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    case PAIR_C:
      td.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    }
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLowerRight = td.addPort(new Port(td.getPort(inTdLeft).x,
                                            boxBottomY - boxHeight));
    int outLowerLeft = td.addPort(new Port(boxCenterX
                                           - boxHalfWidth / 2,
                                           boxBottomY - boxHeight));
    int inUpperRight = td.addPort(new Port(td.getPort(outTdLeft).x,
                                           -boxBottomY + boxHeight,
                                           HIDDEN));
    int inUpperLeft = td.addPort(new Port(boxCenterX
                                          - boxHalfWidth / 2,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLowerRight, outLowerLeft});
    td.connectPorts(outLowerRight, {inTdLeft});
    td.connectPorts(outLowerLeft, {inTdRight},
                    {{boxCenterX - boxHalfWidth / 2,
                          td.tdHalfHeight + UNIT_LENGTH,
                          td.getPort(inTdRight).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outTdRight, {inUpperLeft},
                    {{td.getPort(outTdRight).x,
                          -td.tdHalfHeight - UNIT_LENGTH,
                          boxCenterX - boxHalfWidth / 2,
                          -td.tdHalfHeight - UNIT_LENGTH}});
    td.connectPorts(outTdLeft, {inUpperRight});
    td.connectPorts(inUpperRight, {outUpper});
    td.connectPorts(inUpperLeft, {outUpper});
    td.replaceInPortId(portRightIndex, inLower);
    td.removeInPortId(portLeftIndex);
    td.replaceOutPortId(portRightIndex, outUpper);
    td.removeOutPortId(portLeftIndex);
    td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
    if (boxCenterX - boxHalfWidth < 0) {
      td.shiftX(-(boxCenterX - boxHalfWidth));
      td.tdWidth += -(boxCenterX - boxHalfWidth);
    }
    td.tdHalfHeight = boxBottomY;
    return td;
  } else {
    ////////////////////////////////  ////////////////////////////////
    //          |   td    |       //  //         outUpper           //
    //          |_________|       //  //           __|__            //
    //            |     |         //  //          |     | phi or c  //
    //     inTdLeft  inTdRight    //  //          |_____|           //
    //            |  ___|         //  //            | |             //
    //            | |             //  //  inUpperLeft inUpperRight  //
    // outLowerLeft outLowerRight //  //            | |___          //
    //           _|_|_            //  //            |     |         //
    //          |     |           //  //    outTdLeft  outTdRight   //
    //          |_____| psi or c' //  //           _|_____|_        //
    //             |              //  //          |         |       //
    //          inLower           //  //          |   td    |       //
    ////////////////////////////////  ////////////////////////////////
    float boxCenterX = td.getPort(inTdRight).x + UNIT_LENGTH;
    float boxHalfWidth = UNIT_LENGTH * 2;
    if (portLeftIndex > 0) {
      // portLeftIndex-th ports have neighbors on the right
      boxCenterX =
        min(boxCenterX,
            td.getPort(inTdLeft).x
            + (td.getPort(td.inPortIds[portLeftIndex - 1]).x
               - td.getPort(td.inPortIds[portLeftIndex]).x) / 4);
      boxHalfWidth =
        min(boxHalfWidth,
            (td.getPort(td.inPortIds[portLeftIndex - 1]).x
             - td.getPort(td.inPortIds[portLeftIndex]).x) / 2);
      // avoid overlapping with the right ports
    }
    if (portLeftIndex < td.inPortIds.length - 1) {
      // portLeftIndex-th ports have neighbors on the left
      boxCenterX =
        min(boxCenterX,
            td.getPort(inTdLeft).x
            + (td.getPort(td.inPortIds[portLeftIndex]).x
               - td.getPort(td.inPortIds[portLeftIndex + 1]).x) / 2);
      boxHalfWidth =
        min(boxHalfWidth,
            td.getPort(td.inPortIds[portLeftIndex]).x
            - td.getPort(td.inPortIds[portLeftIndex + 1]).x);
      // avoid overlapping with the left ports
    }
    float boxHeight;
    switch (pair) {
    case PAIR_P: boxHeight = UNIT_LENGTH; break;
    case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
    }
    float boxBottomY = td.tdHalfHeight + UNIT_LENGTH * 2 + boxHeight;
    switch (pair) {
    case PAIR_P:
      td.addBox(new Box(TRI_PAIR_JOIN, {},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    case PAIR_C:
      td.addBox(new Box(LABELED_RECT_PAIR, {"c'", "c"},
                        boxCenterX - boxHalfWidth, boxBottomY,
                        boxHalfWidth * 2, boxHeight));
      break;
    }
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLowerRight = td.addPort(new Port(boxCenterX
                                            + boxHalfWidth / 2,
                                            boxBottomY - boxHeight));
    int outLowerLeft = td.addPort(new Port(td.getPort(inTdLeft).x,
                                           boxBottomY - boxHeight));
    int inUpperRight = td.addPort(new Port(boxCenterX
                                           + boxHalfWidth / 2,
                                           -boxBottomY + boxHeight,
                                           HIDDEN));
    int inUpperLeft = td.addPort(new Port(td.getPort(outTdLeft).x,
                                          -boxBottomY + boxHeight,
                                          HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLowerRight, outLowerLeft});
    td.connectPorts(outLowerRight, {inTdRight},
                    {{boxCenterX + boxHalfWidth / 2,
                          td.tdHalfHeight + UNIT_LENGTH,
                          td.getPort(inTdRight).x,
                          td.tdHalfHeight + UNIT_LENGTH}});
    td.connectPorts(outLowerLeft, {inTdLeft});
    td.connectPorts(outTdRight, {inUpperRight},
                    {{td.getPort(outTdRight).x,
                          -td.tdHalfHeight - UNIT_LENGTH,
                          boxCenterX + boxHalfWidth / 2,
                          -td.tdHalfHeight - UNIT_LENGTH}});
    td.connectPorts(outTdLeft, {inUpperLeft});
    td.connectPorts(inUpperRight, {outUpper});
    td.connectPorts(inUpperLeft, {outUpper});
    td.replaceInPortId(portRightIndex, inLower);
    td.removeInPortId(portLeftIndex);
    td.replaceOutPortId(portRightIndex, outUpper);
    td.removeOutPortId(portLeftIndex);
    td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
    if (boxCenterX - boxHalfWidth < 0) {
      td.shiftX(-(boxCenterX - boxHalfWidth));
      td.tdWidth += -(boxCenterX - boxHalfWidth);
    }
    td.tdHalfHeight = boxBottomY;
    return td;
  }
}

// sequentially compose the primitive pair (phi,psi) or (c,c') at the
// portIndex-ports
// phi or c is lower: the ports are split
Transducer seqCompPrimPairSplit (int portIndex, boolean pair,
                                 Transducer td) {
  ////////////////////////////////  ////////////////////////////////
  //          | td  |           //  // outUpperLeft outUpperRight //
  //          |_____|           //  //           _|_|_            //
  //             |              //  //          |     | psi or c' //
  //           inTd             //  //          |_____|           //
  //             |              //  //             |              //
  //          outLower          //  //          inUpper           //
  //           __|__            //  //             |              //
  //          |     |           //  //           outTd            //
  //          |_____| phi or c  //  //           __|__            //
  //            | |             //  //          |     |           //
  //  inLowerLeft inLowerRight  //  //          | td  |           //
  ////////////////////////////////  ////////////////////////////////
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float boxCenterX = td.getPort(inTd).x; // must be equal to that of
                                         // outTd
  float boxHalfWidth = UNIT_LENGTH * 2;
  if (portIndex > 0) {
    // portIndex-th ports have neighbors on the right
    boxHalfWidth = min(boxHalfWidth,
                       (td.getPort(td.inPortIds[portIndex - 1]).x
                        - td.getPort(td.inPortIds[portIndex]).x)
                       * 3 / 4);
    // avoid overlapping with the right ports
  }
  if (portIndex < td.inPortIds.length - 1) {
    // portIndex-th ports have neighbors on the left
    boxHalfWidth = min(boxHalfWidth,
                       (td.getPort(td.inPortIds[portIndex]).x
                        - td.getPort(td.inPortIds[portIndex + 1]).x)
                       * 3 / 4);
    // avoid overlapping with the left ports
  }
  float boxHeight;
  switch (pair) {
  case PAIR_P: boxHeight = UNIT_LENGTH; break;
  case PAIR_C: boxHeight = UNIT_LENGTH * 2; break;
  }
  float boxBottomY = td.tdHalfHeight + UNIT_LENGTH + boxHeight;
  switch (pair) {
  case PAIR_P:
    td.addBox(new Box(TRI_PAIR_SPLIT, {},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    break;
  case PAIR_C:
    td.addBox(new Box(LABELED_RECT_PAIR, {"c", "c'"},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    break;
  }
  int inLowerRight = td.addPort(new Port(boxCenterX
                                         + boxHalfWidth / 2,
                                         boxBottomY, HIDDEN));
  int inLowerLeft = td.addPort(new Port(boxCenterX
                                        - boxHalfWidth / 2,
                                        boxBottomY, HIDDEN));
  int outLower = td.addPort(new Port(boxCenterX,
                                     boxBottomY - boxHeight));
  int inUpper = td.addPort(new Port(boxCenterX,
                                    -boxBottomY + boxHeight, HIDDEN));
  int outUpperRight = td.addPort(new Port(boxCenterX
                                          + boxHalfWidth / 2,
                                          -boxBottomY));
  int outUpperLeft = td.addPort(new Port(boxCenterX
                                         - boxHalfWidth / 2,
                                         -boxBottomY));
  td.connectPorts(inLowerRight, {outLower});
  td.connectPorts(inLowerLeft, {outLower});
  td.connectPorts(outLower, {inTd});
  td.connectPorts(outTd, {inUpper});
  td.connectPorts(inUpper, {outUpperRight, outUpperLeft});
  td.replaceInPortId(portIndex, inLowerLeft);
  td.insertInPortId(inLowerRight, portIndex);
  td.replaceOutPortId(portIndex, outUpperLeft);
  td.insertOutPortId(outUpperRight, portIndex);
  td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
  if (boxCenterX - boxHalfWidth < 0) {
    td.shiftX(-(boxCenterX - boxHalfWidth));
    td.tdWidth += -(boxCenterX - boxHalfWidth);
  }
  td.tdHalfHeight = boxBottomY;
  return td;
}

// compose the pair (w,w') in parallel at the right of the
// `portIndex-th ports
// w' is lower: new ports are added
Transducer parCompPrimPairW (int portIndex, Transducer td) {
  if (portIndex > 0) {
    // portIndex-th ports have neighbors on the right
    ///////////////  ///////////////
    // |  td   | //  //  outUpper //
    // |_______| //  //   __|__   //
    //   |   |   //  //  |  w  |  //
    // inTd  .   //  //  |_____|  //
    //           //  //     :     //
    //  outLower //  //  inUpper  //
    //   __:__   //  //           //
    //  |  w' |  //  // outTd .   //
    //  |_____|  //  //  _|___|_  //
    //     |     //  // |       | //
    //  inLower  //  // |  td   | //
    ///////////////  ///////////////
    // int inTd = td.inPortIds[portIndex];
    // int outTd = td.outPortIds[portIndex];
    float boxCenterX =
      (td.getPort(td.inPortIds[portIndex - 1]).x
       + td.getPort(td.inPortIds[portIndex]).x) / 2;
    float boxHalfWidth =
      min(UNIT_LENGTH,
          (td.getPort(td.inPortIds[portIndex - 1]).x
           - td.getPort(td.inPortIds[portIndex]).x) / 4);
    float boxHeight = UNIT_LENGTH * 2;
    float boxBottomY = td.tdHalfHeight + UNIT_LENGTH + boxHeight;
    td.addBox(new Box(LABELED_RECT_PAIR, {"w'", "w"},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLower = td.addPort(new Port(boxCenterX,
                                       boxBottomY - boxHeight));
    int inUpper = td.addPort(new Port(boxCenterX,
                                      -boxBottomY + boxHeight,
                                      HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLower});
    td.connectPorts(inUpper, {outUpper});
    td.insertInPortId(inLower, portIndex);
    td.insertOutPortId(outUpper, portIndex);
    td.tdHalfHeight = boxBottomY;
    return td;
  } else {
    // portIndex-th ports are rightmost
    ///////////////////////  ///////////////////////
    // |     |  outLower //  // outTd    outLower //
    // |     |   __|__   //  //  __|__    __|__   //
    // | td  |  |  w' |  //  // |     |  |  w  |  //
    // |_____|  |_____|  //  // | td  |  |_____|  //
    //    |        |     //  // |     |     |     //
    //  inTd    inLower  //  // |     |  inUpper  //
    ///////////////////////  ///////////////////////
    float boxCenterX = td.tdWidth + UNIT_LENGTH * 2;
    float boxHalfWidth = UNIT_LENGTH;
    float boxHeight = UNIT_LENGTH * 2;
    float boxBottomY = UNIT_LENGTH / 2 + boxHeight;
    td.addBox(new Box(LABELED_RECT_PAIR, {"w'", "w"},
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLower = td.addPort(new Port(boxCenterX,
                                       boxBottomY - boxHeight));
    int inUpper = td.addPort(new Port(boxCenterX,
                                      -boxBottomY + boxHeight,
                                      HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLower});
    td.connectPorts(inUpper, {outUpper});
    td.insertInPortId(inLower, portIndex);
    td.insertOutPortId(outUpper, portIndex);
    td.tdWidth = boxCenterX + boxHalfWidth;
    td.tdHalfHeight = max(td.tdHalfHeight, boxBottomY);
    return td;
  }
}

// pull out portIndex-th ports to the right
Transducer pullOutPort (int portIndex, Transducer td) {
  ///////////////////  ///////////////////
  // |   td   |    //  //           out //
  // |________|    //  //    ________|  //
  //   |    |      //  //   |           //
  //  inTd  .      //  //  outTd .      //
  //   |________   //  //  _|____|_     //
  //            |  //  // |        |    //
  //           inn //  // |   td   |    //
  ///////////////////  ///////////////////
  if (portIndex == 0) return td;
  int inTd = td.inPortIds[portIndex];
  int outTd = td.outPortIds[portIndex];
  float portX = td.tdWidth + UNIT_LENGTH;
  float portY = td.tdHalfHeight + UNIT_LENGTH * 2;
  int inn = td.addPort(new Port(portX, portY));
  int out = td.addPort(new Port(portX, -portY));
  td.connectPorts(inn, {inTd},
                  {{portX, portY - UNIT_LENGTH,
                        td.getPort(inTd).x, portY - UNIT_LENGTH}});
  td.connectPorts(outTd, {out},
                  {{td.getPort(outTd).x, -portY + UNIT_LENGTH,
                        portX, -portY + UNIT_LENGTH}});
  td.removeInPortId(portIndex);
  td.removeOutPortId(portIndex);
  td.insertInPortId(inn, 0);
  td.insertOutPortId(out, 0);
  td.tdWidth += UNIT_LENGTH;
  td.tdHalfHeight = portY;
  return td;
}

// combine rightTd in parallel with leftTd
// this is destructive: rightTd is shifted and leftTd is combined
Transducer parCompTd (float interval,
                      Transducer leftTd, Transducer rightTd) {
  float shiftX = leftTd.tdWidth + interval;
  float shiftId = leftTd.ports.length;
  rightTd.shiftX(shiftX);
  rightTd.shiftId(shiftId);
  leftTd.ports = concat(leftTd.ports, rightTd.ports);
  leftTd.boxes = concat(leftTd.boxes, rightTd.boxes);
  leftTd.tdWidth += interval + rightTd.tdWidth;
  leftTd.tdHalfHeight = max(leftTd.tdHalfHeight,
                            rightTd.tdHalfHeight);
  leftTd.inPortIds = concat(rightTd.inPortIds, leftTd.inPortIds);
  leftTd.outPortIds = concat(rightTd.outPortIds, leftTd.outPortIds);
  return leftTd;
}

// make a cross connection between two transducers
Transducer makeCross (int portLeftIndex, Transducer leftTd,
                      int portRightIndex, Transducer rightTd) {
  float cornerLeftX = leftTd.tdWidth + CROSS_INTERVAL / 6;
  float cornerRightX = cornerLeftX + CROSS_INTERVAL * 2 / 3;
  float cornerTopY = -leftTd.tdHalfHeight - UNIT_LENGTH;
  float cornerBottomY = rightTd.tdHalfHeight + UNIT_LENGTH;
  leftTd = parCompTd(CROSS_INTERVAL, leftTd, rightTd);
  portLeftIndex += rightTd.inPortIds.length;
  int inRightTd = leftTd.inPortIds[portRightIndex];
  int outRightTd = leftTd.outPortIds[portRightIndex];
  int inLeftTd = leftTd.inPortIds[portLeftIndex];
  int outLeftTd = leftTd.outPortIds[portLeftIndex];
  float sourceX = leftTd.getPort(inLeftTd).x;
  float targetX = leftTd.getPort(inRightTd).x;
  leftTd.connectPorts(outLeftTd, {inRightTd},
                      {{sourceX, cornerTopY,
                            cornerLeftX, cornerTopY,
                            cornerRightX, cornerBottomY,
                            targetX, cornerBottomY}});
  leftTd.connectPorts(outRightTd, {inLeftTd},
                      {{targetX, -cornerBottomY,
                            cornerRightX, -cornerBottomY,
                            cornerLeftX, -cornerTopY,
                            sourceX, -cornerTopY}});
  leftTd.removeInPortId(portLeftIndex);
  leftTd.removeOutPortId(portLeftIndex);
  leftTd.removeInPortId(portRightIndex);
  leftTd.removeOutPortId(portRightIndex);
  leftTd.tdHalfHeight += UNIT_LENGTH;
  return leftTd;
}

// make self loops with swapping
Transducer makeSwapLoops (int portRightIndex, int portLeftIndex,
                          Transducer td) {
  if (!(portLeftIndex > portRightIndex)) {
    console.log("error makeSwapLoops: portLeftIndex "
                + portLeftIndex + " exceeds portRightIndex "
                + portRightIndex);
    return null;
  }
  int inRight = td.inPortIds[portRightIndex];
  int outRight = td.outPortIds[portRightIndex];
  int inLeft = td.inPortIds[portLeftIndex];
  int outLeft = td.outPortIds[portLeftIndex];
  float swapHalfHeight = min(UNIT_LENGTH, td.tdHalfHeight);
  td.connectPorts(outRight, {inLeft},
                  {{td.getPort(outRight).x,
                        -td.tdHalfHeight - UNIT_LENGTH,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL,
                        -td.tdHalfHeight - UNIT_LENGTH,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL,
                        -swapHalfHeight,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL * 2,
                        swapHalfHeight,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL * 2,
                        td.tdHalfHeight + UNIT_LENGTH * 2,
                        td.getPort(inLeft).x,
                        td.tdHalfHeight + UNIT_LENGTH * 2}});
  td.connectPorts(outLeft, {inRight},
                  {{td.getPort(outLeft).x,
                        -td.tdHalfHeight - UNIT_LENGTH * 2,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL * 2,
                        -td.tdHalfHeight - UNIT_LENGTH * 2,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL * 2,
                        -swapHalfHeight,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL,
                        swapHalfHeight,
                        td.tdWidth + SWAP_LOOP_X_INTERVAL,
                        td.tdHalfHeight + UNIT_LENGTH,
                        td.getPort(inRight).x,
                        td.tdHalfHeight + UNIT_LENGTH}});
  td.removeInPortId(portLeftIndex);
  td.removeOutPortId(portLeftIndex);
  td.removeInPortId(portRightIndex);
  td.removeOutPortId(portRightIndex);
  td.tdWidth += SWAP_LOOP_X_INTERVAL * 2;
  td.tdHalfHeight += UNIT_LENGTH * 2;
  return td;
}

// make a self loop
Transducer makeLoop (int portIndex, Transducer td) {
  int inn = td.inPortIds[portIndex];
  int out = td.outPortIds[portIndex];
  td.connectPorts(out, {inn},
                  {{td.getPort(out).x,
                        -td.tdHalfHeight - UNIT_LENGTH,
                        td.tdWidth + UNIT_LENGTH,
                        -td.tdHalfHeight - UNIT_LENGTH,
                        td.tdWidth + UNIT_LENGTH,
                        td.tdHalfHeight + UNIT_LENGTH,
                        td.getPort(inn).x,
                        td.tdHalfHeight + UNIT_LENGTH}});
  td.removeInPortId(portIndex);
  td.removeOutPortId(portIndex);
  td.tdWidth += UNIT_LENGTH;
  td.tdHalfHeight += UNIT_LENGTH;
  return td;
}

// add a probabilistic choice box
Transducer addChoiceBox (float prob,
                         Transducer leftTd, Transducer rightTd) {
  if (leftTd.inPortIds.length != rightTd.inPortIds.length) {
    console.log("error addChoiceBox: leftTd.inPortIds.length "
                + leftTd.inPortIds.length
                + " is not equal to rightTd.inPortIds.length "
                + rightTd.inPortIds.length);
    return null;
  }
  int numIOPorts = leftTd.inPortIds.length;
  String label = "choose(" + prob + ")";
  textSize(TEXT_SIZE_LABEL);
  float interval = textWidth(label) + TEXT_MARGIN * 2;
  float labelCenterX = UNIT_LENGTH + leftTd.tdWidth + interval / 2;
  leftTd = parCompTd(interval, leftTd, rightTd);
  leftTd.shiftX(UNIT_LENGTH);
  leftTd.tdWidth += UNIT_LENGTH * 2;
  leftTd.tdHalfHeight += UNIT_LENGTH;
  leftTd.addBoxHead(new Box(LABELED_RECT_ONE, {label}, labelCenterX,
                            0, leftTd.tdHalfHeight,
                            leftTd.tdWidth, leftTd.tdHalfHeight * 2));
  Port[] newInPortIds = new Port[0];
  Port[] newOutPortIds = new Port[0];
  for (i = 0; i < numIOPorts; i++) {
    int inn, out;
    if (i < numIOPorts - 1) {
      inn =
        leftTd.addPort(new Port(leftTd.getPort(leftTd.inPortIds[i]).x,
                                leftTd.tdHalfHeight, HIDDEN));
      out =
        leftTd.addPort(new Port(leftTd.getPort(leftTd.inPortIds[i]).x,
                                -leftTd.tdHalfHeight));
    } else {                    // leftmost ports
      inn =
        leftTd.addPort
        (new Port(leftTd.getPort(leftTd.inPortIds[i + numIOPorts]).x,
                                leftTd.tdHalfHeight, HIDDEN));
      out =
        leftTd.addPort
        (new Port(leftTd.getPort(leftTd.inPortIds[i + numIOPorts]).x,
                                -leftTd.tdHalfHeight));
    }
    leftTd.connectPorts(inn,
                        {leftTd.inPortIds[i],
                            leftTd.inPortIds[i + numIOPorts]});
    leftTd.connectPorts(leftTd.outPortIds[i], {out});
    leftTd.connectPorts(leftTd.outPortIds[i + numIOPorts], {out});
    leftTd.getPort(leftTd.outPortIds[i]).hide();
    leftTd.getPort(leftTd.outPortIds[i + numIOPorts]).hide();
    newInPortIds = append(newInPortIds, inn);
    newOutPortIds = append(newOutPortIds, out);
  }
  leftTd.inPortIds = newInPortIds;
  leftTd.outPortIds = newOutPortIds;
  return leftTd;
}

// add a bang box (dashed box) with primitive pairs (u,v) and (d,d')
// v and d' are lower
Transducer addBangBox (Transducer td) {
  float boxHeight = UNIT_LENGTH * 2;
  float boxBottomY = td.tdHalfHeight + UNIT_LENGTH + boxHeight;
  for (i = 0; i < td.inPortIds.length; i++) {
    int inTd = td.inPortIds[i];
    int outTd = td.outPortIds[i];
    float boxCenterX = td.getPort(inTd).x; // must be equal to that of
                                           // outTd
    float boxHalfWidth = UNIT_LENGTH;
    if (i > 0) {
      // i-th ports have neighbors on the right
      boxHalfWidth = min(boxHalfWidth,
                         (td.getPort(td.inPortIds[i - 1]).x
                          - td.getPort(td.inPortIds[i]).x) * 0.4);
      // avoid overlapping with the right ports
    }
    if (i < td.inPortIds.length - 1) {
      // i-th ports have neighbors on the left
      boxHalfWidth = min(boxHalfWidth,
                         (td.getPort(td.inPortIds[i]).x
                          - td.getPort(td.inPortIds[i + 1]).x) * 0.4);
      // avoid overlapping with the left ports
    }
    String[] labels;
    if (i < td.inPortIds.length - 1) labels = {"d'", "d"};
    else labels = {"v", "u"};   // leftmost ports
    td.addBox(new Box(LABELED_RECT_PAIR, labels,
                      boxCenterX - boxHalfWidth, boxBottomY,
                      boxHalfWidth * 2, boxHeight));
    int inLower = td.addPort(new Port(boxCenterX, boxBottomY,
                                      HIDDEN));
    int outLower = td.addPort(new Port(boxCenterX,
                                       boxBottomY - boxHeight));
    int inUpper = td.addPort(new Port(boxCenterX,
                                      -boxBottomY + boxHeight,
                                      HIDDEN));
    int outUpper = td.addPort(new Port(boxCenterX, -boxBottomY));
    td.connectPorts(inLower, {outLower});
    td.connectPorts(outLower, {inTd});
    td.connectPorts(outTd, {inUpper});
    td.connectPorts(inUpper, {outUpper});
    td.replaceInPortId(i, inLower);
    td.replaceOutPortId(i, outUpper);
    if (i == 0) {               // rightmost ports
      td.tdWidth = max(td.tdWidth, boxCenterX + boxHalfWidth);
    }
    if (i == td.inPortIds.length - 1
        && boxCenterX - boxHalfWidth < 0) { // leftmost ports
      td.shiftX(-(boxCenterX - boxHalfWidth));
      td.tdWidth += -(boxCenterX - boxHalfWidth);
    }
  }
  td.shiftX(UNIT_LENGTH);
  td.tdWidth += UNIT_LENGTH * 2;
  td.tdHalfHeight = boxBottomY;
  td.addBoxHead(new Box(DASHED_RECT, {},
                        0, td.tdHalfHeight - boxHeight / 2,
                        td.tdWidth,
                        (td.tdHalfHeight - boxHeight / 2) * 2));
  return td;
}

// add a term box
Transducer addTermBox (String term, String[] portNames,
                       Transducer td) {
  td.shiftX(TEXT_SIZE_TERM + UNIT_LENGTH);
  td.tdWidth += TEXT_SIZE_TERM + UNIT_LENGTH * 2;
  textSize(TEXT_SIZE_TERM);
  td.tdHalfHeight = max(td.tdHalfHeight + UNIT_LENGTH,
                        textWidth(term) / 2 + TEXT_MARGIN);
  td.addBox(new Box(TERM_RECT, {term},
                    0, td.tdHalfHeight,
                    td.tdWidth, td.tdHalfHeight * 2));
  for (i = 0; i < td.inPortIds.length; i++) {
    int inTd = td.inPortIds[i];
    int outTd = td.outPortIds[i];
    String name;
    if (i < portNames.length) name = portNames[i];
    else name = null;
    int inn = td.addPort(new Port(td.getPort(inTd).x,
                                  td.tdHalfHeight, VISIBLE, name));
    int out = td.addPort(new Port(td.getPort(outTd).x,
                                  -td.tdHalfHeight, VISIBLE, name));
    td.connectPorts(inn, {inTd});
    td.connectPorts(outTd, {out});
    td.replaceInPortId(i, inn);
    td.replaceOutPortId(i, out);
  }
  return td;
}
