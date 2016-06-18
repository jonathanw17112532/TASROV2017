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

void updateMotors() {
  for (int x = 0; x < 4; x++) {
    if (motorCalc[x] < 0) {
      motorPWM[x] = map(motorCalc[x], 0, -128, 0, 255);
      motorDIR[x] = 1;
    }
    else if (motorCalc[x] > 0) {
      motorPWM[x] = map(motorCalc[x], 0, 128, 0, 255);
      motorDIR[x] = 0;
    }
    else {
      motorPWM[x] = 0;
      motorDIR[x] = 0;
    }
  }

  motorPWM[4] = motorCalc[4]*100;
  motorPWM[5] = motorCalc[5]*100;
}

void updateServos() {
  for (int i = 0; i < 6; i++) {
      servoValues[i] = analogRead(servoPorts[i]);
  };
}

int convert(int pwm, int dir){
  int out = 128;
  if(dir == 1) out + map(pwm, 0, 255, 0, 128);
  else out - map(pwm, 0, 255, 0, 128);
  
  return out;
}

void zeroMotors() {
  for (int x = 0; x < 6; x++) {
    motorPWM[x] = 0;
    motorDIR[x] = 0;
  }
}
