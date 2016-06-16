inline void initPins(void) {

  pinMode(POWER_SENSE, INPUT);
  pinMode(STATUS_LED_1, OUTPUT);
  pinMode(STATUS_LED_2, OUTPUT);

  pinMode(A11, INPUT);
  pinMode(A10, INPUT);

  for (int i = 0; i < sizeof(SERVOS); i ++){
    pinMode(SRV[i], OUTPUT);
    SERVOS[i].attach(SRV[i]);
  }

  pinMode(13, OUTPUT);
}
