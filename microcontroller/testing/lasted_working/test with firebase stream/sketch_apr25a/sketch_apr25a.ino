//ESP8266 MultitaskScheduler
#include <Arduino.h>
#include <Scheduler.h>

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
SoftwareSerial NodeMCU(12, 14); // RX (D6 = 12) | TX (D5 = 14)

//Servo
Servo myservo;
//int mapSpeed, pos = 0;

//Delay Check
unsigned long lastLoop = 0;
unsigned long lastTimer = 0;

//RGB mode sent to arduino
int rgbArduino;

//Realtime Status
int distance = 0, bottleHeight = 13, remainHeight = 0, foodRemain = 0;
float turbidity, waterTemp;
bool feeding = false;
bool rgb = false;
String rgbMode = "";
String recieve, cmd = "";

//Timer setting
bool t1Status = false;
int t1Hour, t1Minute, t1Duration;

//NTP Timezone setting
int startTime;
int timezone = 7 * 3600;
int dst = 0;

class fetchData : public Task {
  protected:
    void setup() {
      Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
      //Fetch data from firebase
      FirebaseObject rgbObject = Firebase.get("/rgb");
      rgb = rgbObject.getBool("status");
      rgbMode = rgbObject.getString("mode");

      FirebaseObject timer1Object = Firebase.get("/timer/timer1");
      t1Status = timer1Object.getBool("status");
      t1Hour = timer1Object.getInt("hour");
      t1Minute = timer1Object.getInt("minute");
      t1Duration = timer1Object.getInt("duration");
      Firebase.stream("/");
    }
    void fetchDataFunc() {
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
    void RGB() {
      if (rgbMode == "Cycle") {
        rgbArduino = 5;
      } else if (rgbMode == "Wave") {
        rgbArduino = 8;
      } else if (rgbMode == "Solo") {
        rgbArduino = 1;
      }
      if (rgb) {
        byte x = (int)rgbArduino;
        NodeMCU.write(x);
      } else {
        byte x = (int)0;
        NodeMCU.write(x);
      }
    }
    void loop()  {
      //      fetchDataFunc();
      if (Firebase.available()) {
        FirebaseObject event = Firebase.readEvent();
        String eventType = event.getString("type");
        eventType.toLowerCase();

        if (eventType == "") return ;
        Serial.print("event: ");
        Serial.println(eventType);
        if (eventType == "put") {
          String path = event.getString("path");
          Serial.println("[" + path + "]");
          if (path == "/timer/timer1/status") {
            t1Status = event.getBool("data");
          } else if (path == "/timer/timer1/hour") {
            t1Hour = event.getInt("data");
          } else if (path == "/timer/timer1/minute") {
            t1Minute = event.getInt("data");
          } else if (path == "/timer/timer1/duration") {
            t1Duration = event.getInt("data");
          } else if (path == "/rgb/status") {
            rgb = event.getBool("data");
          } else if (path == "/rgb/mode") {
            rgbMode = event.getString("data");
          } else if (path == "/cmd/value") {
            cmd = event.getString("data");
          }
        }
      }
      //Realtime feed
      feedListener();
      //RGB
      RGB();
      delay(10);
    }
} fetch_task;

class updateData : public Task {
  protected:
    void setup() {
      //Temp
      tempSensor.begin();
      //Turbidity INPUT
      pinMode(A0, INPUT);
      Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
    }
    int checkFood() {
      /*Check remain food*/
      distance = sonar.ping_cm();
      remainHeight = bottleHeight - distance;
      foodRemain = remainHeight <= 0 ? 0 : (remainHeight * 100) / bottleHeight;
    }
    void loop()  {
      // Get timestamp now
      time_t now = time(nullptr);
      // Start loop timer.
      unsigned long tnow = millis();
      // Do this every 5 seconds.
      if (tnow - lastLoop >= 5000) {
        lastLoop = tnow;
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
        //        Serial.println();

        //JSON Object create
        StaticJsonBuffer<200> jsonBuffer;
        JsonObject& realtime = jsonBuffer.createObject();
        realtime["turbidity"] = turbidity;
        realtime["water_temp"] = waterTemp;
        realtime["food_remain"] = foodRemain;
        realtime["last_update"] = now - timezone;

        //Firebase set
        //        Firebase.set("realtime", realtime);
      }
    }
} update_task;

class DefaultTask : public Task {
  protected:
    void setup() {
      //Servo
      myservo.attach(5); //D1
      myservo.write(0); //auto set servo degree to 0 when start
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
    void loop()
    {
      //Get Command from Firebase
      //      recieve = Firebase.getString("/cmd/value");
      //      if (recieve != cmd) {
      //        cmd = recieve;
      //        //feed cmd
      //        Serial.print("cmd: ");
      //        Serial.print(cmd);
      //
      //        Serial.println();
      //        Serial.println("----------");
      //        //        Serial.println();
      //      }

      //Timer Function
      feedTimer();


    }
} default_task;

void setup()
{
  Serial.begin(115200);
  NodeMCU.begin(115200);
  NodeMCU.setTimeout(100);
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
  configTime(timezone, dst, "pool.ntp.org", "time.nist.gov");
  Serial.println("\nLoading time");
  while (!time(nullptr)) {
    Serial.print("*");
    delay(1000);
  }
  Serial.println("");

  Scheduler.start(&fetch_task);
  Scheduler.start(&update_task);
  Scheduler.start(&default_task);
  Scheduler.begin();

  time_t now = time(nullptr);
  startTime = now - timezone;
  //  Firebase.set("log/system_start", startTime);
}
void loop() {}
