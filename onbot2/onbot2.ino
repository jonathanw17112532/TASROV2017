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

volatile static uint8_t servo_angles[] = {90, 90, 90, 90};

void setup() {
  Serial.begin(9600);
  sensors.begin();
  Wire.begin(11);  // I2C
  Wire.onReceive(receiveEvent);
  Wire.onRequest(requestEvent);
  initPins();
  delay(2000);
}

void loop() {
  sensors.requestTemperatures();
  temperature = (sensors.getTempCByIndex(0));
  pressure = analogRead(A5) / 10;
  delay(50);
}

void receiveEvent(int howMany) {
  for (int i = 0; i < 4; i++) {
    uint8_t x = Wire.read();
    if (x < 180) {
      servo_angles[i] = x;
      SERVOS[i].write(servo_angles[i]);
    }
    Serial.print(servo_angles[i]);
    Serial.print("   ");
  }
  Serial.println();
}

void requestEvent() {
  String sendThis = (String)(temperature * 100 + pressure);
  Wire.write(sendThis.c_str());
}
