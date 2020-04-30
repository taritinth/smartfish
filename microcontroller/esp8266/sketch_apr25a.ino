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

  //Turbidity INPUT
  pinMode(A0, INPUT);

  fetchData();

  time_t now = time(nullptr);
  startTime = now - timezone;
  Firebase.set("log/system_start", startTime);
}

//int pos1 = 0;
//void moveTo(int position, int speed) {
//  mapSpeed = map(speed, 0, 30, 30, 0);
//  if (position > pos) {
//    for (pos = pos1; pos <= position; pos += 1) {
//      myservo.write(pos);
//      pos1 = pos;
//      delay(mapSpeed);
//    }
//  } else {
//    for (pos = pos1; pos >= position; pos -= 1) {
//      myservo.write(pos);
//      pos1 = pos;
//      delay(mapSpeed);
//    }
//  }
//}

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
  //define timenow
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);
  unsigned long tnow = millis();

  //  For Debug
  //  char timenow[10];
  //  sprintf(timenow, "%02d:%02d:%02d", p_tm->tm_hour, p_tm->tm_min, p_tm->tm_sec);
  //  Serial.println(timenow);

  if (t1Status && p_tm->tm_hour == t1Hour && p_tm->tm_min == t1Minute && p_tm->tm_sec == 0) {
    while (!feeding) {
      myservo.write(90);
      delay(t1Duration);
      myservo.write(0);
      delay(t1Duration);
      feeding = true;
      if (feeding) {
        //Check if feeded, then give it delay to prevent loop run repeatly in small timerDuration.
        delay(1000);
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
  foodRemain = remainHeight <= 0 ? 0 : (remainHeight*100)/bottleHeight;
}

void loop()
{
  time_t now = time(nullptr);
  //Timer Function
  feedTimer();

  unsigned long tnow = millis();
  if (tnow - lastLoop > 5000) {
    lastLoop = tnow;

    fetchData();

    Serial.println(t1Status);
    Serial.println(t1Hour);
    Serial.println(t1Minute);
    Serial.println(t1Duration);

    //    FirebaseObject print
    //    JsonVariant variant = timerObject.getJsonVariant();
    //    variant.prettyPrintTo(Serial);

    //Trubidity
    int turbiSensor = analogRead(A0);
    turbidity = turbiSensor * (5.0 / 1024.0);
    Serial.println(turbidity);

    //Temp
    tempSensor.requestTemperatures();
    waterTemp = tempSensor.getTempCByIndex(0);
    Serial.println(waterTemp);

    //Servo
    Serial.println(feeding);

    checkFood();
    Serial.println(foodRemain);

    Serial.println(feeding);
    Serial.println(rgb);
    Serial.println(rgbMode);

    Serial.println("----------");

    //JSON Object create
    StaticJsonBuffer<200> jsonBuffer;
    JsonObject& realtime = jsonBuffer.createObject();
    realtime["turbidity"] = turbidity;
    realtime["water_temp"] = waterTemp;
    realtime["food_remain"] = foodRemain;
    realtime["feed_status"] = feeding;
    realtime["last_update"] = now - timezone;

    //Firebase set
    Firebase.set("realtime", realtime);
  }
}
