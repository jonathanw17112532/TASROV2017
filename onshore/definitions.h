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
  A0, A3
};

uint8_t outputPins[] = {
  13, A2
};

volatile uint8_t condSensor = A3;

volatile uint16_t servoUpdate = 0;
volatile uint16_t pneumaticUpdate = 0;

volatile int servoValues[] = {
  0, 0, 0, 0, 0, 0, 0
};

int servoPorts[] = {
	1, 2, 3, 4, 5, 6
};

volatile float pressure = 0.00;

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

