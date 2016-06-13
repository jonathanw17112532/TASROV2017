/*
////////////////////////////////////////////////

   [ Arduino Cycle Computer ] Version P0.1
        
 >> Original written by Adam O'Hern
 >> Modified by Alexdlp for Instructables 2011

////////////////////////////////////////////////
*/

  import processing.serial.*;
  import processing.opengl.*;
  import controlP5.*;
  
  Serial myPort;
  PFont fontA;
  
  String prev;
  float rideDistance = 0;
  float averageSpeed = 0;
  ArrayList speedLog = new ArrayList();
  int lastPulseTime = 0;
  int pulseDisplay = 0;
  
  int maxSpeed = 15; // this is just a temporary value until can get maxSpeed function working
  
  int movieWidth = 1024; //Width and height can be whatever you want. Everything should scale (within reason)
  int movieHeight = 620;
  
  BoxPlot speedPlot;
  ControlP5 controlP5;
  
  Timer timer;
  
  void setup()
  {
    size(movieWidth, movieHeight,OPENGL);
    hint(ENABLE_OPENGL_4X_SMOOTH);
    //(DISABLE_OPENGL_2X_SMOOTH);
    
    fontA = loadFont("HelveticaNeue-Bold-48.vlw");
    textFont(fontA, 32);  // Set the font and its size (units of pixels)
    background(0);
    
    String portName = Serial.list()[0];
    // I know that the first port in the serial list on my mac 
    // is always my  FTDI adaptor, so I open Serial.list()[0]. 
    // On Windows machines, this generally opens COM1.     
    myPort = new Serial(this, portName, 9600);
    
    speedPlot = new BoxPlot(width/2, height/2-110, width, height, #E5F5FF);
   
    timer = new Timer();
    
    int x = 20;
    int y = 520;
    
    timer.pause();
    
    controlP5 = new ControlP5(this);
    controlP5.setColorLabel(color(150));
    controlP5.setColorBackground(color(245));
    controlP5.setColorForeground(color(#89BFDB, 95)); //C9EBFF
    
    controlP5.addSlider("TargetSpeed",5,32,13,x,75,200,10);
    Slider targetSlider = (Slider)controlP5.controller("TargetSpeed");
    targetSlider.setNumberOfTickMarks(16);
  }
  
  void draw()
  {
    readSerial();
    speedPlot.update(smoothSpeed());
    timer.update(); 
    
    if(myPort.available() > 0)  {
      timer.unpause();  }
      
    background(255);
    
    speedPlot.display();

     // DISPLAY TITLE
    textAlign(LEFT); textSize(32); fill(#39B4E3); 
    text("/// arduino", 25, height-500);
    fill(#89BFDB);
    text("cycle computer", 190, height-500);
    textSize(12); fill(#B4B4B4);
    text("written by Adam O'Hern, modified Alexdlp 2011", 25, height-480);

    //DISPLAY SPEED
    textAlign(LEFT); textSize(16); fill(#89BFDB, 95);
    text("Speed", 25, height-60);
    textSize(32); fill(0);  
    text("mph: "+nf(smoothSpeed(),2,1), 25, height-25); //show speed bottom-left
    
    // DISPLAY DISTANCE
    textAlign(RIGHT); textSize(16); fill(#89BFDB, 95);
    text("Distance", width-25, height-60);
    textSize(32); fill(0);
    text("miles: "+nf(rideDistance,2,2), width-25, height-25); //show speed bottom-right

    // DISPLAY AVERAGE SPEED
    textAlign(LEFT); textSize(20); fill(#89BFDB);
    float dispAverage = 0;
    text("average: "+nf(averageSpeed, 2,1), 190, height-25);
        
    // DISPLAY MAX.SPEED
    textAlign(LEFT); textSize(20); fill(#39B4E3);
    text("max: "+nf(maxSpeed, 2,2), 190, height-48);
 
    // TIMER
    textAlign(CENTER); textSize(16); fill(#89BFDB, 95);
    text("Time", width/2, height-60);
    textSize(32);
    if(timer.isPaused()) fill(200); else fill(0); 
    String dispStr = nf(timer.minutes(),2)+":"+nf(timer.seconds(),2)+":"+nf(timer.hundredths(),2);
    text(dispStr,width/2, height-25);
  
    // DISPLAY PULSE DETECTION
    textAlign(LEFT); textSize(20); fill(#89BFDB);
    if(myPort.available() > 0)  {  // if data or 'pulse' has been detected straight from the port, highlight text
    fill(#FF9305); }  else  {  fill(#89BFDB, 95);  }
    text("[ pulse detected ]", width-415, height-30);   
   
  }
  
    void TargetSpeed(int theValue) { speedPlot.setTargetSpeed(theValue); } 
class BoxPlot {
  int targetSpeed = 12; int sprintSpeed = 21;
  PVector myCenter;
  float myWidth; float myHeight;
  float myMin; float myMax;
  color myColor;
  PlotTarget myTarget;
  float myPlotScale;
  
  int plotTimer;
  float plotInterval = 4; // in loops
  ArrayList plotBoxes;

  BoxPlot(float centerX, float centerY, float myWidthi, float myHeighti, color myColori) {
    
    myCenter = new PVector(centerX,centerY);
    myWidth = myWidthi; myHeight = myHeighti;
    myMin = 0; myMax = 40;
    myColor = myColori;
    
    plotBoxes = new ArrayList();
    plotTimer = 0;
    
    myPlotScale = -myHeight/myMax;

    myTarget = new PlotTarget(targetSpeed,sprintSpeed,myWidth,myPlotScale);
  }
  
  void display() {
    pushMatrix();
      translate(myCenter.x,myCenter.y+myHeight/2);
      
      myTarget.display();
      
      for(int i=0; i<plotBoxes.size(); i++) {
        PlotBox plotBox = (PlotBox) plotBoxes.get(i);
        if(plotBox.isPlottable()) {
          plotBox.display();
        } else { plotBoxes.remove(i); }
      }
      
      displayHUD(smoothSpeed());
    popMatrix();
  }
  
  void displayHUD(float value) {
      pushStyle();
        fill(#FF9305); noStroke(); ellipseMode(CENTER);
        ellipse(0,-value*myHeight/myMax,10,10);
      textAlign(LEFT); fill(#89BFDB);
      textSize(16);
        text(nf(value,1,1),20,-value*myHeight/myMax+textAscent()/2);
      popStyle();
  }
  
  void update(float value) {
    if(plotTimer > plotInterval) {
      addPlotBox(value);
      plotTimer = 0;
    } else plotTimer++;
  }
  
  void addPlotBox(float value) {
    plotBoxes.add(new PlotBox(myPlotScale*(value),myColor,abs(myPlotScale*(myTarget.targetLine[int(myTarget.targetLine.length/2)])),int(myWidth)));
  }
  
  boolean sluffing() {
    if(smoothSpeed() > myTarget.targetLine[int(myWidth/2)]) return false;
    else return true;
  }
  
  void setTargetSpeed(int value) { myTarget.targetSpeed = value; }
  
}
class PlotBox {
  PVector myCenter;
  PVector myCrazyCenter;
  float myAngle;
  color myBaseColor;
  color myColor;
  int myBirthday;
  float myRandomSeed;
  float myValue;
  float myTarget;
  int myTravel;
  
  PlotBox(float yi, color baseColori, float targeti, int traveli) {
    myBirthday = millis();
    myCenter = new PVector(0,yi);
    float tmp = abs(yi/targeti); if(tmp>1) tmp = 1;
    myBaseColor = lerpColor(baseColori,#D3E8F0,tmp);
    myColor = myBaseColor;
    myAngle = 0;
    myRandomSeed = random(-1,1);
    myValue = yi;
    myTarget = -targeti;
    myTravel = traveli;
    myCrazyCenter = new PVector(myCenter.x,myCenter.y);
  }
  
  void display() {
    update();
    stroke(myBaseColor); strokeWeight(3);
    line(myCenter.x,0,myCenter.x,myCenter.y);
    if(myValue > myTarget) stroke(#FCFCFC);
      
    if(myCrazyCenter.y < 0) {
    pushMatrix();
      pushStyle();
        translate(myCrazyCenter.x,myCrazyCenter.y); rotate(myAngle);
        
        if(myValue > myTarget)  {
          fill(#D3E8F0);  }
          else  { fill(#39B4E3);  }
        ellipseMode(CENTER); noStroke();
        ellipse(0,0,6,6);
        
      popStyle();
    popMatrix();
    }
  }
  
  void update() {
    myCenter.x -= 1;
    myCrazyCenter.x -= map(abs(myCenter.y),0,400,1,3);
    myCrazyCenter.y = myCrazyCenter.y + sin(map(myCrazyCenter.x*myRandomSeed,0,myTravel*25,0,360))*map(abs(myValue),0,25,0,.1);
    myAngle = map(myCenter.x,0,-myTravel/2,0,myRandomSeed*PI/4);
    
    
    float blendCoef = abs(myCenter.x/(myTravel/2));
    if(blendCoef>1) blendCoef = 1;
    myColor = lerpColor(myBaseColor,#D9D9D9,blendCoef);
  }
  
  boolean isPlottable() {
    if(myCenter.x > -myTravel/2-50) { return true; }
    else return false;
  }
    
}
class PlotTarget {
  int targetSpeed;
  int sprintSpeed;
  float sprintInterval = 1;
  float sprintDuration = .5;
  int lastSprint = 0;
  float myWidth;
  float myPlotScale;
  
  float[] targetLine;
  
  PlotTarget(int targeti, int sprinti, float widthi, float scalei) {
    targetSpeed = targeti;
    sprintSpeed = sprinti;
    
    sprintInterval = sprintInterval*60*1000;
    sprintDuration = sprintDuration*60*1000;
    
    myWidth = widthi;
    myPlotScale = scalei;
    
    targetLine = new float[int(myWidth)];
    for(int i=0; i<targetLine.length; i++) {
      targetLine[i] = targetSpeed;
    }
  }
  
  void display() {
     update();
     
     stroke(#bcd3e2, 50); strokeWeight(2);
     for(int i=0; i < targetLine.length-1; i++) line(-myWidth/2+i,myPlotScale*(targetLine[i]),-myWidth/2+1+i,myPlotScale*(targetLine[i+1])); //draw the TARGET line
     noStroke(); fill(#89BFDB); textAlign(RIGHT); textSize(11);
     text("TargetSpeed: "+nf(targetSpeed,1,1),myWidth/2-10,myPlotScale*(targetLine[targetLine.length-1])-10);
     ellipse(myWidth/2,myPlotScale*(targetLine[targetLine.length-1]),10,10);
  }
  
  void update() {
    for(int i=0; i < targetLine.length-1; i++){
      targetLine[i] = targetLine[i+1]; 
    }
    targetLine[targetLine.length-1] = targetSpeed;
  }
}
class Timer {
  int timerStart = 0;
  int offset;
  
  int mill;
  int minutes;
  int seconds;
  int hundredths;
  
  boolean stopped = false;
  boolean continued = false;
  
  Timer() {
    
  }
  
  void update() {
    if(!stopped) {
      mill=(millis()-timerStart);
      if(continued) mill += offset;
      
      seconds = mill / 1000;
      minutes = seconds / 60;
      seconds = seconds % 60;
      hundredths = mill / 10 % 100;
    }
  }
  
  void pause() { stopped = true; }
  
  void unpause() {
    stopped = false;
    continued = true;
    timerStart = millis();
    
    offset = mill;
  }
  
  void reset() {
    stopped = false;
    continued = true;
    timerStart = millis();
  }
  
  int minutes() { return minutes; }
  int seconds() { return seconds; }
  int hundredths() { return hundredths; }
  
  boolean isPaused() { if (stopped) return true; else return false; }
}
void readSerial() {
  String val;
  if ( myPort.available() > 0) {            // If data is available,
      val = myPort.readStringUntil(10);     // read it and store it in val
      if(val != null) {      
        val = trim(val);      // trim whitespace off the ends
        update(val);
        lastPulseTime = millis();
      }
  }
  
  float weightedSpeed = smoothSpeed() - (millis()-lastPulseTime)/1000;
  if(weightedSpeed<0) weightedSpeed = 0;
  update("currentSpeed="+weightedSpeed);

}

void update(String val) {  // unscramble the serial data that has been stored in the form of a string
  if(val != null) {
    String[] pairs = split(val,"&");  // this & character separates the incomming data
    
    for(int i=0; i<pairs.length; i++) {
      String[] pair = split(pairs[i],"=");
      //  note capital "F" in float for ArrayLists!
      if (pair[0].equals("currentSpeed")) speedLog.add(new Float(pair[1]));
      if (pair[0].equals("rideDistance")) rideDistance = float(pair[1]);
      if (pair[0].equals("averageSpeed")) averageSpeed = float(pair[1]);  
    }
  }
  
  if(speedLog.size() > 1000) { speedLog.remove(0); }  // if the speedLog is full (1000) values, then remove/decay values
  
}

float latestSpeed() {
  if(speedLog.size() > 0) {
    //  note capital "F" in float for ArrayLists!
    return (Float) speedLog.get(speedLog.size()-1); 
  } else return 0;
}

float smoothSpeed() {
  if(speedLog.size() > 0) {
    int samples = 32;
    if(speedLog.size() < samples) {
      samples = speedLog.size();
    }
    
    float smoothSpeed = 0;
    int n = 0;
    for(int i=0; i<samples; i++) {
      //  note capital "F" in float for ArrayLists!
      float speed = (Float) speedLog.get(speedLog.size()-1-i);
      speed = speed * sq(samples-i);
      smoothSpeed += speed;
      n+=sq(samples-i);
    }

    smoothSpeed = smoothSpeed/n; 
    return smoothSpeed; 
  } else { return 0; }
}

