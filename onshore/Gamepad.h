#if !defined(__GAMEPAD_H__)
#define __GAMEPAD_H__

#include <hid.h>
#define RPT_GEMEPAD_LEN    5

struct GamePadEventData {
  uint8_t X, Y, Z1, Z2, Rz;
};

class Gamepad : public HIDReportParser {
    //JoystickEvents *joyEvents;
  private:
    int stick[4] = { 0 };
    boolean buttons[12] = { false };
    int hat = 0;
    boolean connected = false;

  public:
    Gamepad();//JoystickEvents *evt);
    virtual void Parse(HID *hid, bool is_rpt_id, uint8_t len, uint8_t *buf);
    void init();
    void update();
    int getStk(int);
    boolean getBtn(int);
    int getHat();
};

#endif
