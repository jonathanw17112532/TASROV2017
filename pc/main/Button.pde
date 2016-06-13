class Button {
  String buttonName;
  int rectx, recty;
  int sizex, sizey;
  boolean buttonOver;
  color rectColor;

  Button(String name, int x, int y, int size1, int size2, color color1) {
    textFont(loadFont("HelveticaNeue-Bold-48.vlw"), 12); 
    rectx = x;
    recty = y;
    sizex = size1;
    sizey = size2;
    rectColor = color1;
    buttonName = name;
  }
  void update(int x, int y, boolean current) {
    if (overButton(rectx, recty, sizex, sizey)) buttonOver = true;
    else buttonOver = false;
    
    if(current) fill(rectColor);
    else if (buttonOver) fill(rectColor, 100);
    else fill(rectColor, 10);
    
    strokeWeight(1);
    stroke(#1c5a70);
    rect(rectx, recty, sizex, sizey, 5, 5, 0, 0);
    
    if (buttonOver) fill(255); 
    else fill(#39B4E0);
    
    textSize(sizey*.6);
    textAlign(CENTER);
    if(current) fill(255);
    text(buttonName, rectx + sizex/2, (sizey*3/4) + recty);
  }

  boolean overButton(int x, int y, int width, int height) {
    if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) return true;
    else return false;
  }
}