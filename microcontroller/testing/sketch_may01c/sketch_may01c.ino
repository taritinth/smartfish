#include<SoftwareSerial.h>
//SoftwareSerial mySUART(4, 5);  //D2, D1 = SRX, STX
SoftwareSerial NodeMCU(12, 14); // RX | TX  , D6 = 12 D5 = 14

void setup()
{
  Serial.begin(115200);
  NodeMCU.begin(115200);
//  pinMode(4, INPUT);
//  pinMode(5, OUTPUT);
}

void loop()
{
  if(Serial.available()>0)
  {
    byte x = Serial.read();
    NodeMCU.write(x);
  }
  if(NodeMCU.available()>0)
  {
    Serial.write((char)NodeMCU.read());
  }
}
