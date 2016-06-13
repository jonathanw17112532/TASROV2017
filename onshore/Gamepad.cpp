/*
  stick: id 1-4 mapped to 0-3 in array
  1: left x
  2: left y
  3: right x
  4: right y

  hat:
  0: not pressed
  1-8: top, top right, (clockwise etc)

  buttons: id 1-12 mapped to 0-11 in array
  1-10: buttons as labeled
  11: left stick click
  12: right stick click
*/

#include "Gamepad.h"

Gamepad :: Gamepad() {
}

int Gamepad :: getStk(int _i) {
  return stick[_i - 1];
}

boolean Gamepad :: getBtn(int _i) {
  return buttons[_i-1];
};

int Gamepad :: getHat() {
  return hat;
}

void Gamepad::Parse(HID *hid, bool is_rpt_id, uint8_t len, uint8_t *buf) {
  // Calling Game Pad event handler
  const GamePadEventData *temp = (const GamePadEventData*)buf;
  stick[0] = temp->X;
  stick[1] = temp->Y;
  stick[2] = temp->Z1;
  stick[3] = temp->Z2;

  hat = temp->Rz;

  int _hat = (buf[5] & 0xF);

  for (int i = 0; i < 4; i ++) {
    buttons[4 + i] = (_hat >> i) & 1;
  }

  uint16_t _but = (0x0000 | buf[6]);
  _but <<= 4;
  _but |= (buf[5] >> 4);
  _but -= 1088;

  for (int i = 0; i < 4; i ++) {
    buttons[8 + i] = (_but >> i) & 1;
  }
}
