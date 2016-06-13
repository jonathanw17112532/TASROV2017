class PowerPlot {
  PVector myCenter;
  float myWidth; 
  float myHeight;
  float myMin; 
  float myMax;
  color[] myColor = new color[2];
  float[] myPlotScale = new float[2];
  ArrayList[] plotBoxes = new ArrayList[2];

  int plotTimer;
  int plotSpeedTimer = 0;
  float plotInterval = 10; // in loops
  float plotSpeed = 0;

  PowerPlot(float centerX, float centerY, float myWidthi, float myHeighti, color[] myColori) { 
    myColor = myColori;
    myCenter = new PVector(centerX, centerY);
    myWidth = myWidthi; 
    myHeight = myHeighti;
    myMin = 0; 
    myMax = 25;
    plotTimer = 0;

    myPlotScale[0] = -height*0.12/5;
    myPlotScale[1] = -height*0.12/5;

    for (int x = 0; x < plotBoxes.length; x++) plotBoxes[x] = new ArrayList();
  }

  void display() {
    stroke(80); 
    strokeWeight(2);
    line(0, height-109, width, height-109);
    line(0, 100, width, 100);
    float difference = height*0.66/6;
    for (int x = 1; x < 6; x++) {
      stroke(200, 150); 
      strokeWeight(1);
      line(0, height-height*0.18-x*difference, width, height-height*0.18-x*difference);
    }
    
    pushMatrix();
    translate(myCenter.x, myCenter.y+myHeight/2);
    for (int x = 0; x<plotBoxes.length; x++) {
      for (int i=0; i<plotBoxes[x].size (); i++) {
        stroke(myColor[x]); 
        strokeWeight(5);
        PlotBox plotBox = (PlotBox) plotBoxes[x].get(i);
        if (plotBox.isPlottable()) {
          plotBox.display();
        } else {
          plotBoxes[x].remove(i);
        }
        if (i>0) {
          strokeWeight(2);
          PlotBox plotBox2 = (PlotBox) plotBoxes[x].get(i-1);
          line(plotBox2.myCenter.x, plotBox2.myCenter.y, plotBox.myCenter.x, plotBox.myCenter.y);
        }
      }
    }
    popMatrix();
    displayHUD(latestVolt(), latestCurrent());
  }

  void displayHUD(float valueA, float valueB) {
    float[] value = {
      valueA, valueB
    };
    for (int x = 0; x < value.length; x++) {
      pushMatrix();
      translate(myCenter.x, myCenter.y+myHeight/2);
      pushStyle();
      fill(#FF9305); 
      noStroke(); 
      ellipseMode(CENTER);
      ellipse(0, value[x]*myPlotScale[x]-10, 10, 10);
      textAlign(LEFT); 
      fill(#89BFDB);
      textSize(16);
      if (x == 0) text(nf(value[x], 1, 2) + " V", 20, value[x]*myPlotScale[x]-10+textAscent()/2);
      if (x == 1) text(nf(value[x], 1, 2) + " A", 20, value[x]*myPlotScale[x]-10+textAscent()/2);
      popStyle();
      popMatrix();
    }
  }

  void update(float valueA, float valueB) {
    float[] value = {
      valueA, valueB
    };
    for (int x = 0; x<plotBoxes.length; x++) {
      for (int i=0; i<plotBoxes[x].size (); i++) {
        PlotBox plotBox = (PlotBox) plotBoxes[x].get(i);
        plotBox.update();
      }
    }
    if (plotTimer > plotInterval) {
      addPlotBox(value);
      plotTimer = 0;
    } else plotTimer++;
  }

  void addPlotBox(float[] value) {
    for (int x = 0; x < value.length; x++) {
      plotBoxes[x].add(new PlotBox(myPlotScale[x]*(value[x])-10, myColor[x], int(myWidth)));
    }
  }
}