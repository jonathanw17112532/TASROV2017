class mtrDial {
  int xPos, yPos;
  int size = 80;
  int thickness = 8;
  int lastFault = 0;
  int threshold = 100;
  int textSz = 32;
  float current = 0;
  int target = 0;
  int updateRate = 10;
  int lastUpdate = 0;
  color colorForward = #3ADF00;
  color colorBackward = #FF8000;
  color colorError = #FF0000;
  color outline = 220;
  boolean fault = false;
  boolean direction = false;
  boolean flash = false;

  mtrDial(int x, int y, int sz, int ts, color cF, color cB) {
    xPos = x;
    yPos = y;
    size = sz;
    thickness = ts;
    colorForward = cF;
    colorBackward = cB;
  }

  mtrDial(int x, int y) {
    xPos = x; 
    yPos = y;
  }

  mtrDial(int x, int y, int sz, int ts) {
    xPos = x;
    yPos = y;
    size = sz;
    textSz = ts;
  }

  void update(int value) {
    target = value;
    
    if (millis() - lastUpdate > updateRate) {
      if (target >=-128) {
        if (current != target) current += (((float)target-current)/6);
        else current = target;
      }
      else current = 0;
      lastUpdate = millis();
    }
    ellipseMode(CENTER);
    strokeWeight(thickness);
    textAlign(CENTER);
    textSize(textSz);
    if (current >= 0 && target >= -128) {
      stroke(colorForward);
      fault = false;
      direction = true;
    } else if (current <= 0 && current >= -128 && target >= -128) {
      stroke(colorBackward);
      fault = false;
      direction = false;
    } else if (target >= 0);
    else fault = true;

    if (!fault) {
      noFill();
      if (direction) arc(xPos, yPos, size, size, -HALF_PI, (current)*(4*PI/255)-HALF_PI);
      else arc(xPos, yPos, size, size, (current)*(4*PI/255)-HALF_PI, -HALF_PI);
      fill(0);
      text(constrain(abs(2*((int)target)), -128, 128), xPos, yPos+12);
    } else {
      noFill();
      stroke(colorError);
      if (millis() - lastFault > threshold) {
        flash = !flash;
        lastFault = millis();
      }
      if (flash) ellipse(xPos, yPos, size, size);
      fill(0);
      text("!!!", xPos, yPos+12);
    }
    strokeWeight(2);
    stroke(outline);
    noFill();
    ellipse(xPos, yPos, size+8, size+8);
    ellipse(xPos, yPos, size-8, size-8);
  }
}