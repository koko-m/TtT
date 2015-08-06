class Token {
  Nat copyIndex;
  Nat data;
  int portId;                   // id. of the target (next) port
  float[] path;                 // path on which the token is
  int pointIndex;               // index of the next point on the path
  float distance;               // distance to the next point
  float x;
  float y;

  Token (Nat data) {
    this.copyIndex = new Nat(); // dummy value
    this.data = data;
    this.distance = 0;
  }

  void setNextPort (int portId, float[] path) {
    this.portId = portId;
    this.path = path;
    this.pointIndex = 1;
    this.distance += dist(path[0], path[1], path[2], path[3]);
    this.x = path[0];
    this.y = path[1];
  }

  void step () {
    this.distance -= TOKEN_SPEED * getSpeed() / 100;
    while (this.distance < 0
           && this.pointIndex + 1 < this.path.length / 2) {
      this.distance += dist(this.path[this.pointIndex * 2],
                            this.path[this.pointIndex * 2 + 1],
                            this.path[(this.pointIndex + 1) * 2],
                            this.path[(this.pointIndex + 1) * 2 + 1]);
      this.pointIndex += 1;
    }
  }

  void put () {
    float lineLength = dist(this.path[this.pointIndex * 2],
                            this.path[this.pointIndex * 2 + 1],
                            this.path[(this.pointIndex - 1) * 2],
                            this.path[(this.pointIndex - 1) * 2 + 1]);
    this.x = lerp(this.path[this.pointIndex * 2],
                  this.path[(this.pointIndex - 1) * 2],
                  this.distance / lineLength);
    this.y = lerp(this.path[this.pointIndex * 2 + 1],
                  this.path[(this.pointIndex - 1) * 2 + 1],
                  this.distance / lineLength);
  }

  void draw () {
    stroke(#ff0000);
    fill(#ff0000);
    ellipseMode(CENTER);
    ellipse(this.x, this.y, TOKEN_DIAMETER, TOKEN_DIAMETER);
    textSize(TEXT_SIZE_TOKEN);
    textAlign(RIGHT, CENTER);
    text("{" + this.copyIndex.prettyPrint() + "}",
         this.x - TOKEN_DIAMETER / 2 - TEXT_MARGIN, this.y);
    textAlign(LEFT, CENTER);
    text(this.data.prettyPrint(),
         this.x + TOKEN_DIAMETER / 2 + TEXT_MARGIN, this.y);
  }
}
