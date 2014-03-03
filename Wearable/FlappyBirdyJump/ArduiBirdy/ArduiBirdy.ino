#include <Wire.h>
#include <LSM303.h>

LSM303 compass;

char report[80];

void setup()
{
  Serial.begin(9600);
  Wire.begin();
  if(!compass.init()) Serial.println("Device not recognized!");
  compass.enableDefault();

  compass.m_min = (LSM303::vector<int16_t>){-587,   -649,   -38};
  compass.m_max = (LSM303::vector<int16_t>){513,   567,   653};
}

void loop()
{
  compass.read();

  //+x - north
  int hx = (int)compass.heading((LSM303::vector<int>){1, 0, 0});
  int hy = (int)compass.heading((LSM303::vector<int>){0, 1, 0});
  int hz = (int)compass.heading((LSM303::vector<int>){0, 0, 1});
  
  //1009 == 1g
  int ax = compass.a.x >> 4;
  int ay = compass.a.y >> 4;
  int az = compass.a.z >> 4;
  
  snprintf(report, sizeof(report), "~,%d,%d,%d,%d,%d,%d,;", ax, ay, az, hx, hy, hz);
  Serial.println(report);

  delay(100);
}




