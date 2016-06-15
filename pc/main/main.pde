/*
////////////////////////////////////////////////
 [ ROV Debug Monitor ] Version 2.0 based on [ Arduino Cycle Computer ]        
 >> Original written by Adam O'Hern
 >> Modified by Anthony Lin, Joseph Chuang and Jonathan Wu for ROV Debug Monitor
 ////////////////////////////////////////////////
 */

import controlP5.*;
import processing.serial.*;

//hardware
Serial myPort;
int baudRate = 9600;
int Ss;
int lastGamepadCheck = 0;

//controlP5 + gui
ControlP5 controlP5;
DropdownList ports;
OverviewPlot overviewPlot;    //overview
PowerPlot powerPlot;          //power
VoltsPlot voltPlot;           //sensor
Button overviewButton, powerButton, voltButton, serialButton;
Button[] buttons;

//control variables
String[] comList;
boolean serialSet, Comselected;
//logs for graphs - see update() in calculationFunctions
String[] logTags = new String[]{"voltage", "current", "temperature", "motor1", "motor2", "motor3", "motor4"};
int logs_length = logTags.length;
ArrayList[] logs = new ArrayList[logs_length];

//non-logged variables
int pwm[] = new int[]{
  0, 256, 128, 128, 128, 128
};
int servo[] = new int[7];
long upTime = 0;
int plotMode = 0; //0 volt, 1 motors, 2 weather, 3 serial
int lastPulseTime = 0;
boolean connected, controller;
String DEBUGMESSAGE = "";

boolean fullscreen = false;

//style
PFont fontA;
color DARKBLUE = #000064;
color LIGHTBLUE = #97D7FF;
color LIGHTGREY = #B4B4B4;
color RED = #FF0000;
color GREEN = #00FF00;
color ROSE = #ff7676;
color BUTTONCOL = #39B4E0;

void setup()
{
  size(1366, 768, P2D);
  frame.setResizable(true);
  fontA = loadFont("HelveticaNeue-Bold-48.vlw");
  textFont(fontA, 32);  // Set the font and its size (units of pixels)
  controlP5 = new ControlP5(this);
  ports = controlP5.addDropdownList("list-1", width/2-80, 31, 100, 84);
  controlP5.addButton("refresh").setValue(0).setPosition(width/2+25, 15).setSize(45, 15);
  //triggers refresh() on activation - by name
  controlP5.setAutoDraw(false); 
  try {
    ports.clear();
    customize(ports);
  }
  catch(ArrayIndexOutOfBoundsException e) {
  };

  for (int i = 0; i < logs_length; i++) logs[i] = new ArrayList();

  voltPlot = new VoltsPlot(width-100, height/2-110, width, height, LIGHTBLUE);
  powerPlot = new PowerPlot(width-100, height/2-110, width, height, new color[] {
    LIGHTBLUE, DARKBLUE, ROSE, GREEN
    }
    );
  overviewPlot = new OverviewPlot();

  overviewButton = new Button("overview", width - 460, 70, 100, 30, BUTTONCOL);
  powerButton = new Button("power", width - 360, 70, 100, 30, BUTTONCOL);
  voltButton = new Button("sensor", width - 260, 70, 100, 30, BUTTONCOL);
  serialButton = new Button("serial", width - 160, 70, 100, 30, BUTTONCOL);
  buttons = new Button[]{overviewButton, powerButton, voltButton, serialButton};
}

//main update cycle
void draw()
{
  println(frameRate);
  serialIO();
  drawCenterCanvas();
  drawBorderPieces();
  stroke(0);
  fill(0);
  textSize(10);
  text(DEBUGMESSAGE, 500, 500);
}

/*void serialEvent(Serial evt) {
  serialIO();
}
*/
void serialIO() {
  if (Comselected  && !serialSet) startSerial(comList);
  else if (Comselected && serialSet) {
    readSerial(); 
  }

  voltPlot.update(latestCond()); 
  powerPlot.update(latestVolt(), latestCurrent());
}

void drawCenterCanvas() {
  if (!fullscreen) {
    background(255);
    controlP5.draw();
    evalButtons();
  } else background(0);
  switch(plotMode) {
  case 0:
    overviewPlot.display();
    break;
  case 1:
    powerPlot.display();
    break;
  case 2:
    voltPlot.display();
    break;
  case 3:
    serialDisplay();
    break;
  }
}

void drawBorderPieces() {
  textAlign(LEFT);
  // DISPLAY TITLE
  textColSize("/// ROV monitor", 25, 50, DARKBLUE, 32);
  textColSize("written by Anthony Lin, modified by Joseph Chuang and Jonathan Wu, 6/15/2016", 25, 74, LIGHTGREY, 12);
  //DISPLAY VOLTAGE
  textSize(16); 
  fill(#89BFDB, 200);
  text("Power", 25, height-80);
  textSize(32);
  fill(0);
  text("volts: "+nf(latestVolt(), 1, 2), 25, height-50); //show speed bottom-left
  text("amps: "+nf(latestCurrent(), 1, 2), 15, height-20); //show speed bottom-left

  noStroke();
  textSize(20);
  // DISPLAY PULSE DETECTION
  if (serialSet == true && myPort.available() > 0) fill(GREEN);
  else fill(RED);
  text("[ pulse ]", width-200, 30);   
  // DISPLAY ROV CONNECTION
  if (connected)fill(GREEN); 
  else fill(RED);
  text("[ ROV ]", width-400, 30);
  // DISPLAY CONTROLLER CONNECTION
  if (controller)fill(GREEN); 
  else fill(RED);
  text("[ Controller ]", width-600, 30);

  textAlign(RIGHT); 
  // DISPLAY DEPTH
  textSize(16);
  fill(#89BFDB, 200);
  text("Temperature", width/3, height-65);
  textSize(32); 
  fill(0);
  text("sensor: "+nf(latestCond(), 4, 0), width/3, height-30);

textAlign(RIGHT); 
  // DISPLAY DEPTH
  textSize(16);
  fill(#89BFDB, 200);
  text("Water Pressure", width*3/4, height-65);
  textSize(32); 
  fill(0);
  text("sensor: "+nf(latestCond(), 4, 0), width*3/4, height-30);
 
  float floatpressure=float(nf(latestCond(), 4, 0));
  float floatdepth=(floatpressure-101.325)/10.052;
   
  textAlign(RIGHT); 
  // DISPLAY DEPTH
  textSize(16);
  fill(#89BFDB, 200);
  text("Depth", width-25, height-65);
  textSize(32); 
  fill(0);
  text(nf(floatdepth, 2,0)+"m", width-25, height-30);

  textAlign(CENTER); 
  // TIMER
  textSize(16); 
  fill(#89BFDB, 200);
  if (!fullscreen) text("Mission Time", width/2, height-80);
  textSize(32);
  fill(0); 
  String dispStr = nf((int) ((upTime / (1000*60)) % 60), 2)+":"+nf((int) (upTime / 1000) % 60, 2)+":"+nf((int) ((upTime) % 1000)/10, 2);
  if (!fullscreen) text(dispStr, width/2, height-30);
  else {
    fill(255);
    text(dispStr, width/2, 30);
  }
}

void evalButtons() {
  for (int i = 0; i < buttons.length; i++) {
    if (plotMode == i) buttons[i].update(mouseX, mouseY, true); 
    else buttons[i].update(mouseX, mouseY, false);
  }
}

void mousePressed() {
  for (int i = 0; i < buttons.length; i ++) if (buttons[i].buttonOver) plotMode = i;
}

void keyPressed() {
  if (key == ENTER ) fullscreen = !fullscreen;
}

void serialDisplay() {
  stroke(80); 
  strokeWeight(2);
  line(0, height-109, width, height-109);
  line(0, 100, width, 100);

  textAlign(LEFT); 
  textSize(20); 
  fill(0); 
  text("Motors:", 40, 125); 
  fill(#39B4E3);
  for (int i = 0; i < pwm.length; i++) text("pwm" + i + ": "+pwm[i], 40, 200 + 50*i);

  fill(0);  
  text("Servos:", 240, 125);
  fill(#39B4E3);
  for (int i = 0; i < servo.length; i++) text("servo" + i + ": "+servo[i], 240, 200 + 50*i);
}

void textCol(String string, int x, int y, color col) {
  fill(col);
  text(string, x, y);
}

void textColSize(String string, int x, int y, color col, int size) {
  fill(col);
  textSize(size);
  text(string, x, y);
}