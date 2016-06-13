class OverviewPlot {
  PImage rov;
  mtrDial left1, left2;
  mtrDial right1, right2;
  mtrDial vert1, vert2;
  int dataShift = 0;
  int imageShift = 300;
  ArrayList<PImage> cache = new ArrayList<PImage>();

  OverviewPlot() { 
    rov = loadImage("ROV-MTR.png");
    left1 = new mtrDial(width/2 -250 + dataShift, height/2-100);
    left2 = new mtrDial(width/2 -250 + dataShift, height/2+150);
    right1 = new mtrDial(width/2 +250 + dataShift, height/2-100);
    right2 = new mtrDial(width/2 +250 + dataShift, height/2+150);
    vert1 = new mtrDial(width/2 + dataShift, height/2 - 70, 60, 26);
    vert2 = new mtrDial(width/2 + dataShift, height/2 + 170, 60, 26);
  }

  void display() {
    if (!fullscreen) {
      stroke(80);
      strokeWeight(2);
      line(0, height-109, width, height-109);
      line(0, 100, width, 100);
    }
    imageMode(CENTER);
    if (cache.size() > 2) {
      PImage temp = cache.remove(0);
      if (!fullscreen) image(temp, width/2 + imageShift, height/2-5, temp.width*(height-219)/temp.height, height-219);
      else image(temp, width/2, height/2, temp.width*height/temp.height, height);
    }
    if (!fullscreen) {
      image(rov, width/2 + dataShift, height/2);
      left1.update(pwm[0]);
      left2.update(pwm[1]);
      right1.update(pwm[2]);
      right2.update(pwm[3]);
      vert1.update(pwm[4]);
      vert2.update(pwm[5]);

      ellipseMode(CENTER);
      textMode(CENTER);
      strokeWeight(4);
      textAlign(CENTER);
      textSize(16);
      stroke(220);
   
      ellipse(width/2 +130 + dataShift, height/2-155, 50, 50);
      fill(0);
      text("arm", width/2 +130 + dataShift, height/2-150);
      fill (255);
      ellipse(width/2 -130 + dataShift, height/2-155, 50, 50);
      fill(0);
      text("claw", width/2 -130 + dataShift, height/2-150);
    }
  }
}