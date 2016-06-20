inline void initPins(void) {

  for (int i = 0; i < 6; i ++){
    pinMode(SRV[i], OUTPUT);
    SERVOS[i].attach(SRV[i]);
  }

  pinMode(13, OUTPUT);
}
