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
