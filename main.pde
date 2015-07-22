void setup () {
  size(1000,1000);
  background(#b3adaa);
  frameRate(20);
}

int count = 0;
bool run = true;
int x = 1000;

void draw () {
  background(#b3adaa);
  text("Click to pause/restart!", 100, 80);
  if (isTermReady()) {
    text(getTerm().print(), 100, 120);
    text(getTerm().prettyPrint(), 100, 140);

    pushMatrix();
    translate(0, 300);
    new Wire(x, 15, 0, -10, true, "in").draw();
    new Wire(x, -5, 0, -10, false, "out").draw();
    new Box(LABELED_RECT_ONE, {"f"}, x - 10, 5, 20, 10).draw();
    new Box(LABELED_RECT_PAIR, {"c", "c'"}, x + 20, 15, 20, 10).draw();
    new Box(TRI_PAIR_CAP, {}, x + 50, 15, 20, 10).draw();
    new Box(TRI_PAIR_SANDGLASS, {}, x + 80, 15, 30, 10).draw();
    textSize(TEXT_SIZE_TERM);
    new Box(TERM_RECT, {"(lambda(x)(+x x))"}, x + 120, 20, 20,
            textWidth("(lambda(x)(+x x))") + TEXT_MARGIN * 2).draw();
    new Box(DASHED_RECT, {}, x + 150, 20, 50, 40).draw();

    popMatrix();
    text("Hey hey!", x, 500);
    x -= 5;
    if (x < -200) x = 1000;
  }
  text(count++,100,100);
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
int TEXT_SIZE_ERR_MSG = 12;
int TEXT_MARGIN = 2.5;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float TERM_BOX_MARGIN_LEFT = 15;
float TERM_BOX_MARGIN_RIGHT = 5;
