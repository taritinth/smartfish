//FirebaseESP8266.h must be included before ESP8266WiFi.h
//WiFi & Firebase
#include "FirebaseESP8266.h"
#include <ESP8266WiFi.h>
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
//TX (D5 = 14)(NODEMCU) - RX 19(MEGA)
//RX (D6 = 12)(NODEMCU) - TX 18(MEGA) 
SoftwareSerial NodeMCU(12, 14);

//Servo
Servo myservo;
//int mapSpeed, pos = 0;

//Define FirebaseESP8266 data object
FirebaseData firebaseData1;
FirebaseData firebaseData2;

unsigned long sendDataPrevMillis = 0;

String path = "/";

//uint16_t count = 0;

//RGB mode sent to arduino
int rgbArduino;

//Realtime Status
int distance = 0, bottleHeight = 13, remainHeight = 0, foodRemain = 0;
double turbidity, waterTemp;
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

//Define function
void printResult(FirebaseData &data);
void printResult(StreamData &data);

void streamCallback(StreamData data)
{
  Serial.println("Stream Data1 available...");
  Serial.println("STREAM PATH: " + data.streamPath());
  Serial.println("EVENT PATH: " + data.dataPath());
  Serial.println("DATA TYPE: " + data.dataType());
  Serial.println("EVENT TYPE: " + data.eventType());
  Serial.print("VALUE: ");
  printResult(data);
  Serial.println();
  if (data.eventType() == "put" || data.eventType() == "patch") {
    Serial.println();
    FirebaseJson &json = data.jsonObject();
    //Print all object data
    size_t len = json.iteratorBegin();
    String key, value = "";
    int type = 0;
    for (size_t i = 0; i < len; i++)
    {
      json.iteratorGet(i, type, key, value);
      Serial.print(i);
      Serial.print(", ");
      Serial.print("Type: ");
      Serial.print(type == JSON_OBJECT ? "object" : "array");
      if (type == JSON_OBJECT)
      {
        Serial.print(", Key: ");
        Serial.print(key);
        // For recieve stream data from specific path when user setting.
        if (data.dataPath() == "/timer/timer1") {
          if (key == "timer1_status") {
            t1Status = value == "true" ? true : false;
            Serial.println(t1Status);
          } else if (key == "hour") {
            t1Hour = value.toInt();
            Serial.println(t1Hour);
          } else if (key == "minute") {
            t1Minute = value.toInt();
            Serial.println(t1Minute);
          } else if (key == "duration") {
            t1Duration = value.toInt();
            Serial.println(t1Duration);
          }
        } else if (data.dataPath() == "/rgb") {
          if (key == "rgb_status") {
            rgb = value == "true" ? true : false;
            Serial.println(rgb);
          } else if (key == "rgb_mode") {
            rgbMode = value;
            Serial.println(rgbMode);
          }
          // Set RGB when recieve new cmd.
          RGB();
        } else if (data.dataPath() == "/cmd") {
          if (key == "value") {
            cmd = value;
            Serial.println(cmd);
          }
          // Do feedListener when recieve new cmd.
          feedListener();
        } else if (data.dataPath() == "/") { // For recieve all stream data ( path ["/"] ) when NODEMCU start.
          if (key == "timer1_status") {
            t1Status = value == "true" ? true : false;
            Serial.println(t1Status);
          } else if (key == "hour") {
            t1Hour = value.toInt();
            Serial.println(t1Hour);
          } else if (key == "minute") {
            t1Minute = value.toInt();
            Serial.println(t1Minute);
          } else if (key == "duration") {
            t1Duration = value.toInt();
            Serial.println(t1Duration);
          } else if (key == "rgb_status") {
            rgb = value == "true" ? true : false;
            Serial.println(rgb);
          } else if (key == "rgb_mode") {
            rgbMode = value;
            Serial.println(rgbMode);
          } else if (key == "value") {
            cmd = value;
            Serial.println(cmd);
          }
          // Set last state of RGB when NODEMCU start.
          RGB();
          // Get last cmd when NODEMCU start.
          feedListener();
        }
      }
      Serial.print(", Value: ");
      Serial.println(value);
    }
    json.iteratorEnd();
  }
}

void streamTimeoutCallback(bool timeout)
{
  if (timeout)
  {
    Serial.println();
    Serial.println("Stream timeout, resume streaming...");
    Serial.println();
  }
}

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

  //Temp
  tempSensor.begin();

  //Turbidity INPUT
  pinMode(A0, INPUT);

  //Servo
  myservo.attach(5); //D1
  myservo.write(0); //auto set servo degree to 0 when start

  // Get timestamp now
  //  time_t now = time(nullptr);
  //  int timestampNow = now - timezone;

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  //Set the size of WiFi rx/tx buffers in the case where we want to work with large data.
  firebaseData1.setBSSLBufferSize(1024, 1024);

  //Set the size of HTTP response buffers in the case where we want to work with large data.
  firebaseData1.setResponseSize(1024);


  //Set the size of WiFi rx/tx buffers in the case where we want to work with large data.
  firebaseData2.setBSSLBufferSize(1024, 1024);

  //Set the size of HTTP response buffers in the case where we want to work with large data.
  firebaseData2.setResponseSize(1024);

  if (!Firebase.beginStream(firebaseData1, path))
  {
    Serial.println("------------------------------------");
    Serial.println("Can't begin stream connection...");
    Serial.println("REASON: " + firebaseData1.errorReason());
    Serial.println("------------------------------------");
    Serial.println();
  }

  Firebase.setStreamCallback(firebaseData1, streamCallback, streamTimeoutCallback);
}

int checkFood() {
  /*Check remain food*/
  distance = sonar.ping_cm();
  remainHeight = bottleHeight - distance;
  foodRemain = remainHeight <= 0 ? 0 : (remainHeight * 100) / bottleHeight;
}

void feedTimer() {
  //get timenow
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);

  //  For Debug
  //  char timenow[10];
  //  sprintf(timenow, "%02d:%02d:%02d", p_tm->tm_hour, p_tm->tm_min, p_tm->tm_sec);
  //  Serial.println(timenow);

  // Use p_tm->tm_sec <= 5 , becuase sometime NODEMCU is doing Firebase.set(every 15s) and then it may be missing the timer.
  if (t1Status && p_tm->tm_hour == t1Hour && p_tm->tm_min == t1Minute && p_tm->tm_sec <= 5) {
    while (!feeding) {
      myservo.write(45);
      delay(t1Duration);
      myservo.write(0);
      delay(t1Duration);
      feeding = true;
      if (feeding) {
        //Check if feeded, then give it delay to prevent loop run repeatly in small timerDuration.
        delay(5000);
        break;
      }
    }
  }
  //When finish above function, then set feeding to false for recieve new command.
  feeding = false;
}

void feedListener() {
  if (cmd == "on_feed") {
    myservo.write(45);
  } else if (cmd == "off_feed") {
    myservo.write(0);
  }
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
    byte x = (int)rgbArduino; // convert int to byte for sent via Serial.write
    NodeMCU.write(x);
  } else {
    byte x = (int)0; // convert int to byte for sent via Serial.write
    NodeMCU.write(x);
  }
}

void loop()
{
  //Timer Function
  feedTimer();

  // Get timestamp now
  time_t now = time(nullptr);

  if (millis() - sendDataPrevMillis > 15000)
  {
    sendDataPrevMillis = millis();

    //Trubidity
    int turbiSensor = analogRead(A0);
    turbidity = turbiSensor * (5.0 / 1024.0);

    //Temp
    tempSensor.requestTemperatures();
    waterTemp = tempSensor.getTempCByIndex(0);

    //checkFood
    checkFood();

    FirebaseJson json1;
    int timestampNow = now - timezone;
    json1.set("turbidity", turbidity);
    json1.set("water_temp", waterTemp);
    json1.set("food_remain", foodRemain);
    json1.set("last_update", timestampNow);

    Serial.println("------------------------------------");
    Serial.println("Set JSON...");

    if (Firebase.setJSON(firebaseData2, path + "realtime", json1))
    {
      Serial.println("PASSED");
      Serial.println("PATH: " + firebaseData2.dataPath());
      Serial.println("TYPE: " + firebaseData2.dataType());
      Serial.print("VALUE: ");
      printResult(firebaseData2);
      Serial.println("------------------------------------");
      Serial.println();
    }
    else
    {
      Serial.println("FAILED");
      Serial.println("REASON: " + firebaseData2.errorReason());
      Serial.println("------------------------------------");
      Serial.println();
    }
  }
}

void printResult(FirebaseData & data)
{

  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else if (data.dataType() == "double")
    printf("%.9lf\n", data.doubleData());
  else if (data.dataType() == "boolean")
    Serial.println(data.boolData() == 1 ? "true" : "false");
  else if (data.dataType() == "string")
    Serial.println(data.stringData());
  else if (data.dataType() == "json")
  {
    Serial.println();
    FirebaseJson &json = data.jsonObject();
    //Print all object data
    Serial.println("Pretty printed JSON data:");
    String jsonStr;
    json.toString(jsonStr, true);
    Serial.println(jsonStr);
    Serial.println();
    Serial.println("Iterate JSON data:");
    Serial.println();
    size_t len = json.iteratorBegin();
    String key, value = "";
    int type = 0;
    for (size_t i = 0; i < len; i++)
    {
      json.iteratorGet(i, type, key, value);
      Serial.print(i);
      Serial.print(", ");
      Serial.print("Type: ");
      Serial.print(type == JSON_OBJECT ? "object" : "array");
      if (type == JSON_OBJECT)
      {
        Serial.print(", Key: ");
        Serial.print(key);
      }
      Serial.print(", Value: ");
      Serial.println(value);
    }
    json.iteratorEnd();
  }
  else if (data.dataType() == "array")
  {
    Serial.println();
    //get array data from FirebaseData using FirebaseJsonArray object
    FirebaseJsonArray &arr = data.jsonArray();
    //Print all array values
    Serial.println("Pretty printed Array:");
    String arrStr;
    arr.toString(arrStr, true);
    Serial.println(arrStr);
    Serial.println();
    Serial.println("Iterate array values:");
    Serial.println();
    for (size_t i = 0; i < arr.size(); i++)
    {
      Serial.print(i);
      Serial.print(", Value: ");

      FirebaseJsonData &jsonData = data.jsonData();
      //Get the result data from FirebaseJsonArray object
      arr.get(jsonData, i);
      if (jsonData.typeNum == JSON_BOOL)
        Serial.println(jsonData.boolValue ? "true" : "false");
      else if (jsonData.typeNum == JSON_INT)
        Serial.println(jsonData.intValue);
      else if (jsonData.typeNum == JSON_DOUBLE)
        printf("%.9lf\n", jsonData.doubleValue);
      else if (jsonData.typeNum == JSON_STRING ||
               jsonData.typeNum == JSON_NULL ||
               jsonData.typeNum == JSON_OBJECT ||
               jsonData.typeNum == JSON_ARRAY)
        Serial.println(jsonData.stringValue);
    }
  }
}

void printResult(StreamData & data)
{

  if (data.dataType() == "int")
    Serial.println(data.intData());
  else if (data.dataType() == "float")
    Serial.println(data.floatData(), 5);
  else if (data.dataType() == "double")
    printf("%.9lf\n", data.doubleData());
  else if (data.dataType() == "boolean")
    Serial.println(data.boolData() == 1 ? "true" : "false");
  else if (data.dataType() == "string")
    Serial.println(data.stringData());
  else if (data.dataType() == "json")
  {
    Serial.println();
    FirebaseJson *json = data.jsonObjectPtr();
    //Print all object data
    Serial.println("Pretty printed JSON data:");
    String jsonStr;
    json->toString(jsonStr, true);
    Serial.println(jsonStr);
    Serial.println();
    Serial.println("Iterate JSON data:");
    Serial.println();
    size_t len = json->iteratorBegin();
    String key, value = "";
    int type = 0;
    for (size_t i = 0; i < len; i++)
    {
      json->iteratorGet(i, type, key, value);
      Serial.print(i);
      Serial.print(", ");
      Serial.print("Type: ");
      Serial.print(type == JSON_OBJECT ? "object" : "array");
      if (type == JSON_OBJECT)
      {
        Serial.print(", Key: ");
        Serial.print(key);
      }
      Serial.print(", Value: ");
      Serial.println(value);
    }
    json->iteratorEnd();
  }
  else if (data.dataType() == "array")
  {
    Serial.println();
    //get array data from FirebaseData using FirebaseJsonArray object
    FirebaseJsonArray *arr = data.jsonArrayPtr();
    //Print all array values
    Serial.println("Pretty printed Array:");
    String arrStr;
    arr->toString(arrStr, true);
    Serial.println(arrStr);
    Serial.println();
    Serial.println("Iterate array values:");
    Serial.println();

    for (size_t i = 0; i < arr->size(); i++)
    {
      Serial.print(i);
      Serial.print(", Value: ");

      FirebaseJsonData *jsonData = data.jsonDataPtr();
      //Get the result data from FirebaseJsonArray object
      arr->get(*jsonData, i);
      if (jsonData->typeNum == JSON_BOOL)
        Serial.println(jsonData->boolValue ? "true" : "false");
      else if (jsonData->typeNum == JSON_INT)
        Serial.println(jsonData->intValue);
      else if (jsonData->typeNum == JSON_DOUBLE)
        printf("%.9lf\n", jsonData->doubleValue);
      else if (jsonData->typeNum == JSON_STRING ||
               jsonData->typeNum == JSON_NULL ||
               jsonData->typeNum == JSON_OBJECT ||
               jsonData->typeNum == JSON_ARRAY)
        Serial.println(jsonData->stringValue);
    }
  }
}
