#include <hid.h>
#include <hiduniversal.h>
#include <usbhub.h>

#ifdef dobogusinclude
#include <spi4teensy3.h>
#include <SPI.h>
#endif

#include "definitions.h"
#include "Gamepad.h"

USB Usb;
USBHub Hub(&Usb);
HIDUniversal Hid(&Usb);
IntervalTimer pcTimer, botTimer;

Gamepad Joy;

void setup() {
  BOTSIDE.begin(38400);
  PCSIDE.begin(9600);
  Serial.println("------BOOT------");
  //init serial

  for (int x = 0; x < sizeof(inputPins); x++) pinMode(inputPins[x], INPUT);
  for (int x = 0; x < sizeof(outputPins); x++) pinMode(outputPins[x], OUTPUT);
  //init pins - see header

  if (Usb.Init() == -1)
    Serial.println("OSC did not start.");

  delay(200);

  if (!Hid.SetReportParser(0, &Joy))
    ErrorMessage<uint8_t > (PSTR("SetReportParser"), 1);

  delay(1000);
  pcTimer.begin(telemetry, 200000);
}

void controlOutput() {
  updateJoystick();
  updateMotors();
  updateServos();
  transmit();
  receiveData();
}

void loop() {
  while (true) {
    Usb.Task();
    controlOutput();

    delay(20);
  }
}



