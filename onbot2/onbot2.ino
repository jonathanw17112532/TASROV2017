#include <Servo.h>
#include <Wire.h>
#include "definitions.h"
#include "OneWire.h"
#include "DallasTemperature.h"

// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 12

OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);

Servo SERVOS[4];

uint8_t temperature = 0, pressure = 0;

volatile static uint8_t servo_angles[] = {89, 89, 89, 89};

void setup() {
  Serial.begin(9600);
  sensors.begin();
  Wire.begin(11);  // I2C
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);
  initPins();
  delay(1000);
}

void loop() {
  delay(50);
  sensors.requestTemperatures();
  temperature = (sensors.getTempCByIndex(0));
  pressure = analogRead(A5) / 10;
}

void receiveEvent(int howMany) {
  for (int i = 0; i < 4; i++) {
    uint8_t x = Wire.read();
    servo_angles[i] = x;
    SERVOS[i].write(servo_angles[i]);
    Serial.println(servo_angles[i]);
  }
}

void requestEvent() {
  String sendThis = (String)(temperature * 100 + pressure);
  Wire.write(sendThis.c_str());
}
