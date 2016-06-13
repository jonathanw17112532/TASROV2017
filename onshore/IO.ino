void updateJoystick() {
  
    int leftX, leftY, rightX, rightY;
    leftY = map(Joy.getStk(1), 0, 255, -128, 128);
    leftX = map(Joy.getStk(2), 0, 255, -128, 128);
    rightY = map(Joy.getStk(3), 0, 255, -128, 128);
    rightX = map(Joy.getStk(4), 0, 255, -128, 128);

    motorCalc[0] = leftY;//constrain(-1*(leftY + leftX), -128, 128);
    motorCalc[1] = leftX;//constrain(leftY - leftX, -128, 128);
    motorCalc[2] = rightY;//constrain((rightY - rightX), -128, 128);
    motorCalc[3] = rightX;//constrain((rightY + rightX), -128, 128);
    motorCalc[4] = Joy.getBtn(7);
    motorCalc[5] = Joy.getBtn(8);

    //PCSIDE.println(Joy.getBtn(7));

    //if(PS4.getButtonClick(OPTIONS)) PCSIDEMode = !PCSIDEMode;
  
}

void current() {
  char buff1[16];
  amps = ((float)3.3 * ((float)analogRead(A0) / (float)1024) - (float)1.65) / (float)0.055;
  sprintf(buff1, " CURRENT:  %2.2f ", constrain(amps, 0, 30));
  //PCSIDE.print(buff1);
}
