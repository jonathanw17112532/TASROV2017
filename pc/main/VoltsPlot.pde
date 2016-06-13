class VoltsPlot {
  int targetSpeed = 12; 
  int sprintSpeed = 15;
  PVector myCenter;
  float myWidth, myHeight, myMin, myMax, myPlotScale;
  color myColor;
  ArrayList plotBoxes = new ArrayList();

  int plotTimer;
  float plotInterval = 10; // in loops

  VoltsPlot(float centerX, float centerY, float myWidthi, float myHeighti, color myColori) { 
    myCenter = new PVector(centerX, centerY);
    myWidth = myWidthi; 
    myHeight = myHeighti;
    myMin = 0; 
    myMax = 1100;
    myColor = myColori;
    plotTimer = 0;
    myPlotScale = -height*0.66/myMax;
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

    for (int i=0; i<plotBoxes.size(); i++) {
      PlotBox plotBox = (PlotBox) plotBoxes.get(i);
      stroke(myColor); 
      strokeWeight(5);
      if (plotBox.isPlottable()) {
        plotBox.display();
      } else { 
        plotBoxes.remove(i);
      }
      if (i>0) {
        strokeWeight(2);
        PlotBox plotBox2 = (PlotBox) plotBoxes.get(i-1);
        line(plotBox2.myCenter.x, plotBox2.myCenter.y, plotBox.myCenter.x, plotBox.myCenter.y);
      }
    }
    popMatrix();
    displayHUD(latestCond());
  }

  void displayHUD(float value) {
    pushMatrix();
    translate(myCenter.x, myCenter.y+myHeight/2);
    pushStyle();
    fill(#FF9305); 
    noStroke(); 
    ellipseMode(CENTER);
    ellipse(0, value*myPlotScale, 10, 10);
    textAlign(LEFT); 
    fill(#89BFDB);
    textSize(16);
    text(nf(value, 1, 0), 20, value*myPlotScale+textAscent()/2);
    popStyle();
    popMatrix();
  }

  void update(float value) {
    for (int i=0; i<plotBoxes.size(); i++) {
      PlotBox plotBox = (PlotBox) plotBoxes.get(i);
      plotBox.update();
    }

    if (plotTimer > plotInterval) {
      addPlotBox(value);
      plotTimer = 0;
    } else plotTimer++;
  }

  void addPlotBox(float value) {
    plotBoxes.add(new PlotBox(myPlotScale*(value), myColor, int(myWidth)));
  }
}