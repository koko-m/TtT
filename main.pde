// global variables
boolean goDrawing;
Transducer Td;
float ScaleValue;
float OriginRelativeX;
float OriginRelativeY;
float ZoomX;
float ZoomY;

void setup () {
  size(getCanvasWidth(), getCanvasHeight());
  background(#b3adaa);
  frameRate(20);
  Td = null;
  clearLog();
}

void draw () {
  byte currentState = getState();
  switch (currentState) {
  case STATE_IDLE:
    if (Td != null) drawZoomedTd();
    break;
  case STATE_READY:
    Td = getTd();
    Td.collectPaths();
    Td.debug(true);
    Td.initToken(encodeNatQuery());
    ScaleValue = 1;
    OriginRelativeX = 0;
    OriginRelativeY = 0;
    ZoomX = 0;
    ZoomY = 0;
    drawZoomedTd();
    goRun();
    break;
  case STATE_RUN: case STATE_PAUSE:
    boolean terminate = false;
    if (currentState == STATE_RUN) terminate = Td.run();
    drawZoomedTd();
    if (terminate) goIdle();
    break;
  }
}

void drawZoomedTd () {
  background(#b3adaa);

  pushMatrix();
  translate(ZoomX, ZoomY);
  scale(ScaleValue);
  translate(OriginRelativeX, OriginRelativeY);

  translate(0, height / 2);
  scale(min(width / Td.tdWidth, height / (Td.tdHalfHeight * 2)));
  Td.drawAll();               // draw port ids as well
  // Td.draw();                  // not draw port ids
  popMatrix();
}



boolean over = false;

void mouseOver () {
  cursor(HAND);
  over = true;
}
void mouseOut () {
  cursor(ARROW);
  over = false;
}

int scrollCount = 0;

void mouseScrolled () {
  if (over) {
    if (mouseScroll > 0) scrollCount += 1;
    if (mouseScroll < 0) scrollCount -= 1;
    if (abs(scrollCount) > 2) { // remove noise
      OriginRelativeX =
        (ZoomX - mouseX) / ScaleValue + OriginRelativeX;
      OriginRelativeY =
        (ZoomY - mouseY) / ScaleValue + OriginRelativeY;
      ZoomX = mouseX;
      ZoomY = mouseY;
      if (mouseScroll > 0) {
        ScaleValue = max(ScaleValue
                         + SCALE_COEFFICIENT * pow(mouseScroll, 2),
                         1);
      } else {
        ScaleValue = max(ScaleValue
                         - SCALE_COEFFICIENT * pow(mouseScroll, 2),
                         1);
      }
      scrollCount = 0;
    }
  }
}

boolean dragging = false;

void mouseDragged () {
  if (over) {
    dragging = true;
    cursor(CROSS);
    OriginRelativeX += mouseX - pmouseX;
    OriginRelativeY += mouseY - pmouseY;
  }
}

void mouseReleased () {
  if (dragging) {
    if (over) cursor(HAND);
    else cursor(ARROW);
    dragging = false;
  }
}

void mouseClicked () {
  switch (getState()) {
  case STATE_IDLE: case STATE_READY: break;
  case STATE_RUN: goPause(); break;
  case STATE_PAUSE: goResume(); break;
  }
}

void keyTyped () {
  if (key == 'c') {             // clear zoom
    ScaleValue = 1;
    OriginRelativeX = 0;
    OriginRelativeY = 0;
    ZoomX = 0;
    ZoomY = 0;
  }
}

// macros
float SCALE_COEFFICIENT = 0.1;

float UNIT_LENGTH = 10;

int TEXT_SIZE_LABEL = 10;
int TEXT_SIZE_PROB = 12;
int TEXT_SIZE_PORT = 10;
int TEXT_SIZE_TERM = 12;
int TEXT_SIZE_DEBUG = 10;
int TEXT_SIZE_TOKEN = 10;
int TEXT_MARGIN = UNIT_LENGTH / 2;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float CROSS_INTERVAL = UNIT_LENGTH * 6;
float SWAP_LOOP_X_INTERVAL = UNIT_LENGTH * 2;
float PRIM_INTERVAL = UNIT_LENGTH * 4;

float TOKEN_DIAMETER = UNIT_LENGTH;

float TOKEN_SPEED = UNIT_LENGTH;
