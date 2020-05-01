void setup()
{
  Serial.begin(115200);
  Serial1.begin(115200);
}

void loop()
{
  if(Serial.available()>0)
  {
    byte x = Serial.read();
    Serial1.write(x);
  }
  if(Serial1.available()>0)
  {
    Serial.write((char)Serial1.read());
  }
}
