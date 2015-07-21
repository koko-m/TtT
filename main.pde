void setup () {
  size(1000,1000);
  background(#b3adaa);
  frameRate(20);
}

bool run = true;

void draw () {
  background(#b3adaa);
  if (isParsed()) {
    Object parsedTerm = getParsedTerm();
    // testPrint(parsedTerm);
    testDraw(parsedTerm);
  }
}

void mouseClicked() {
  run = !run;
  if (run) loop();
  else noLoop();
}
