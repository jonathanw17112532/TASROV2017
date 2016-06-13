void zeroMotors() {
  for (int x = 0; x < 6; x++) {
    motorPWM[x] = 0;
    motorDIR[x] = 0;
  }
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

  
  /*
    if (PS4.getButtonPress(UP) || PS4.getButtonPress(DOWN)) {
      if (PS4.getButtonPress(UP)) {
        motorPWM[4] = 255;
        motorDIR[4] = 0;
        motorPWM[5] = 255;
        motorDIR[5] = 0;
      }
      else if (PS4.getButtonPress(DOWN)) {
        motorPWM[4] = 255;
        motorDIR[4] = 1;
        motorPWM[5] = 255;
        motorDIR[5] = 1;
      }

    }
    else {

      if (motorCalc[4] > 10) {
        motorPWM[4] = motorCalc[4];
        motorPWM[5] = motorCalc[4];
        motorDIR[4] = 0;
        motorDIR[5] = 1;
      }
      else if (motorCalc[5] > 10) {
        motorPWM[4] = motorCalc[5];
        motorPWM[5] = motorCalc[5];
        motorDIR[4] = 1;
        motorDIR[5] = 0;
      }
      else {
        motorPWM[4] = 0;
        motorPWM[5] = 0;
        motorDIR[4] = 0;
        motorDIR[5] = 0;
      }
    }
  */

  //char buff[100];
  //sprintf(buff, "Motor: %d %d %d %d  %d  %d  %d", motorPWM[0], motorPWM[1], motorPWM[2], motorPWM[3], motorPWM[4], motorPWM[5], servo1);
  //PCSIDE.println(buff);

}

void updateServos() {
  if (millis() - servoUpdate > delayThreshold + 10) {
    /*if (PS4.getButtonPress(TRIANGLE)) servo1 -= SERVORATE;
      if (PS4.getButtonPress(CROSS)) servo1 += SERVORATE;
    */
    if (servo1 > 180) servo1 = 180;
    if (servo1 < 3) servo1 = 2;

    servoUpdate = millis();
  }
}

void updatePeripherals() {
  /*if(PS4.getButtonClick(R1)) armGrab = !armGrab;
    if(PS4.getButtonClick(L1)) armSwivel = !armSwivel;

    if(PS4.getButtonClick(TOUCHPAD)) timer = millis();
    //if(PS4.getButtonClick(SHARE))
    //servo1 = 90;

    if(armGrab) bitWrite(pneumatics, 1, 1);
    else bitWrite(pneumatics, 1, 0);
    if(armSwivel) bitWrite(pneumatics, 0, 1);
    else bitWrite(pneumatics, 0, 0);*/
}

int convert(int pwm, int dir){
  int out = 128;
  if(dir == 1) out + map(pwm, 0, 255, 0, 128);
  else out - map(pwm, 0, 255, 0, 128);
  
  return out;
}



