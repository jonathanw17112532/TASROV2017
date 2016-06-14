void transmit(int servoval[]) {
  BOTSIDE.write((byte)sync);
  for (int x = 0; x < 6; x++) {
    BOTSIDE.write(motorPWM[x]);
    BOTSIDE.write(motorDIR[x]);
  }
  for (int i=0; i<7; i++){
    BOTSIDE.write(servoval[i]);
  }
}

void receiveData() {

  if (BOTSIDE.available() && BOTSIDE.read() == 0xAA) {
    motorFault = BOTSIDE.read();
    for (int x = 0; x < 6; x++) conv.bytes[x] = BOTSIDE.read();
    voltage = conv.val;
    lastReceive = millis();
  }
  
  if (millis() - lastReceive > 10) {
    digitalWrite(outputPins[1], LOW);
    pulse = 0;
  }
  else {
    digitalWrite(outputPins[1], HIGH);
    pulse = 1;
  }
}

void telemetry() {
  PCSIDE.print("voltage=");
  PCSIDE.print(voltage);

  PCSIDE.print("&current=");
  PCSIDE.print(amps);

  PCSIDE.print("&pressure=");
  PCSIDE.print(pressure);

  PCSIDE.print("&conductivity=");
  PCSIDE.print(analogRead(condSensor));

  PCSIDE.print("&mtr1=");
  if (!bitRead(motorFault, 0)) PCSIDE.print(motorCalc[0]);
  else PCSIDE.print(-1);

  PCSIDE.print("&mtr2=");
  if (!bitRead(motorFault, 1)) PCSIDE.print(motorCalc[1]);
  else PCSIDE.print(-1);

  PCSIDE.print("&mtr3=");
  if (!bitRead(motorFault, 2)) PCSIDE.print(motorCalc[2]);
  else PCSIDE.print(-1);

  PCSIDE.print("&mtr4=");
  if (!bitRead(motorFault, 3)) PCSIDE.print(motorCalc[3]);
  else PCSIDE.print(-1);

  PCSIDE.print("&mtr5=");
  if (!bitRead(motorFault, 4)) PCSIDE.print(motorCalc[4]);
  else PCSIDE.print(-1);

  PCSIDE.print("&mtr6=");
  if (!bitRead(motorFault, 5)) PCSIDE.print(motorCalc[5]);
  else PCSIDE.print(-1);

  PCSIDE.print("&servo1=");
  PCSIDE.print(servo1);

  PCSIDE.print("&servo2=");
  PCSIDE.print(servo2);

  PCSIDE.print("&servo3=");
  PCSIDE.print(servo3);

  PCSIDE.print("&servo4=");
  PCSIDE.print(servo4);

  PCSIDE.print("&servo5=");
  PCSIDE.print(servo5);

  PCSIDE.print("&servo6=");
  PCSIDE.print(servo6);

  PCSIDE.print("&connected=");
  PCSIDE.print(pulse);

  PCSIDE.print("&uptime=");
  PCSIDE.print(constrain(missionTime - millis() + timer, 0, 1000000000));

  PCSIDE.println();
}





