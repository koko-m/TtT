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
    translate(x, 300);
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
    graph.addBox(new Box(TRI_PAIR_CAP, {}, 50, 15, 20, 10));
    graph.addBox(new Box(TRI_PAIR_SANDGLASS, {}, 80, 15, 30, 10));
    textSize(TEXT_SIZE_TERM);
    graph.addBox(new Box(TERM_RECT, {"(lambda(x)(+x x))"},
                         120, 20, 20,
                         textWidth("(lambda(x)(+x x))")
                         + TEXT_MARGIN * 2));
    graph.addBox(new Box(DASHED_RECT, {}, 150, 20, 50, 40));
    graph.drawAll();
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

float MARGIN_UNIT = 5;

float TERM_BOX_MARGIN_LEFT = 15;
float TERM_BOX_MARGIN_RIGHT = 5;
