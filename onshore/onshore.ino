#include <Servo.h>

#include <hid.h>
#include <hiduniversal.h>
#include <usbhub.h>

#ifdef dobogusinclude
#include <spi4teensy3.h>
#include <SPI.h>
#endif

#include "definitions.h"
#include "Gamepad.h"
#include "SimpleTimer.h"

//USB and controller setup
USB Usb;
USBHub Hub(&Usb);
HIDUniversal Hid(&Usb);
Gamepad Joy;

//Timer for transmissions
SimpleTimer pcTimer, botTimer;

void setup() {
  // init serial
  BOTSIDE.begin(38400);
  PCSIDE.begin(9600);
  Serial.println("------BOOT------");

  // init pins - see definitions.h
  for (int x = 0; x < sizeof(inputPins); x++) pinMode(inputPins[x], INPUT);
  for (int x = 0; x < sizeof(outputPins); x++) pinMode(outputPins[x], OUTPUT);

  if (Usb.Init() == -1) Serial.println("OSC did not start.");


  if (!Hid.SetReportParser(0, &Joy))
    ErrorMessage<uint8_t>(PSTR("SetReportParser"), 1);
    
  //transmits to PC every 200ms
  pcTimer.setInterval(200, telemetry);
}

void controlOutput() {
  updateJoystick();
  updateMotors();
  updateServos();
  transmit();
  receiveData();
  pcTimer.run();
}

void loop() {
  //runs the controller libraries
  Usb.Task();
  controlOutput();
  delay(100);
}
