void updateJoystick() {

  int leftX, leftY, rightX, rightY;
  leftX = map(Joy.getStk(1), 0, 255, -128, 128);
  leftY = map(Joy.getStk(2), 0, 255, -128, 128);
  rightX = map(Joy.getStk(3), 0, 255, -128, 128);
  rightY = map(Joy.getStk(4), 0, 255, -128, 128);

  motorCalc[0] = constrain(rightY - rightX, -128, 128);
  motorCalc[1] = constrain(leftY + leftX, -128, 128);
  motorCalc[2] = constrain(leftY - leftX, -128, 128);
  motorCalc[3] = constrain(-rightY -rightX, -128, 128);

  motorCalc[4] = Joy.getBtn(8) - Joy.getBtn(6);
  motorCalc[5] = Joy.getBtn(8) - Joy.getBtn(6);

  if (motorCalc[4] != 0)
  {
    motorCalc[0] = 0;
    motorCalc[1] = 0;
    motorCalc[2] = 0;
    motorCalc[3] = 0;
  }

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

  motorPWM[4] = motorCalc[4] * 12;
  motorPWM[5] = motorCalc[5] * 12;
}

void updateServos() {
  for (int i = 0; i < 6; i++) {
    servoRaws[i] = analogRead(servoPorts[i]);
    servoRaws[i] = constrain(servoRaws[i], servoRanges[i][0], servoRanges[i][1]);
    servoValues[i] = map(servoRaws[i], servoRanges[i][0], servoRanges[i][1], servoRanges[i][2], servoRanges[i][3]);
  };

  servoRaws[6] += 60*(Joy.getBtn(7) - Joy.getBtn(5));
  servoRaws[6] = constrain(servoRaws[6], 130, 170);
  servoValues[6] = servoRaws[6];
}

int convert(int pwm, int dir) {
  int out = 128;
  if (dir == 1) out + map(pwm, 0, 255, 0, 128);
  else out - map(pwm, 0, 255, 0, 128);

  return out;
}

void zeroMotors() {
  for (int x = 0; x < 6; x++) {
    motorPWM[x] = 0;
    motorDIR[x] = 0;
  }
}
