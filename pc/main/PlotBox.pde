class PlotBox {
  PVector myCenter;
  color myBaseColor;
  float myValue, myTarget;
  int myTravel;
  int updateTimer = 0;
  float updateInterval = 1;
  
  PlotBox(float _y, color _basecolor, int _travel) {
    myCenter = new PVector(0,_y);
    myBaseColor = _basecolor;
    myValue = _y;
    myTravel = _travel;
  }
  
  void display() {
    ellipse(myCenter.x,myCenter.y, 1, 1);
    if(myValue > myTarget) stroke(#FCFCFC);
  }
  
  void update() {
    myCenter.x -= 3;    
    float blendCoef = abs(myCenter.x/(myTravel/2));
    if(blendCoef>1) blendCoef = 1;
  }
  
  boolean isPlottable() {
    if(myCenter.x > -myTravel) { return true; }
    else return false;
  }
}