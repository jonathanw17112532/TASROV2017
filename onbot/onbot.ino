#include <Servo.h>
#include <Wire.h>
#include "definitions.h"
#include "SimpleTimer.h"

Servo SERVOS[6];
uint8_t SRV[] = {A0, A1, A2, A3, A4, A5};
uint8_t temperature, pressure;

const static uint8_t i2c_bus_addresses[9] = {0,    0x64, 0x65, 0x66, 0x67,
                                             0x68, 0x69, 0x6A, 0x6B
                                            };
const static uint8_t i2c_register_address = 0x00;

const static uint8_t slave_address = 11;
volatile static uint8_t servo_angles[8] = {45, 90, 90, 90, 90, 90, 90, 90};

SimpleTimer bot2Timer;

volatile static uint8_t motor_direction[6] = {0, 0, 0, 0, 0, 0};
volatile static uint8_t motor_speed[6] = {0, 0, 0, 0, 0, 0};

void setup() {
  delay(1000);   // Allow Attiny85s to initialize
  Wire.begin();  // I2C
  controlCOM.begin(38400);
  initPins();
  temperature = 20;
  Serial.begin(9600);
  bot2Timer.setInterval(200, bot2Process);
}

void loop() {
  delay(50);
  //process complete signals received from onshore
  if (controlCOM.available() > 14 && controlCOM.read() == 0xAA) {
    digitalWrite(13, HIGH);
    for (int i = 0; i < 6; i++) {
      motor_speed[i] = controlCOM.read();
      motor_direction[i] = controlCOM.read();
    };
    for (int i = 0; i < 7; i++) {
      servo_angles[i] = controlCOM.read();
    }
  }
  // pushes values to motors via i2c
  // notice that motor channels are shifted +1
  for (int i = 0; i < 4; i++) {
    motorWrite(i + 1, motor_direction[i], motor_speed[i]);
  }

  for (int i = 0; i < 6; i++) {
    SERVOS[i].write(servo_angles[i]);
  }

  bot2Timer.run();
  Serial.println(motor_speed[0]);
  Serial.println(motor_speed[1]);
  Serial.println(motor_speed[2]);
  Serial.println(motor_speed[3]);

  controlCOM.write((byte)sync);
  controlCOM.write(temperature);
  controlCOM.write(pressure);

  digitalWrite(13, LOW);
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

void servoPush() {
  Wire.beginTransmission(slave_address);
  for (int i = 4; i < 6; i++) {
    uint8_t power = motor_speed[i];
    if (motor_direction[i])
      bitSet(power, 0);
    else
      bitClear(power, 0);
    Wire.write(90 + power);
  }
  for (int i = 6; i < sizeof(servo_angles); i++) {
    Wire.write( (char) servo_angles[i]);
  }
  Wire.endTransmission();
}
