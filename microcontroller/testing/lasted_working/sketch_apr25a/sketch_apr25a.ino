//WiFi & Firebase
#include <ESP8266WiFi.h>
#include <FirebaseArduino.h>
#include <ArduinoJson.h>
#define WIFI_SSID "BualoiTech"
#define WIFI_PASSWORD "11223344551"
#define FIREBASE_HOST "smart-fish-tank-69105.firebaseio.com"
#define FIREBASE_AUTH "sETZH2EgeJkK18o1LJIvLpYiNSwmwcGWvwKo41YP"

//Ultrasonic without delay
#include <NewPing.h>
#define TRIGGER_PIN  2  // Arduino pin tied to trigger pin on the ultrasonic sensor.
#define ECHO_PIN     0  // Arduino pin tied to echo pin on the ultrasonic sensor.
#define MAX_DISTANCE 200 // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE); // NewPing setup of pins and maximum distance.

//Servo
#include <Servo.h>
//Temp
#include <OneWire.h>
#include <DallasTemperature.h>
#define ONE_WIRE_BUS D2
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature tempSensor(&oneWire);

//SoftwareSerial
#include <SoftwareSerial.h>
SoftwareSerial NodeMCU(12, 14); // RX | TX  , D6 = 12 D5 = 14

//Servo
Servo myservo;
//int mapSpeed, pos = 0;

//Delay Check
unsigned long lastLoop = 0;
unsigned long lastTimer = 0;

//Realtime Status
int distance = 0, bottleHeight = 13, remainHeight = 0, foodRemain = 0;
float turbidity, waterTemp;
bool feeding = false;
bool rgb = false;
String rgbMode = "";
String cmd = "";

//Timer setting
bool t1Status = false;
int t1Hour, t1Minute, t1Duration;

//NTP Timezone setting
int startTime;
int timezone = 7 * 3600;
int dst = 0;

void setup()
{
  Serial.begin(115200);
  NodeMCU.begin(115200);
  Serial.setDebugOutput(true);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("connecting");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("connected: ");
  Serial.println(WiFi.localIP());
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  configTime(timezone, dst, "pool.ntp.org", "time.nist.gov");
  Serial.println("\nLoading time");
  while (!time(nullptr)) {
    Serial.print("*");
    delay(1000);
  }
  Serial.println("");

  //Servo
  myservo.attach(5); //D1
  myservo.write(0); //auto set servo degree to 0 when start

  //Temp
  tempSensor.begin();

  //SoftwareSerial
  //  pinMode(D5, INPUT);
  //  pinMode(D6, OUTPUT);

  //Turbidity INPUT
  pinMode(A0, INPUT);

  fetchData();

  time_t now = time(nullptr);
  startTime = now - timezone;
  Firebase.set("log/system_start", startTime);
}

void fetchData() {
  //Fetch data from firebase
  FirebaseObject rgbObject = Firebase.get("/rgb");
  rgb = rgbObject.getBool("status");
  rgbMode = rgbObject.getString("mode");

  FirebaseObject timer1Object = Firebase.get("/timer/timer1");
  t1Status = timer1Object.getBool("status");
  t1Hour = timer1Object.getInt("hour");
  t1Minute = timer1Object.getInt("minute");
  t1Duration = timer1Object.getInt("duration");
}

void feedTimer() {
  //get timenow
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);

  //  For Debug
  //  char timenow[10];
  //  sprintf(timenow, "%02d:%02d:%02d", p_tm->tm_hour, p_tm->tm_min, p_tm->tm_sec);
  //  Serial.println(timenow);

  if (t1Status && p_tm->tm_hour == t1Hour && p_tm->tm_min == t1Minute && p_tm->tm_sec <= 1) {
    while (!feeding) {
      myservo.write(45);
      delay(t1Duration);
      myservo.write(0);
      delay(t1Duration);
      feeding = true;
      if (feeding) {
        //Check if feeded, then give it delay to prevent loop run repeatly in small timerDuration.
        delay(2000);
        break;
      }
    }
  }
  //When finish above function, then set feeding to false for recieve new command.
  feeding = false;
}

int checkFood() {
  /*Check remain food*/
  distance = sonar.ping_cm();
  remainHeight = bottleHeight - distance;
  foodRemain = remainHeight <= 0 ? 0 : (remainHeight * 100) / bottleHeight;
}

void feedListener() {
  if (cmd == "on_feed") {
    myservo.write(45);
  } else if (cmd == "off_feed") {
    myservo.write(0);
  }
}

byte stringToByte(char * src) {
  return byte(atoi(src));
}

void loop()
{
  //  if (Serial.available() > 0)
  //  {
  //    //    byte x = stringToByte("test");
  //    //    NodeMCU.write(x);
  //    byte x = Serial.read();
  //    NodeMCU.write(x);
  //  }
  //  if (NodeMCU.available() > 0)
  //  {
  //    Serial.write((char)NodeMCU.read());
  //  }

  //Get Command from Firebase
  cmd = Firebase.getString("/cmd/value");
  //
  //  //Get timestamp now
  time_t now = time(nullptr);
  //
  //Realtime feed
  feedListener();

  //Timer Function
  feedTimer();

  int rgbArduino = 8;
  if (rgb) {
    NodeMCU.write(rgbArduino);
  } else {
    NodeMCU.write(0);
  }

  unsigned long tnow = millis();

  // Do this every 5 seconds.
  if (tnow - lastLoop >= 5000) {
    lastLoop = tnow;

    fetchData();

    Serial.print("t1Status: ");
    Serial.print(t1Status);
    Serial.println();
    Serial.print("t1Hour: ");
    Serial.print(t1Hour);
    Serial.println();
    Serial.print("t1Minute: ");
    Serial.print(t1Minute);
    Serial.println();
    Serial.print("t1Duration: ");
    Serial.print(t1Duration);
    Serial.println();

    //    FirebaseObject print
    //    JsonVariant variant = timerObject.getJsonVariant();
    //    variant.prettyPrintTo(Serial);

    //Trubidity
    int turbiSensor = analogRead(A0);
    turbidity = turbiSensor * (5.0 / 1024.0);
    Serial.print("turbidity: ");
    Serial.print(turbidity);
    Serial.println();

    //Temp
    tempSensor.requestTemperatures();
    waterTemp = tempSensor.getTempCByIndex(0);
    Serial.print("waterTemp: ");
    Serial.print(waterTemp);
    Serial.println();

    //feeding
    Serial.print("feeding: ");
    Serial.print(feeding);
    Serial.println();

    //feed cmd
    Serial.print("cmd: ");
    Serial.print(cmd);
    Serial.println();

    //checkFood
    checkFood();
    Serial.print("foodRemain: ");
    Serial.print(foodRemain);
    Serial.println();

    //rgb
    Serial.print("rgb: ");
    Serial.print(rgb);
    Serial.println();
    Serial.print("rgbMode: ");
    Serial.print(rgbMode);
    Serial.println();

    Serial.println("----------");

    //JSON Object create
    StaticJsonBuffer<200> jsonBuffer;
    JsonObject& realtime = jsonBuffer.createObject();
    realtime["turbidity"] = turbidity;
    realtime["water_temp"] = waterTemp;
    realtime["food_remain"] = foodRemain;
    realtime["last_update"] = now - timezone;

    //Firebase set
    Firebase.set("realtime", realtime);
  }
}
