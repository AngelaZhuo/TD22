#include <SPI.h> //Serial Peripheral Interface to manipulate periphal devices
#include <Wire.h> // allows you to communicate with I2C / TWI (two wire interfaces) devices
//inkludiert weittere libraries
//<>sucht im libraries Ordner #include SPI.h sucht im Sketch Ordner
#include <C:\Users\Anwender\Desktop\desktop old\ExperimentalControl_21092018_LW\ADfunctions\ADfunctions.ino>
#include <C:\Users\Anwender\Desktop\desktop old\ExperimentalControl_21092018_LW\ValveControllerComm\ValveControllerComm.ino>
#include <C:\Users\Anwender\Desktop\desktop old\ExperimentalControl_21092018_LW\OdorFunctions\OdorFunctions.ino>
//inkludiert weitere sketches

//#define BEAM1     37 //benennt Variablen, die so verständlicher im Code verwendet werden können
//#define BEAM2     36 // verbraucht keinen Speicher, was ist sonst der Vorteil von define im Gegensatz zu const int/long...??

#define fv 1

#define SOLENOID1 29 //what do these numbers stay for? too high for existing pins ??? -> corresponding to Wire or SPI?
#define SOLENOID2 28 //cylindrical metal coil magnet
#define SOLENOID3 27
#define SOLENOID4 26
#define SOLENOID5 25
#define SOLENOID6 24
#define SOLENOID7 23
#define SOLENOID8 22

#define ADC_PIN   49
#define DAC1_PIN  53
#define DAC2_PIN  48

#define DIGITAL1 62
#define DIGITAL2 63
#define DIGITAL3 64
#define DIGITAL4  65
#define DIGITAL5  66
#define DIGITAL6  67 //Digital6 does not seem to work
#define DIGITAL7  68 //Digital7 does not seem to work


#define DummyPumpTrig  62 //DIGITAL1 was LaserTrig in Mirko's script
#define FVTrig  63
#define LaserTrig2  64
#define CherryPumpTrig  65
#define LEDtrig 66
#define TrialTrig  68
#define GrapePumpTrig  64



#define LickPin 67


int lickSol = SOLENOID1;
int Preloading = 900; //720 in fMRI
int state = 0;
int Sensor, Sensor1, Sensor2;

//uint16_t lick_threshold;
//int LickCount = 0;
//int reward = 5;               //Report=4: Miss 1: Hit 2: False Alarm 3:Correct Rejection 5:default
//int DropSize, DropNumber;

// some standard parameters that are not included anymore in superflex2000.mat
uint16_t odor_lat_On= 90; // Mirko's setup was 70; 480 measured for MRI setup with 3 m odortube
uint16_t odor_lat_Off= 90;//Mirko's setup was 70; MRI 440
uint16_t drop_lat = 520; // Mirko's setup was 240
uint16_t  TrialPrep = 1200;
uint16_t  IOI = 1200;
uint16_t  state_dur = 1200;
uint16_t jitter, laser_lat, ITI;
uint16_t xx, xy;
int laser_pattern, laser_active;


//int  laser_pattern = 0; //default
//uint16_t  laser_lat = 499;

//parameters that get sent by superflex2000.mat
int odorcue_odor_dur, rewardcue_odor_dur, odor_num, odor_lat, odor_dur;
int odorcue_odor_num, rewardcue_odor_num;
int reward_active;
int drop_or_not;
int reward_delay; 
int reward_size;
int reward_size2 = 333; //333 default; 100 for Ephys
int lick_window;
int trial_type;
//int lick_delay, discovery_help;

//the four variables for StageOne
int PhaseOneDuration = 50;
uint16_t randNumber;               
unsigned long StageOneInterval;
int Counter = 0;

unsigned long startTime = 0;
unsigned long currentTime, TrialStartTime, TimerStart, DropOnTime, DropOnTimefake, odorcue_OdorOnTime, perc_odorcue_OdorOnTime, rewardcue_OdorOnTime, perc_rewardcue_OdorOnTime, odorcue_OdorOffTime, perc_odorcue_OdorOffTime, OdorOnTime, OdorOffTime; 
unsigned long rewardcue_OdorOffTime, perc_rewardcue_OdorOffTime, FirstLickTime, MomentaryTime, TrialEndTime, perc_DropOnTimefake, perc_DropOnTime;

boolean odorON = false; //boolsche Operatoren können zwei Zustände annehmen, zero=false, non-zero=true
boolean dropON = false; //Variablen werden hier deklariert und mit false inialisiert
boolean lickON = false;
boolean DropDelivered = false;
boolean odorcue_OdorDelivered = false;
boolean rewardcue_OdorDelivered = false;
//boolean laserON = false;
boolean dropONfake = false;
boolean DropDeliveredfake = false;


// actions are performed in the functions "setup" "help" "loop"
// but  no information is reported to the larger program

void help() {
  Serial.println(" BCS verification firmware "); // Prints data to the serial port as human-readable ASCII text 
  Serial.println(" Commands:");
  Serial.println("  valve ADDR N <on,  off>: read/set the valve state for valve N on controller ADDR ");
  Serial.println("  vial ADDR N <on,  off>: read/set the vial state for vial N on controller ADDR");
  Serial.println("  vialOn ADDR N: turn On vial N exclusively, turn Off dummy valves on controller ADDR");
  Serial.println("  vialOff ADDR: turn Off all vials, turn On dummy valves on controller ADDR");
  Serial.println("  aMFC ADDR N <value>: read or set the analog value for MFC N on controller ADDR, value in range 0 - 1");
  Serial.println("  sMFC ADDR N <value>: set the value for MFC N on controller ADDR, value in range 0 - 100, serial comm");
  Serial.println("  solenoid <N> {on,off}, N = {1..8}");
  Serial.println("  beam <N>, N = {1..8}");
  Serial.println("  cue <N> {on,off}, N = {1..8}");
  Serial.println("  digital <N> {high,low,input,output}, N = {1..8}");
  Serial.println("  aout <N> <VALUE>, N = {1..8}, -32768<VALUE<32767 for N = 1 - 4, 0 <VALUE<65535 for N = 5 - 8");
  Serial.println(" trialParams 3000 0 5 6 3 ");
} // a fuction that can be called and gives advices/help

void CheckSetFV1() {
//close FV after odor_dur
currentTime = millis();
  
  if (odorON) {
    if (currentTime - odorcue_OdorOnTime > odorcue_odor_dur) {

      SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)OFF); //from ValveControllerComm.io SetValve(uint8_t device, uint8_t valve, uint8_t state)
      VialOff ((uint8_t)1, (uint8_t)odorcue_odor_num);
      SetVial((uint8_t)1, (uint8_t)odorcue_odor_num, (uint8_t)OFF);//odor number is vialnumber
      SetValve((uint8_t)1, (uint8_t)7, (uint8_t)OFF); //7=vial on
      digitalWrite(FVTrig, LOW);
      odorON = false;
      odorcue_OdorDelivered = true;
      odorcue_OdorOffTime = currentTime;

    }
  }
}

void CheckSetFV2() {
//close FV after odor_dur
  if (odorON) {
    if (currentTime - rewardcue_OdorOnTime > rewardcue_odor_dur) {

      SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)OFF); //from ValveContorllerComm.ino SetValve(uint8_t device, uint8_t valve, uint8_t state)
      VialOff ((uint8_t)1, (uint8_t)rewardcue_odor_num);
      SetVial((uint8_t)1, (uint8_t)rewardcue_odor_num, (uint8_t)OFF);//odor number is vialnumber
      SetValve((uint8_t)1, (uint8_t)7, (uint8_t)OFF); //7=vial on
      digitalWrite(FVTrig, LOW);
      odorON = false;
      rewardcue_OdorDelivered = true;
      rewardcue_OdorOffTime = currentTime;

    }
  }
}
//void CloseFaucet() {
//
//  if (dropON && DropDelivered == false) {
//    currentTime = millis();
//    if ((currentTime - DropOnTime) > reward_size||(currentTime - DropOnTimefake > reward_size2)) {
//
//      SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF); //???
//
//      digitalWrite(lickSol, LOW); //???
//      digitalWrite(65, LOW);
//      DropDelivered = true;           
//    }
//  }
//}

void CherryPumpOn() {
  // activate digital pump trigger for the cherry water
  if (drop_or_not == 1 && ((trial_type == 1)||(trial_type == 5)) ) {
    DropOnTime = millis();
    Serial.println (DropOnTime);
          digitalWrite(CherryPumpTrig, HIGH);
          delay(reward_size2);
          digitalWrite(CherryPumpTrig, LOW);
    //DropOffTime = millis;
    //Serial.println("OpenFaucet");
    //digitalWrite(lickSol, HIGH);
   // SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);
   // digitalWrite(65, HIGH);

  //  dropON = true;
    //DropOnTime = millis();
  } 
  }

void GrapePumpOn() {
  // activate digital pump trigger for the grape water
  if (drop_or_not == 1 && ((trial_type == 3)||(trial_type == 7)) ) {
    DropOnTime = millis();
    Serial.println (DropOnTime);
          digitalWrite(GrapePumpTrig, HIGH);
          delay(reward_size2);
          digitalWrite(GrapePumpTrig, LOW);
  } 
  }
  
void setup() {
  pinMode(ADC_PIN, OUTPUT);
  pinMode(DAC1_PIN, OUTPUT);
  pinMode(DAC2_PIN, OUTPUT);


  pinMode(SOLENOID1, OUTPUT);
  pinMode(SOLENOID2, OUTPUT);
  pinMode(SOLENOID3, OUTPUT);
  pinMode(SOLENOID4, OUTPUT);
  pinMode(SOLENOID5, OUTPUT);
  pinMode(SOLENOID6, OUTPUT);
  pinMode(SOLENOID7, OUTPUT);
  pinMode(SOLENOID8, OUTPUT);
  pinMode(LickPin, INPUT);
  pinMode(CherryPumpTrig, OUTPUT);
  pinMode(FVTrig, OUTPUT);
  pinMode(DummyPumpTrig, OUTPUT);
  pinMode(LaserTrig2, OUTPUT);
  pinMode(LEDtrig, OUTPUT);
  pinMode(TrialTrig, OUTPUT);
  pinMode(GrapePumpTrig, OUTPUT);
  
 
  digitalWrite(FVTrig, LOW);
  digitalWrite(CherryPumpTrig, LOW);
  digitalWrite(DummyPumpTrig, LOW);
  digitalWrite(LaserTrig2, LOW);
  digitalWrite(LEDtrig, LOW);
  digitalWrite(TrialTrig, LOW);
  digitalWrite(GrapePumpTrig, LOW);
 
  pinMode(0, OUTPUT);
  digitalWrite(0, LOW);
  digitalWrite(ADC_PIN, LOW);
  digitalWrite(SOLENOID1, LOW);
  digitalWrite(SOLENOID2, LOW);
  digitalWrite(SOLENOID3, LOW);
  digitalWrite(SOLENOID4, LOW);
  digitalWrite(SOLENOID5, LOW);
  digitalWrite(SOLENOID6, LOW);
  digitalWrite(SOLENOID7, LOW);
  digitalWrite(SOLENOID8, LOW);
  Wire.begin();

  // initialize SPI


  // PC communication
  Serial.begin(115200);
  Serial.println(">System is ready");

  // LCD communication
  Serial1.begin(19200);
  Serial1.write(0x0c); // clear the display
  delay(10);
  Serial1.write(0x11); // Back-light on

}

void loop() 
 //================ State for paradigm===========================================================
{
  switch (state) {

    case 0:
      
      uint8_t c;
      if (Serial.available() > 0) { // PC communication
        c = Serial.read();
        if (c == '\r') { //test if enter-key was pressed, \r\n used by Windows, \n used by Linux and Unix ->was \n before
          buffer[idx] = 0; // so to say buffer grows with its input ???
          parse((char*)buffer, argv, sizeof(argv));//arguments werden in char-array gespeichert

          
          if (strcmp(argv[0], "trialParams") == 0) {
       // == 0 means strings are equal

            odorcue_odor_dur = 1240;
            rewardcue_odor_dur = 1240;
            odorcue_odor_num   = (int)atoi(argv[1]); //atoi: string/ascii zu Int;
            rewardcue_odor_num   = (int)atoi(argv[2]);
            drop_or_not = (int)atoi(argv[3]);
            reward_active = drop_or_not;
            reward_delay = (int)atoi(argv[4]);
            reward_size = (int)atoi(argv[5]);
            trial_type = (int)atoi(argv[6]); //trialtype 1&5 (C->R) leads to cherry-flavored R, trialtype 3&7 (D->R) leads to grape-flavored R
            //odorcue_odor_dur = (int)atoi(argv[6]);
            //rewardcue_odor_dur = (int)atoi(argv[7]);
            lick_window = 7500;

            odorON = false;
            dropON = false;
            lickON = false;
            DropDelivered = false;
            odorcue_OdorDelivered = false;
            rewardcue_OdorDelivered = false;

            startTime = millis();
            Serial.println(startTime);
            Serial.println ("startTime");
            state = 1;
          }
          
        //optogenetic tagging and LED
          if (strcmp(argv[0], "trialParams2") == 0) {
            
            laser_pattern   = (int)atoi(argv[1]); //atoi: string/ascii zu Int;
            laser_lat   = (int)atoi(argv[2]);
            odor_num = (int)atoi(argv[3]);
            odor_lat = (int)atoi(argv[4]);
            odor_dur = (int)atoi(argv[5]);
            
            state = 100;
          }
        //experiment for Lennart: odors paired with laser-stim
          if (strcmp(argv[0], "trialParams3") == 0) {
            
            laser_active   = (int)atoi(argv[1]); //atoi: string/ascii zu Int;
            ITI = (int)atoi(argv[2]);//laser_lat   = (int)atoi(argv[2]);
            odor_num = (int)atoi(argv[3]);
            odor_lat = (int)atoi(argv[4]);
            odor_dur = (int)atoi(argv[5]);
            odorON = false;
            
            startTime = millis();
            Serial.println(startTime);
            Serial.println ("startTime");
            
            state = 300;
          }          
      //in the following several cases for simple control via serial Monitor are defined

      
       // tt= Trialtest
       // tt1/2 testing valves for vial 5, 10, 7, 8
                   if (strcmp(argv[0], "tt1") == 0) {
       // == 0 means strings are equal

            odorcue_odor_dur = 1240;
            rewardcue_odor_dur =1240;
            odorcue_odor_num   = 5; //atoi: string/ascii zu Int;
            rewardcue_odor_num   = 10;
            IOI = 1200;
            drop_or_not = 0;
            reward_active = drop_or_not;
            reward_delay = 1200;
            reward_size = 333;
            lick_window = 7500;

            odorON = false;
            dropON = false;
            lickON = false;
            DropDelivered = false;
            odorcue_OdorDelivered = false;
            rewardcue_OdorDelivered = false;


            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 1; }
            
 if (strcmp(argv[0], "tt2") == 0) {
       // == 0 means strings are equal

            odorcue_odor_dur = 1200;
            rewardcue_odor_dur =1200;
            odorcue_odor_num   = 7; //atoi: string/ascii zu Int;
            rewardcue_odor_num   = 8;
            IOI = 1200;
            drop_or_not = 0;
            reward_active = drop_or_not;
            reward_delay = 1200;
            reward_size = 333;
            lick_window = 7500;

            odorON = false;
            dropON = false;
            lickON = false;
            DropDelivered = false;
            odorcue_OdorDelivered = false;
            rewardcue_OdorDelivered = false;


            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 1; }
            
           //lasertest    laser 1 
           if (strcmp(argv[0], "tt3") == 0) {
   
           laser_pattern = 2; //
           laser_lat = 0;
           delay (1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
           state = 100;}
           
           //lasertest    laser 2+3 
           if (strcmp(argv[0], "tt4") == 0) {
   
           laser_pattern = 6; //
           laser_lat = 0;
           delay (1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
           state = 100;}    
    
       // all lasers on for 1min
           if (strcmp(argv[0], "tt5") == 0) {
   
           laser_pattern = 100;
           laser_lat = 0;
           delay (1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
           state = 100;}
           
    // test LED  
           if (strcmp(argv[0], "led") == 0) {
           digitalWrite(LEDtrig,HIGH);
           delay(1000);
           digitalWrite(LEDtrig,LOW);
           state = 0;}    
           
     // test Laser 1: 10x1s pulses + 2min on  
           if (strcmp(argv[0], "tt6") == 0) {
   
           laser_pattern = 101;
           laser_lat = 0;
           delay (1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
           state = 100;}    
          
    // test Laser 2: 10x1s pulses + 2min on  
           if (strcmp(argv[0], "tt7") == 0) {
   
           laser_pattern = 102;
           laser_lat = 0;
           delay (1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
           state = 100;}    

    //test vial 9 with laser
       if (strcmp(argv[0], "tt9") == 0) {
       // == 0 means strings are equal

            laser_active = 1;
            laser_lat = 0;
            odor_num  = 9; 
            odor_lat = 70; 
            odor_dur = 500;
            
            odorON = false;
            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 300; }

    //test vial 10 
       if (strcmp(argv[0], "tt10") == 0) {
       // == 0 means strings are equal

            laser_pattern = 0;
            laser_active = 0;
            odor_num  = 10; 
            odor_lat = 70; 
            odor_dur = 500;
            
            odorON = false;
            
            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 300; }

    //test vial 11 
       if (strcmp(argv[0], "tt11") == 0) {
       // == 0 means strings are equal

            laser_active = 0;
            laser_lat = 0;
            odor_num  = 11; 
            odor_lat = 70; 
            odor_dur = 500;
            
            odorON = false;
            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 300; }

    //test vial 12 
       if (strcmp(argv[0], "tt12") == 0) {
       // == 0 means strings are equal

            laser_active = 0;
            laser_lat = 0;
            odor_num  = 12; 
            odor_lat = 70; 
            odor_dur = 500;
            
            odorON = false;
            delay(1);
            startTime = millis();
            Serial.println("startTime");
            Serial.println (startTime);
            state = 300; }
    

             
          else if (strcmp(argv[0], "valve") == 0) {
            ValveOnOff(c);
          }
          else if (strcmp(argv[0], "vial") == 0) {
            VialOnOff(c);
          }
          else if (strcmp(argv[0], "aMFC") == 0) {
            FlowChangeAnalog(c);
          }
          else if (strcmp(argv[0], "sMFC") == 0) {
            FlowChangeSerial(c);
          }
          else if (strcmp(argv[0], "digitalSet") == 0) {
            SetDigitalChannel(c);
          }
          else if (strcmp(argv[0], "digital") == 0) {
            ActivateDigitalChan(c);
          }
          else if (strcmp(argv[0], "digitalMode") == 0) {
            SetDigitalMode(c);
          }
          else if (strcmp(argv[0], "analogSet") == 0) {
            SetAnalogChannel(c);
          }
          else if (strcmp(argv[0], "analogRead") == 0) {
            ReadAnalogChannel(c);
          }
          else if (strcmp(argv[0], "digitalRead") == 0) {
            ReadDigitalChannel(c);
          }

             
          if (strcmp(argv[0],"fakedrop") == 0) {
            digitalWrite(DummyPumpTrig, HIGH);
            delay(reward_size2);
            digitalWrite(DummyPumpTrig, LOW);
          }
          
          else  if (strcmp(argv[0], "cherrydrop") == 0)  {
            //digitalWrite(lickSol, HIGH);              // initial drop for more motivation
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);            
            digitalWrite(CherryPumpTrig, HIGH);
            delay(reward_size2);
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF);
            //digitalWrite(lickSol, LOW);
            digitalWrite(CherryPumpTrig, LOW);
          }

          else if (strcmp(argv[0],"grapedrop") == 0) {
            digitalWrite(GrapePumpTrig, HIGH);
            delay(reward_size2);
            digitalWrite(GrapePumpTrig, LOW);
          }
          
          else  if (strcmp(argv[0], "fill") == 0)  {
            digitalWrite(lickSol, HIGH);              // initial drop for more motivation
            SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);            
            digitalWrite(DIGITAL4, HIGH);
            delay(10000);
            SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF);
            digitalWrite(lickSol, LOW);
            digitalWrite(DIGITAL4, LOW);
          }
            

          else  if (strcmp(argv[0], "so") == 0)  {    // StageOne Training
            digitalWrite(lickSol, HIGH);              // initial drop for more motivation
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);            
            digitalWrite(DIGITAL4, HIGH);
            delay(reward_size2);
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF);
            digitalWrite(lickSol, LOW);
            digitalWrite(DIGITAL4, LOW);
            PhaseOneDuration = 50;
            xx = 7000;
            xy = 7002;
            state = 200;
          }
          
          else  if (strcmp(argv[0], "sso") == 0)  {    // shortStageOne Training
            digitalWrite(lickSol, HIGH);              // initial drop for more motivation
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);            
            digitalWrite(DIGITAL4, HIGH);
            delay(reward_size2);
            //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF);
            digitalWrite(lickSol, LOW);
            digitalWrite(DIGITAL4, LOW);
            PhaseOneDuration= 10;
            xx = 15000;
            xy = 45000;
            state = 200;
          }




          else if ((strcmp(argv[0], "help") == 0) || (strcmp(argv[0], "?") == 0)) {
            help();
          }
          idx = 0; // what does idx count ???
          
        }
       //update buffer size
        else if ((c >= ' ') && (idx < sizeof(buffer) - 1)) {
          buffer[idx++] = c;
          
        }
      }
      break;
    
     
    case 1: //activation of odor valve of odor cue for preloading
    
      currentTime = millis();
      if  (currentTime - startTime > TrialPrep - Preloading - odor_lat_On) {
         if (odorcue_odor_num > 0) {
          VialOn ((uint8_t)1, (uint8_t)odorcue_odor_num);
          SetValve((uint8_t)1, (uint8_t)7, (uint8_t)ON);
         }
         Serial.println("Preloading");
         Serial.println(currentTime); 
        state = 2;
      }
      break;

// open FV 
    case 2:
      currentTime = millis();
      if  (!odorON &&(currentTime - startTime > TrialPrep - odor_lat_On)) {        
        odorcue_OdorOnTime = millis();
        TrialStartTime = odorcue_OdorOnTime;
        SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)ON);
        odorON = true;
        digitalWrite(TrialTrig, HIGH);
        Serial.println ("Trialstart");
        digitalWrite(FVTrig, HIGH);
        Serial.println ("odorcueOn");
        Serial.println(TrialStartTime);
        state = 3;
      }
      break;


    case 3: // perceived odorcue_OdorOnTime
        currentTime = millis();
        if  (odorON &&(currentTime - odorcue_OdorOnTime > odor_lat_On)) {        
          perc_odorcue_OdorOnTime = millis();
          Serial.println ("perc_odorcueOn");
          Serial.println(perc_odorcue_OdorOnTime);
          state = 4;
      }
      break;
      

    case 4: //closing FV
      currentTime = millis();
      CheckSetFV1();
      if (odorcue_OdorDelivered = true &&(currentTime - odorcue_OdorOnTime > odorcue_odor_dur)) {
         state = 5;
         Serial.println("odorcue_OdorOff"); 
         Serial.println(odorcue_OdorOffTime); 
      }
      break;

    case 5: // perceived odorcue_OdorOffTime
        currentTime = millis();
        if  (!odorON &&(currentTime - odorcue_OdorOffTime > odor_lat_Off)) {        
          perc_odorcue_OdorOffTime = millis();
          Serial.println("perc_odorcue_OdorOff"); 
          Serial.println(perc_odorcue_OdorOffTime);
          jitter= random(0,1001);
          Serial.println("jitter");
          Serial.println(jitter);
          state = 6;
      }
      break;      

    case 6: //open vial for rewardcue odor preloading
      currentTime = millis();
      if  (currentTime - perc_odorcue_OdorOffTime > IOI + jitter - Preloading - odor_lat_On) {
          if (odorcue_odor_num > 0){
          VialOn ((uint8_t)1, (uint8_t)rewardcue_odor_num);
          SetValve((uint8_t)1, (uint8_t)7, (uint8_t)ON);        
          } 
          Serial.println ("Preloading");
          Serial.println (currentTime);
          state = 7;
      }
      break;

// open FV for rewardcue odor
    case 7:
      currentTime = millis();
      if  (!odorON &&(currentTime - perc_odorcue_OdorOffTime > IOI + jitter - odor_lat_On)) {
 
        SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)ON);
        odorON = true;
        digitalWrite(FVTrig, HIGH);
        rewardcue_OdorOnTime = millis();
        Serial.println("rewardcueOn");
        Serial.println(rewardcue_OdorOnTime);       

        state = 8;
      }
      break;

    case 8: // perceived rewardcue_OdorOnTime
        currentTime = millis();
        if  (odorON &&(currentTime - rewardcue_OdorOnTime > odor_lat_On)) {        
          perc_rewardcue_OdorOnTime = millis();
          Serial.println("perc_rewardcue_OdorOn");
          Serial.println(perc_rewardcue_OdorOnTime);
          state = 9;
      }
      break;
       

     case 9: // close FV for rewardcue
      currentTime = millis();
      CheckSetFV2();

      if (rewardcue_OdorDelivered = true &&(currentTime - rewardcue_OdorOnTime > rewardcue_odor_dur)) 
      { 
      Serial.println("rewardcue_OdorOff");
      Serial.println(rewardcue_OdorOffTime);
      state = 10;
      }
      break;


    case 10: // perceived rewardcue_OdorOffTime
        currentTime = millis();
        if  (!odorON &&(currentTime - rewardcue_OdorOffTime > odor_lat_Off)) {        
          perc_rewardcue_OdorOffTime = millis();
          Serial.println("perc_rewardcue_OdorOff");
          Serial.println(perc_rewardcue_OdorOffTime);
          state = 11;
      }
      break;      
     
     case 11: //Drop or not
      currentTime = millis();
      //CloseFaucet();


      // if there is no reward
     if (drop_or_not == 0 && (currentTime - perc_rewardcue_OdorOffTime > reward_delay - drop_lat))  
     {
       
        DropOnTimefake = millis();
        Serial.println ("Dropfake");
        Serial.println (DropOnTimefake);
        digitalWrite(DummyPumpTrig, HIGH);
        delay(reward_size2);
        digitalWrite(DummyPumpTrig, LOW);
     state = 12; 
     }

        // turn on either the pump for cherry-water or grape-water
        if (drop_or_not == 1 &&  (currentTime - perc_rewardcue_OdorOffTime > reward_delay - drop_lat)) {
         if (trial_type == 1 || trial_type == 5) {
         // C -> cherry-flavored reward
          CherryPumpOn();
         }
         else if(trial_type == 3 || trial_type == 7) {
         // D -> grape-flavored reward
          GrapePumpOn();
         }       
        Serial.println ("Drop");
                     
      state = 12;
      }
      break;

//      if (drop_or_not == 1 && (currentTime - perc_rewardcue_OdorOffTime > reward_delay - drop_lat)) {       
//        Serial.println ("Drop");
//        OpenFaucet();                
//      state = 12;
//      }
//      break;

     case 12: //perc_drop
      currentTime = millis();
     if (drop_or_not == 0 && (currentTime - DropOnTimefake > drop_lat))  
     {
        perc_DropOnTimefake = millis();
        Serial.println ("perc_Dropfake");
        Serial.println (perc_DropOnTimefake);
     state = 13; 

     }

     if (drop_or_not == 1 && (currentTime - DropOnTime > drop_lat)) {       
        perc_DropOnTime = millis();
        Serial.println ("Perc_Drop");
        Serial.println (perc_DropOnTime);                      
      state = 13;
      }
      break;

case 13: //closefaucet
      currentTime = millis();
      //CloseFaucet();
      if(DropOnTime > 0 && (currentTime - DropOnTime > reward_size)){
      Serial.println (currentTime);
      Serial.println("DropDelivered");
      state = 14;
      }
      if (DropOnTimefake > 0 && (currentTime - DropOnTimefake > reward_size)){
      Serial.println (currentTime);
      Serial.println("DropDeliveredFake");
      state = 14;     
      }
      break;      

case 14:

        currentTime = millis();
        if ((drop_or_not == 1 &&(currentTime - perc_DropOnTime > state_dur))||(drop_or_not == 0 &&(currentTime - perc_DropOnTimefake > state_dur))){
        TrialEndTime = millis();
        Serial.println ("End of trial");
        Serial.println (TrialEndTime);
        Serial.println();
        digitalWrite(TrialTrig, LOW);
        state = 0;}
      break;
      
//Laser and LED trigger

case 100:
        digitalWrite(TrialTrig, HIGH);
        currentTime = millis();
          if (currentTime - startTime >= laser_lat) {
            
      ////Laser 1////
      
              if (laser_pattern == 2) {        //MSN tagging: 1s, 40Hz, 5 ms pulse 
          for (int xi=0; xi < 40; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delay(20);
          }
        }
        
        if (laser_pattern == 3) {        //MSN tagging 1s, 40Hz, 12,5 ms pulse 
          for (int xi=0; xi < 40; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(12500);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(12500);
          }
        }

        if (laser_pattern == 4) {        //MSN tagging 6 pulse, 40 Hz, 5ms 
          for (int xi=0; xi < 6; xi++){
          digitalWrite(LaserTrig, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig, LOW);
          delay(20);
          }
        }

        if (laser_pattern == 5) {        //MSN tagging 6 pulse, 10 Hz, 5ms 
          for (int xi=0; xi < 6; xi++){
          digitalWrite(LaserTrig, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);          
          delay(90);
          }
        }
        if (laser_pattern == 9) {        //MSN tagging 10 pulse, 40 Hz, 5ms 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig, LOW);       
          delay(20);
          }
        } 
        if (laser_pattern == 11) {        //MSN tagging 10 pulse, 10 Hz, 5ms 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);          
          delay(90);
          }
        }               
        
          ////Laser 2////

        if (laser_pattern == 6) {        //MSN tagging: 1s, 40Hz, 5 ms pulse 
          for (int xi=0; xi < 40; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delay(20);
          }
        }


//        old case 405, used until 27thFeb2020 
//        if (laser_pattern == 6) {        //MSN tagging 1s, 40Hz, 12,5 ms pulse 
//          for (int xi=0; xi < 40; xi++){
//          digitalWrite(LaserTrig2, HIGH);
//          //digitalWrite(LEDtrig, HIGH);
//          delayMicroseconds(12500);
//          //digitalWrite(LEDtrig, LOW);
//          digitalWrite(LaserTrig2, LOW);
//          delayMicroseconds(12500);
//          }
//        }
//        
        
        
        

        if (laser_pattern == 7) {        //MSN tagging 6 pulse, 40 Hz, 5ms 
          for (int xi=0; xi < 6; xi++){
          digitalWrite(LaserTrig2, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig2, LOW);
          delay(20);
          }
        }

        if (laser_pattern == 8) {        //MSN tagging 6 pulse, 10 Hz, 5ms 
          for (int xi=0; xi < 6; xi++){
          digitalWrite(LaserTrig2, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);          
          delay(90);
          }
        }        
        if (laser_pattern == 10) {        //MSN tagging 10 pulse, 40 Hz, 5ms 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig2, LOW);       
          delay(20);
          }
        } 
        if (laser_pattern == 12) {        //MSN tagging 10 pulse, 10 Hz, 5ms 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);          
          delay(90);
          }
        }               

        if (laser_pattern == 13) {        //MSN tagging 10 pulses, 2Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);
          delay(490);
          }
        }

        if (laser_pattern == 14) {        //MSN tagging 10 pulses, 4Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);
          delay(240);
          }
        }

        if (laser_pattern == 15) {        //MSN tagging 10 pulses, 8Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delay(120);
          }
        }
        
        if (laser_pattern == 16) {        //MSN tagging 10 pulses, 16Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(7500);
          delay(50);
          }
        }

        if (laser_pattern == 17) {        //MSN tagging 10 pulses, 32Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(6250);
          delay(20);
          }
        }
        
        if (laser_pattern == 18) {        //MSN tagging 1s, 2Hz, 5 ms pulse 
          for (int xi=0; xi < 2; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);
          delay(490);
          }
        }
 
        if (laser_pattern == 19) {        //MSN tagging 1s, 4Hz, 5 ms pulse 
          for (int xi=0; xi < 4; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(5000);
          delay(240);
          }
        }

        if (laser_pattern == 20) {        //MSN tagging 1s, 8Hz, 5 ms pulse 
          for (int xi=0; xi < 8; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delay(120);
          }
        }

        if (laser_pattern == 21) {        //MSN tagging 1s, 16Hz, 5 ms pulse 
          for (int xi=0; xi < 16; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(7500);
          delay(50);
          }
        }

        if (laser_pattern == 22) {        //MSN tagging 1s, 32Hz, 5 ms pulse 
          for (int xi=0; xi < 32; xi++){
          digitalWrite(LaserTrig2, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig2, LOW);
          delayMicroseconds(6250);
          delay(20);
          }
        }
        if (laser_pattern == 23) {        //DAT tagging 10 pulses, 2Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);
          delay(490);
          }
        }

        if (laser_pattern == 24) {        //DAT tagging 10 pulses, 4Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);
          delay(240);
          }
        }

        if (laser_pattern == 25) {        //DAT tagging 10 pulses, 8Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delay(120);
          }
        }
        
        if (laser_pattern == 26) {        //DAT tagging 10 pulses, 16Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(7500);
          delay(50);
          }
        }

        if (laser_pattern == 27) {        //DAT tagging 10 pulses, 32Hz, 5 ms pulse 
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(6250);
          delay(20);
          }
        }
        
        if (laser_pattern == 28) {        //DAT tagging 1s, 2Hz, 5 ms pulse 
          for (int xi=0; xi < 2; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);
          delay(490);
          }
        }
 
        if (laser_pattern == 29) {        //DAT tagging 1s, 4Hz, 5 ms pulse 
          for (int xi=0; xi < 4; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(5000);
          delay(240);
          }
        }

        if (laser_pattern == 30) {        //DAT tagging 1s, 8Hz, 5 ms pulse 
          for (int xi=0; xi < 8; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delay(120);
          }
        }

        if (laser_pattern == 31) {        //DAT tagging 1s, 16Hz, 5 ms pulse 
          for (int xi=0; xi < 16; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(7500);
          delay(50);
          }
        }

        if (laser_pattern == 32) {        //DAT tagging 1s, 32Hz, 5 ms pulse 
          for (int xi=0; xi < 32; xi++){
          digitalWrite(LaserTrig, HIGH);
          //digitalWrite(LEDtrig, HIGH);
          delayMicroseconds(5000);
          //digitalWrite(LEDtrig, LOW);
          digitalWrite(LaserTrig, LOW);
          delayMicroseconds(6250);
          delay(20);
          }
        }               
        if(laser_pattern == 99) {        //led stim for video-intan sync
          
          digitalWrite(LEDtrig, HIGH);
          delay(1000);
          digitalWrite(LEDtrig, LOW);}

        if(laser_pattern == 991) {        //turn on red light
          
          digitalWrite(LEDtrig, HIGH);}

        if(laser_pattern == 990) {        //turn off red light
                    
          digitalWrite(LEDtrig, LOW);}
 
     
       if(laser_pattern == 100) {        //all lasers on for 2min
          
          digitalWrite(LaserTrig, HIGH);
          digitalWrite(LaserTrig2, HIGH);
          delay(120000);
          digitalWrite(LaserTrig, LOW);
          digitalWrite(LaserTrig2, LOW);}
          
       if(laser_pattern == 101) {        //Lasertest 1
       
          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig, HIGH);
          delay(1000);
          digitalWrite(LaserTrig, LOW);
          delay(1000);    }
          
          digitalWrite(LaserTrig, HIGH);
          delay(120000);
          digitalWrite(LaserTrig, LOW);}

       if(laser_pattern == 102) {        //Lasertest 2

          for (int xi=0; xi < 10; xi++){
          digitalWrite(LaserTrig2, HIGH);
          delay(1000);
          digitalWrite(LaserTrig2, LOW);
          delay(1000);    }
          
          digitalWrite(LaserTrig2, HIGH);
          delay(120000);
          digitalWrite(LaserTrig2, LOW);}          
     
          state = 0;}
          break;

  case 200:                              //StageOne training
      currentTime = millis();
      
      state = 201;
      break;

    case 201:

      MomentaryTime = millis();
      delay(1);
      state = 202;
      break;

    case 202:
      randNumber= random(xx, xy);
      StageOneInterval = (currentTime) + (randNumber);
      if (MomentaryTime > StageOneInterval)
      {
        Serial.println((MomentaryTime - currentTime));
        state = 203;
      }
      else {
        state = 201;
      }
      break;

    case 203:
      Sensor = digitalRead(LickPin);
      delay(1);
      //if (Sensor > 0) 
      if (1) {
        digitalWrite(DIGITAL4, HIGH);
        //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)ON);
        delay(reward_size2);
        //SetValve((uint8_t)1, (uint8_t)4, (uint8_t)OFF);
        digitalWrite(DIGITAL4, LOW);
      }
        Counter++;
        Serial.println(Counter);
        if (Counter >PhaseOneDuration) {
        Serial.println("End of Training");
          Counter = 0;
          state = 0;}
      else {
          state = 200;
      }
      break;           
    
case 300:
     //open vial for odor preloading
      
          currentTime = millis();       
          if (currentTime - startTime > TrialPrep - Preloading - odor_lat_On){
          if (odor_num > 0) {
          VialOn ((uint8_t)1, (uint8_t)odor_num);
          SetValve((uint8_t)1, (uint8_t)7, (uint8_t)ON);}        
          
          Serial.println ("Preloading");
          Serial.println (currentTime);
          //delay(1000);
          state = 301;
          }
      break;

// open FV 
    case 301:
      currentTime = millis();
      if  (!odorON &&(currentTime - startTime > TrialPrep - odor_lat_On)) {
      if (odor_num > 0) {
        SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)ON);
        digitalWrite(FVTrig, HIGH);
      }
        odorON = true;
        OdorOnTime = millis();
        Serial.println("OdorOn");
        Serial.println(OdorOnTime);       

        state = 302;
      }
      break;

    case 302: // laser 
        currentTime = millis();
        if(currentTime - startTime > TrialPrep){
        Serial.println("Laser");         
         if (laser_active > 0) {      //odor with laser pulses in VTA       
        Serial.println("On");
          for (int xi=0; xi < 12; xi++){
          digitalWrite(LaserTrig, HIGH);
          delayMicroseconds(5000);
          digitalWrite(LaserTrig, LOW);
          delay(20);
          }
        }
        currentTime = millis();
        Serial.println("Off");
        Serial.println (currentTime);        
          state =303;
      }
      break;
       

     case 303: // close FV
      currentTime = millis();
      if  (odorON &&(currentTime - OdorOnTime> odor_dur)) {
      if (odor_num > 0) {  
      SetValve((uint8_t)1, (uint8_t)fv, (uint8_t)OFF);
      VialOff ((uint8_t)1, (uint8_t)odor_num);
      SetValve((uint8_t)1, (uint8_t)7, (uint8_t)OFF); 
      digitalWrite(FVTrig, LOW); }     
      odorON = false;
      Serial.println("OdorOff");
      Serial.println("EndofTrial");            
      Serial.println (currentTime);        
      state = 0;
      }
      break; 
  }
}
