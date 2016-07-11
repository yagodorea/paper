#include <Wire.h>
#include <Adafruit_ADS1015.h>

Adafruit_ADS1115 ads;	// 0x49 -> ADR---GND

int16_t a;
byte b[2];
int i = 0;
int t = 0;
int LED = 8;

void setup()
{
  // Setup LED
  pinMode(LED,OUTPUT);
  // Begin Serial 
  Serial.begin(115200);
  // Set gain to 1-16
  ads.setGain(GAIN_SIXTEEN);
  // Begin ADS
  ads.begin();
}

void loop()
{
  // Protocol starting message
   //   Serial.write(B11111111);
   //   Serial.write(B11111111);
   //   Serial.write(B11111111);
   
  int now = micros();
  
  byte rec;

  if ((now-t) >= 1667)
  {
    t = now;
    
    // Read from device
    //a = analogRead(A0);
    //a = ads.readADC_SingleEnded(0);
    a = ads.readADC_Differential_0_1();
    
    b[0] = a;
    b[1] = a >> 8;
    Serial.write(b, 2);
    
    // Receive command from matlab
    if (Serial.available() > 0)
    {
      rec = Serial.read();
      if (rec == 1)
      {
        digitalWrite(LED,HIGH);
      } else {
        digitalWrite(LED,LOW);
      }
    }
  }
}
