class Token {
  Nat copyIndex;
  Nat data;
  int portId;
  float x;
  float y;

  Token (Nat data) {
    this.copyIndex = new Nat(); // dummy value
    this.data = data;
  }

  void setNextPort (int portId, float x, float y) {
    this.portId = portId;
    this.x = x;
    this.y = y;
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
