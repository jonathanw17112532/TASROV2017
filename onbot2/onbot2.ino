#include <Servo.h>
#include <Wire.h>
#include "definitions.h"

Servo SERVOS[2];
int SRV[] = {22, 33};

// const static uint8_t i2c_bus_addresses[9] = {0, 0x64, 0x65, 0x66, 0x67, 0x68,
// 0x69, 0x6A, 0x6B};

const static uint8_t servo_addresses[2] = {11,12};
volatile static uint8_t servo_angles[2];


void setup() {
  delay(1000);     // Allow Attiny85s to initialize
  Wire.begin(11);  // I2C
  Wire.onReceive(receiveEvent);
  controlCOM.begin(38400);
  initPins();
  digitalWrite(13, HIGH);  // Signal initialization complete
}

void loop() {
  delay(100);
  for (int i = 0; i < sizeof(SERVOS); i++) {
    SERVOS[i].write(servo_angles[i]);
  }
}

void receiveEvent(int howMany) {
  for (int i = 0; i < sizeof(SERVOS); i++) {
    int x = Wire.read();
    servo_angles[i] = x;
  }
}
