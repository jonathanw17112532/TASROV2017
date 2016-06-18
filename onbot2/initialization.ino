inline void initPins(void) {

  for (int i = 0; i < sizeof(SRV); i++) {
    pinMode(SRV[i], OUTPUT);
    SERVOS[i].attach(SRV[i]);
  }

  pinMode((int)13, OUTPUT);
}
