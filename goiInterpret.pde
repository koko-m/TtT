Transducer interpret (Object term) {
  Transducer td;
  int numFV = term.freeVars.length;
  switch (term.tag) {
  case "var":
    td = primH(PRIM_INTERVAL);
    int varIndex = term.parameters[0];
    if (varIndex == numFV - 1) { // the last variable
      for (i = 0; i < varIndex; i++) {
        td = parCompPrimPairW(0, td);
      }
    } else {
      for (i = varIndex + 1; i < numFV; i++) {
        td = parCompPrimPairW(0, td);
      }
      td = pullOutPort(numFV - (varIndex + 1), td);
      for (i = 0; i < varIndex; i++) {
        td = parCompPrimPairW(0, td);
      }
    }
    break;
  case "nat":
    td = makeCross(0, primH(PRIM_INTERVAL),
                   0, primK(term.parameters[0]));
    for (i = 0; i < numFV; i++) {
      td = parCompPrimPairW(0, td);
    }
    break;
  case "unit":
    td = makeLoop(0, primH(PRIM_INTERVAL));
    for (i = 0; i < numFV; i++) {
      td = parCompPrimPairW(0, td);
    }
    break;
  case "lambda":
    td =
      makeCross
      (0, primH(PRIM_INTERVAL),
       numFV,
       addBangBox
       (seqCompPrimPairJoinCenter
        (numFV, numFV + 1, PAIR_P, UNSWAP,
         interpret(term.bodies[0]))));
    break;
  case "rec":
    td =
      makeCross
      (0, primH(PRIM_INTERVAL),
       numFV,
       makeSwapLoops
       (numFV, numFV + 1,
        seqCompPrimPairSplit
        (numFV + 1, PAIR_C,
         addBangBox
         (seqCompPrimPairJoinCenter
          (numFV + 1, numFV + 2, PAIR_P, UNSWAP,
           interpret(term.bodies[0]))))));
    break;
  case "app":
    td =
      makeCross
      (numFV,
       seqCompPrimPairSplit
       (numFV, PAIR_P, interpret(term.bodies[0])),
       numFV,
       seqCompPrimPairJoinCenter
       (numFV, numFV + 1, PAIR_P, UNSWAP,
        seqCompPrimPairE
        (numFV,
         seqCompPrimPairSplit
         (numFV, PAIR_P, interpret(term.bodies[1])))));
    for (i = 0; i < numFV; i++) {
      td = seqCompPrimPairJoinRight(i, numFV, PAIR_C, UNSWAP, td);
    }
    break;
  case "choose":
    td = addChoiceBox(term.parameters[0],
                      interpret(term.bodies[0]),
                      interpret(term.bodies[1]));
    break;
  case "car":
    td = makeCross(numFV,
                   seqCompPrimPairSplit
                   (numFV, PAIR_P, interpret(term.bodies[0])),
                   0,
                   seqCompPrimPairJoinCenter
                   (0, 1, PAIR_P, UNSWAP,
                    seqCompPrimPairJoinCenter
                    (0, 1, PAIR_P, UNSWAP,
                     parCompPrimPairW
                     (0, primH(PRIM_INTERVAL)))));
    break;
  case "cdr":
    td = makeCross(numFV,
                   seqCompPrimPairSplit
                   (numFV, PAIR_P, interpret(term.bodies[0])),
                   0,
                   seqCompPrimPairJoinCenter
                   (0, 1, PAIR_P, UNSWAP,
                    seqCompPrimPairJoinCenter
                    (0, 1, PAIR_P, UNSWAP,
                     parCompPrimPairW
                     (1, primH(PRIM_INTERVAL)))));
    break;
  case "cons":
    td = makeCross(numFV,
                   makeCross
                   (numFV,
                    seqCompPrimPairSplit
                    (numFV, PAIR_P, interpret(term.bodies[0])),
                    numFV + 1,
                    seqCompPrimPairSplit
                    (numFV, PAIR_P, interpret(term.bodies[1]))),
                   0,
                   seqCompPrimPairJoinCenter
                   (0, 1, PAIR_P, UNSWAP,
                    seqCompPrimPairJoinCenter
                    (1, 2, PAIR_P, UNSWAP,
                     seqCompPrimPairSplit
                     (0, PAIR_P, primH(PRIM_INTERVAL)))));
    for (i = 0; i < numFV; i++) {
      td = seqCompPrimPairJoinRight(i, numFV, PAIR_C, UNSWAP, td);
    }
    break;
  case "inl":
    td = makeCross(numFV,
                   seqCompPrimPairSplit
                   (numFV, PAIR_P, interpret(term.bodies[0])),
                   0,
                   makeCross
                   (0,
                    seqCompPrimPairJoinCenter
                    (1, 2, PAIR_P, UNSWAP,
                     seqCompPrimPairSplit
                     (0, PAIR_P, primH(PRIM_INTERVAL))),
                    0,
                    seqCompPrimPairJoinCenter
                    (0, 1, PAIR_P, UNSWAP,
                     seqCompPrimPairJoinCenter
                     (0, 1, PAIR_P, UNSWAP,
                      parCompPrimPairW
                      (0, primSwap(PRIM_INTERVAL))))));
    break;
  case "inr":
    td = makeCross(numFV,
                   seqCompPrimPairSplit
                   (numFV, PAIR_P, interpret(term.bodies[0])),
                   0,
                   makeCross
                   (0,
                    seqCompPrimPairJoinCenter
                    (1, 2, PAIR_P, UNSWAP,
                     seqCompPrimPairSplit
                     (0, PAIR_P, primH(PRIM_INTERVAL))),
                    0,
                    seqCompPrimPairJoinCenter
                    (0, 1, PAIR_P, UNSWAP,
                     seqCompPrimPairJoinCenter
                     (0, 1, PAIR_P, UNSWAP,
                      parCompPrimPairW
                      (1, primSwap(PRIM_INTERVAL))))));
    break;
  case "match":
    td =
      makeCross
      (numFV,
       makeSwapLoops
       (numFV + 1, numFV + 2,
        seqCompPrimPairJoinCenter
        (numFV + 2, numFV + 3, PAIR_P, UNSWAP,
         seqCompPrimPairSplit
         (numFV, PAIR_P,
          seqCompPrimPairSplit
          (numFV, PAIR_P,
           seqCompPrimPairSplit
           (numFV, PAIR_P,
            seqCompPrimPairSplit
            (numFV, PAIR_P, interpret(term.bodies[0]))))))),
       numFV,
       seqCompPrimPairJoinLeft
       (numFV, numFV * 2 + 1, PAIR_P, UNSWAP,
        parCompTd
        (CROSS_INTERVAL / 2,
         seqCompPrimPairJoinCenter
         (numFV, numFV + 1, PAIR_P, UNSWAP,
          interpret(term.bodies[1])),
         seqCompPrimPairJoinCenter
         (numFV, numFV + 1, PAIR_P, UNSWAP,
          interpret(term.bodies[2])))));
    for (i = 0; i < numFV; i++) {
      td = seqCompPrimPairJoinRight(i, numFV, PAIR_C, UNSWAP, td);
    }
    for (i = 0; i < numFV; i++) {
      td = seqCompPrimPairJoinRight(i, numFV, PAIR_C, SWAP, td);
    }
    break;
  case "+1":
    td = 
      seqCompPrimPairJoinCenter
      (0, 1, PAIR_C, UNSWAP,
       makeCross(0, primH(PRIM_INTERVAL),
                 2, primSum(UNIT_LENGTH * 2)));
    for (i = 0; i < numFV - 1; i++) {
      td = parCompPrimPairW(0, td);
    }
    break;
  case "+2":
    td = makeCross(0, primH(PRIM_INTERVAL),
                   2, primSum(UNIT_LENGTH * 2));
    for (i = 0; i < numFV - 2; i++) {
      td = parCompPrimPairW(0, td);
    }
    break;
  case "+":
    console.log
      ("error interpret: summation of terms not eliminated");
    td = null;
    break;
  }
  if (td != null) {
    td = addTermBox(term.prettyPrint(), term.freeVars, td);
  }
  return td;
}


