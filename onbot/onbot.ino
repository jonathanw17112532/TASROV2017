#include <Servo.h>
#include <Wire.h>
#include "definitions.h"
#include "SimpleTimer.h"

Servo SERVOS[6];
uint8_t SRV[] = {A0, A1, A2, A3, A4, A5};
uint8_t temperature, pressure;
int s = 0;

/*const static uint8_t i2c_bus_addresses[9] = {0,    0x64, 0x65, 0x66, 0x67,
                                             0x68, 0x69, 0x6A, 0x6B
                                            };
*/

const static uint8_t i2c_bus_addresses[9] = {0x66, 0x67, 0x69, 0x6A};

const static uint8_t i2c_register_address = 0x00;

const static uint8_t slave_address = 11;
volatile static uint8_t servo_angles[8] = {90, 90, 90, 90, 90, 90, 90, 90};

SimpleTimer bot2Timer, sensorTimer;

volatile static uint8_t motor_direction[6] = {0, 0, 0, 0, 0, 0};
volatile static uint8_t motor_speed[6] = {0, 0, 0, 0, 0, 0};

void setup() {
  // Allow Attiny85s to initialize
  Wire.begin();  // I2C
  controlCOM.begin(38400);
  Serial.begin(9600);
  initPins();
  temperature = 20;
  bot2Timer.setInterval(200, bot2Process);
  sensorTimer.setInterval(500, sensorProcess);
  delay(3000);
}

void loop() {
  digitalWrite(13, HIGH);
  //process complete signals received from onshore

  while (controlCOM.available()) {
    if (controlCOM.available() > 20 && controlCOM.read() == 0xAA) {
      for (int i = 0; i < 6; i++) {
        motor_speed[i] = controlCOM.read();
        motor_direction[i] = controlCOM.read();
      };
      for (int i = 0; i < 8; i++) {
        servo_angles[i] = controlCOM.read();
      }
      while (controlCOM.available()) {
        controlCOM.read();
      }
    }
  }

  // pushes values to motors via i2c
  // notice that motor channels are shifted +1
  for (int i = 0; i < 4; i++) {
    motorWrite(i, motor_direction[i], motor_speed[i]);
  }

  s = (s + 2) % 255;

  for (int i = 0; i < 6; i++) {
    SERVOS[i].write(servo_angles[i]);
    Serial.print(servo_angles[i]);
    Serial.print("    ");
  }

  Serial.println();

  bot2Timer.run();
  sensorTimer.run();
  delay(15);
  digitalWrite(13, LOW);
  delay(15);
}
/**
   [motorWrite]
   @param  channel   Channel #, 1-8
   @param  direction Direction, FORWARD or REVERSE
   @param  power     Motor speed, 0-255
*/
void motorWrite(uint8_t channel, uint8_t direction, uint8_t power) {
  if (direction)
    bitSet(power, 0);
  else
    bitClear(power, 0);

  Wire.beginTransmission(i2c_bus_addresses[channel]);
  Wire.write(i2c_register_address);
  Wire.write(power);
  Wire.endTransmission();
}

void bot2Process() {
  servoPush();
  delay(50);
  char c[] = {0, 0, 0, 0};
  Wire.requestFrom(slave_address, 4);
  for (int i = 0; i < 4; i ++) {
    c[i] = Wire.read();
  }
  temperature = (c[0] - '0') * 10 + (c[1] - '0');
  pressure = (c[2] - '0') * 10 + (c[3] - '0');
}

void sensorProcess() {
  controlCOM.write((byte)sync);
  controlCOM.write(temperature);
  controlCOM.write(pressure);
}

void servoPush() {
  Wire.beginTransmission(slave_address);
  for (int i = 4; i < 6; i++) {
    uint8_t power = motor_speed[i];
    if (motor_direction[i])
      Wire.write(90 - power);
    else
      Wire.write(90 + power);
  }
  for (int i = 6; i < sizeof(servo_angles); i++) {
    Wire.write( (char) servo_angles[i]);
  }
  Wire.endTransmission();
}
