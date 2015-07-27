void setup () {
  size(1000,1000);
  background(#b3adaa);
  frameRate(20);
}

boolean first = true;

void draw () {
  if (isTermReady()) {
    background(#b3adaa);
    pushMatrix();
    translate(0, 300);
    Transducer td = interpret(getTerm());
    td.drawAll();               // draw port ids as well
    // td.draw();                  // not draw port ids
    td.debug(first);
    popMatrix();
    termProcessed();
  }
}

void mouseClicked() {
  run = !run;
  if (run) loop();
  else noLoop();
}

// macros

float UNIT_LENGTH = 10;

int TEXT_SIZE_LABEL = 10;
int TEXT_SIZE_PORT = 10;
int TEXT_SIZE_TERM = 12;
int TEXT_SIZE_DEBUG = 10;
int TEXT_MARGIN = UNIT_LENGTH / 2;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float CROSS_INTERVAL = UNIT_LENGTH * 6;
float SWAP_LOOP_X_INTERVAL = UNIT_LENGTH * 2;
float PRIM_INTERVAL = UNIT_LENGTH * 4;
