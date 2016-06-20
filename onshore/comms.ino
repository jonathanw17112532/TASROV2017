void transmit() {
  BOTSIDE.write((byte)sync);
  for (int x = 0; x < 6; x++) {
    BOTSIDE.write(motorPWM[x]);
    BOTSIDE.write(motorDIR[x]);
  }
  for (int i = 0; i < 8; i++) {
    BOTSIDE.write((uint8_t)servoValues[i]);
  }
}

void receiveData() {
  if (BOTSIDE.available() && BOTSIDE.read() == 0xAA) {
    temperature = BOTSIDE.read();
    pressure = BOTSIDE.read();
    while (BOTSIDE.available()) {
      BOTSIDE.read();
    }
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
  PCSIDE.print("voltage=" + String(voltage));
  PCSIDE.print("&current=" + String(amps));
  PCSIDE.print("&pressure=" + String(pressure));
  
  PCSIDE.print("&temperature=");
  PCSIDE.print(temperature);
  
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

  for (int i = 0; i < 8; i ++) {
    PCSIDE.print("&servo");
    PCSIDE.print(i + 1);
    PCSIDE.print("=");
    PCSIDE.print(servoRaws[i]);
  };
  
  PCSIDE.print("&connected=");
  PCSIDE.print(pulse);

  PCSIDE.print("&uptime=");
  PCSIDE.print(constrain(missionTime - millis() + timer, 0, 1000000000));

  PCSIDE.println();
}





