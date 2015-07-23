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
  textAlign(LEFT, BOTTOM);
  text("Click to pause/restart!", 100, 80);
  text(count++,100,100);
  text("Hey hey!", x, 50);
  testParse();
  pushMatrix();
  translate(x, 300);
  testGraph();
  popMatrix();
  pushMatrix();
  translate(0, 450);
  testTdConstructors(first);
  popMatrix();
  x -= 5;
  if (x < -200) x = 1000;
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
int TEXT_SIZE_DEBUG = 6;
int TEXT_MARGIN = 2.5;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float MARGIN_UNIT = 5;

float TERM_BOX_MARGIN_LEFT = 15;
float TERM_BOX_MARGIN_RIGHT = 5;
