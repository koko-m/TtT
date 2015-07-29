void setup () {
  size(areaWidth * 3 / 4, areaHeight);
  background(#b3adaa);
  frameRate(20);
  goDrawing = false;
}

// global variables
boolean goDrawing;
Transducer Td;
float ScaleValue;
float OriginRelativeX;
float OriginRelativeY;
float ZoomX;
float ZoomY;

void draw () {
  // testDraw();
  if (isTermReady()) {
    background(#b3adaa);
    Td = interpret(getTerm());
    termProcessed();
    Td.debug(true);
    ScaleValue = 1;
    OriginRelativeX = 0;
    OriginRelativeY = 0;
    ZoomX = 0;
    ZoomY = 0;
    goDrawing = true;
  } else if (goDrawing) {
    background(#b3adaa);

    pushMatrix();
    translate(ZoomX, ZoomY);
    scale(ScaleValue);
    translate(OriginRelativeX, OriginRelativeY);

    translate(0, height / 2);
    scale(min(width / Td.tdWidth, height / (Td.tdHalfHeight / 2)));
    Td.drawAll();               // draw port ids as well
    // Td.draw();                  // not draw port ids
    popMatrix();
    // goDrawing = false;
  }
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
  if (over & goDrawing) {
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
  if (over & goDrawing) {
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

boolean run = true;

void mouseClicked () {
  run = !run;
  if (run) {
    addLog("resume");
    loop();
  } else {
    addLog("pause");
    noLoop();
  }
}

void keyTyped () {
  if (run && key == 'c') {             // clear zoom
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
int TEXT_MARGIN = UNIT_LENGTH / 2;

float DASHED_LINE_ON_INERVAL = 4;
float DASHED_LINE_OFF_INTERVAL = 3;

float CROSS_INTERVAL = UNIT_LENGTH * 6;
float SWAP_LOOP_X_INTERVAL = UNIT_LENGTH * 2;
float PRIM_INTERVAL = UNIT_LENGTH * 4;
