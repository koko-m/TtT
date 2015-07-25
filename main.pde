void setup () {
  size(1000,1000);
  background(#b3adaa);
  frameRate(20);
}

int count = 0;
bool run = true;
int x = 1000;
boolean first = true;

void draw () {
  background(#b3adaa);
  // textAlign(LEFT, BOTTOM);
  // text("Click to pause/restart!", 100, 50);
  // text(count++,100,70);
  // text("Hey hey!", x, 20);
  // testParse();
  translate(0, 50);
  testTdConstructorsPrim(first);
  translate(0, 80);
  testTdConstructorsSeqComp(first);
  translate(0, 100);
  testTdConstructorsParComp(first);
  translate(0, 120);
  testTdConstructorsConnect(first);
  noLoop();
  // translate(x, 100);
  // testGraph();
  // x -= 5;
  // if (x < -200) x = 1000;
  first = false;
}

void mouseClicked() {
  run = !run;
  if (run) loop();
  else noLoop();
}

// macros

int TEXT_SIZE_LABEL = 10;
int TEXT_SIZE_PORT = 10;
int TEXT_SIZE_TERM = 12;
int TEXT_SIZE_DEBUG = 10;
int TEXT_MARGIN = 2.5;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float MARGIN_UNIT = 10;

float CROSS_INTERVAL = MARGIN_UNIT * 6;

float TERM_BOX_MARGIN_LEFT = 15;
float TERM_BOX_MARGIN_RIGHT = 5;
