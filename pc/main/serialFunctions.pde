void controlEvent(ControlEvent theEvent) {
  float S = theEvent.getValue();
  try {
    myPort.stop();
  }
  catch(Exception e) {
  }
  Ss= int(S);
  Comselected = true;
  serialSet = false;
}
//handles the dropdown menu on select

public void refresh() {
  ports.clear();
  customize(ports);
}
//refreshes dropdown menu - handles refresh button

void customize(DropdownList ddl) {
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.setCaptionLabel("Select COM port");
  //Store the Serial ports in the string comList (char array).
  comList = myPort.list();
  for (int i=0; i< comList.length; i++)
  {
    ddl.addItem(comList[i], i);
  }
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
//sets up the dropdown menu

void startSerial(String[] theport){
  //When this function is called, we setup the Serial connection with the accuried values. The int Ss acesses the determins where to accsess the char array. 
  try {
    myPort = new Serial(this, theport[Ss], baudRate);
    println(theport[Ss]);
    serialSet = true;
  }catch(RuntimeException e) {
    serialSet = false;
  }
}
//attemps to start serial channel

void readSerial() {
  String val;
  if (myPort.available() > 0) {            // If data is available,
    val = myPort.readStringUntil('\n');//StringUntil(10);     // read until line break and store it in val
    DEBUGMESSAGE = val;
    val = trim(val);      // trim whitespace off the ends
    update(val);
    lastPulseTime = millis();
  }
}
//attempts a serial read - on success, evaluates and updates

void update(String val) {
  try {
    if (val != null) {
      String[] pairs = split(val, "&");  // this & character separates the incomming data
      for (int i=0; i<pairs.length; i++) {
        println(pairs[i]);
        String[] pair = split(pairs[i], "=");
        //  note capital "F" in float for ArrayLists!
        for (int ii = 0; ii < logs.length; ii ++) if (pair[0].equals(logTags[ii])) logs[ii].add(new Float(pair[1]));
        for (int ii = 0; ii < pwm.length; ii++) if (pair[0].equals("mtr" + (1 + ii))) pwm[ii] =  int(pair[1]);
        for (int ii = 0; ii < servo.length; ii++) if (pair[0].equals("servo" + (1 + ii))) servo[ii] =  int(pair[1]);
        for (int ii = 0; ii < actuator.length; ii++) if (pair[0].equals("actuator" + (1 + ii))) actuator[ii] =  int(pair[1]);

        if (pair[0].equals("connected")) connected = (int(pair[1]) != 0);
        if (pair[0].equals("ps4")) controller = (int(pair[1]) != 0);
        if (pair[0].equals("uptime")) upTime = Long.valueOf(pair[1]).longValue(); 
      }
    }
  }
  catch(Exception e) {
  }
  for (int x = 0; x < logs.length; x++) {
    if (logs[x].size() > 200) logs[x].remove(0);
    // if the speedLog is full (1000) values, then remove/decay values
  }
}
// unscrambles serial string and updates local control variables - feed as a param

float latestVolt() {
  if (logs[0].size() > 0) {
    return (Float)logs[0].get(logs[0].size()-1);
  } else return 0.00;
}

float latestCurrent() {
  if (logs[1].size() > 0) {
    return (Float)logs[1].get(logs[1].size()-1);
  } else return 0.00;
}

float latestCond() {
  if (logs[2].size() > 0) {
    return (Float)logs[2].get(logs[0].size()-1);
  } else return 0.00;
}

float[] latestMtr() {
  float[] temp = new float[4];
  for (int x = 3; x < 7; x++) {
    if (logs[x].size() > 0) temp[x-6] = (Float)logs[x].get(logs[x].size()-1); 
    else temp[x-6] = 0.00;
  }
  //  temp = new float[] {random(0, 2), random(2, 3), random(3, 4),random(4, 5)};
  return temp;
}