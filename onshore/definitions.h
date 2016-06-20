#define BOTSIDE Serial1
#define PCSIDE Serial

#define delayThreshold 10
#define joystickThreshold 12
#define SERVORATE 1
#define sync 0xAA
#define missionTime 900000

volatile uint8_t motorPWM[] = {
  0, 0, 0, 0, 0, 0
};
volatile uint8_t motorDIR[] = {
  0, 0, 0, 0, 0, 0
};
volatile int motorCalc[] = {
  0, 0, 0, 0, 0, 0
};

uint8_t inputPins[] = {
};

uint8_t outputPins[] = {
  13
};

volatile uint16_t servoUpdate = 0;
volatile uint16_t pneumaticUpdate = 0;

volatile int servoRaws[] = {
  90, 90, 90, 90, 90, 90, 130, 90
};

volatile int servoValues[] = {
  90, 90, 90, 90, 90, 90, 130, 90
};

uint8_t servoPorts[] = {
  1, 2, 3, 4, 5, 6
};

volatile uint8_t pressure = 0;
volatile uint8_t temperature = 0;

volatile float voltage = 0.00;
volatile float amps = 0.00;
volatile uint8_t motorFault = 0;

volatile boolean controller = false;

volatile int pulse = 0;
volatile long timer = 0;
volatile long lastReceive = 0;

union conv_tag {
  byte bytes[4];
  float val;
}
conv;

int servoRanges[6][4] = {{
    280, 460, 45, 95
  }, {
    90, 630, 160, 20
  }, {
    430, 900, 10, 170
  }, {
    100, 500, 140, 20
  }, {
    300, 775, 20, 150
  }, {
    150, 800, 10, 170
  }
};

