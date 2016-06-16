#include <Servo.h>
#include <Wire.h>
#include "definitions.h"
#include "OneWire.h"
#include "DallasTemperature.h"
 
// Data wire is plugged into pin 12 on the Arduino
#define ONE_WIRE_BUS 12
 
// Setup a oneWire instance to communicate with any OneWire devices 
// (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
 
// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);

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
  
   // start serial port
  Serial.begin(9600);
  Serial.println("Dallas Temperature IC Control Library Demo");

  // Start up the library
  sensors.begin();
}

void loop() {
  for (int i = 0; i < sizeof(SERVOS); i++) {
    SERVOS[i].write(servo_angles[i]);
  }
  
  // call sensors.requestTemperatures() to issue a global temperature
  // request to all devices on the bus
  Serial.print(" Requesting temperatures...");
  sensors.requestTemperatures(); // Send the command to get temperatures
  Serial.println("DONE");

  Serial.print("Temperature for Device 1 is: ");
  Serial.print(sensors.getTempCByIndex(0)); // Why "byIndex"? 
    // You can have more than one IC on the same bus. 
    // 0 refers to the first IC on the wire
    delay(100);
 
}

void receiveEvent(int howMany) {
  for (int i = 0; i < sizeof(SERVOS); i++) {
    int x = Wire.read();
    servo_angles[i] = x;
  }
}


