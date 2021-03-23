#include <SPI.h> //Inclusion librarie SPI.h
#include <Ethernet.h>//Inclusion librarie Ethernet.h
#include <Wire.h>//Inclusion librarie Wire.h (pour DS1307)
#include <Arduino.h>//Inclusion librarie Arduino.h
#include <Time.h>//Inclusion librarie Time
#include <DHT.h>
#include <LiquidCrystal.h>
#include "DFRobot_EC.h"
#include <EEPROM.h>
#include <OneWire.h>
//#include "RTClib.h"  // Bibliothèque pour le module RTC

// Set up communication with arduino and TinyRTC
#include "Wire.h"
#define DS1307_I2C_ADDRESS 0x68


#define DHTPIN A0 // pin du DHT
#define DHTTYPE DHT22 // type de dht


#define PHPIN 7 //pin du ds18B20         
DHT dht(DHTPIN, DHTTYPE); // test du fonctionnement

#define StartConvert 0
#define ReadTemperature 1

unsigned long int avgValue;  //Store the average value of the sensor feedback
float b;
int buf[10],temp;


int intracteur = 12; //Extracteur n°2 introduit en pin 12 (numérique)
int extracteur = 13; //Extracteur numéro 1 en pin 13 (numérique)
int hydro = 11; //Humidificateur introduit en pin 11 (numérique)
int brasseur = 10; //Ventillo brasseur introduit en pin 10 (numérique)
int lampe = 9; //Lampe introduit en pin 9 (numérique)
int chauffage = 8; //Chauffage introduit en pin 8 (numérique)

  
String temps_perso; // temps actuels interpréter


int chauffage_on;
int chauffage_off;
int hydro_on;
int hydro_off;
int extracteur_on;
int extracteur_off;
int intracteur_on;
int intracteur_off;
String lampe_on;
String lampe_off;

  
String hourOn;
String minuteOn;
String hourOFF;
String minuteOff;

const byte numReadings = 20;     //the number of sample times
byte ECsensorPin = A8;  //EC Meter analog output,pin on analog 1
byte DS18B20_Pin = 43; //DS18B20 signal, pin on digital 2
unsigned int AnalogSampleInterval=25,printInterval=700,tempSampleInterval=850;  //analog sample interval;serial print interval;temperature sample interval
unsigned int readings[numReadings];      // the readings from the analog input
byte index = 0;                  // the index of the current reading
unsigned long AnalogValueTotal = 0;                  // the running total
unsigned int AnalogAverage = 0,averageVoltage=0;                // the average
unsigned long AnalogSampleTime,printTime,tempSampleTime;
float temperature,ECcurrent; 

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

//Temperature chip i/o
OneWire ds(DS18B20_Pin);  // on digital pin 43

// Convert normal decimal numbers to binary coded decimal
byte decToBcd(byte val)
{
return ( (val/10*16) + (val%10) );
}

// Convert binary coded decimal to normal decimal numbers
byte bcdToDec(byte val)
{
return ( (val/16*10) + (val%16) );
}



char val;

void setup()  //Fonction d'initialisation de la carte
{  //Début contenue de l'initialisation

  pinMode(13,OUTPUT);           //initialisation de la broche ? comme étant une sortie
  pinMode(chauffage, OUTPUT);   //initialisation de la broche 8 comme étant une sortie
  pinMode(lampe, OUTPUT);       //initialisation de la broche 9 comme étant une sortie
  pinMode(brasseur, OUTPUT);    //initialisation de la broche 12 comme étant une sortie
  pinMode(hydro, OUTPUT);       //initialisation de la broche 11 comme étant une sortie
  pinMode(extracteur, OUTPUT);  //initialisation de la broche 13 comme étant une sortie
  pinMode(intracteur, OUTPUT);  //initialisation de la broche 12 comme étant une sortie

  digitalWrite(chauffage, LOW);   //écriture en sortie (broche 8) d'un état BAS
  digitalWrite(lampe, LOW);       //écriture en sortie (broche 9) d'un état BAS
  digitalWrite(brasseur, LOW);    //écriture en sortie (broche 12) d'un état BAS
  digitalWrite(hydro, LOW);       //écriture en sortie (broche 11) d'un état BAS
  digitalWrite(extracteur, LOW);  //écriture en sortie (broche 13) d'un état BAS
  digitalWrite(intracteur, LOW); //écriture en sortie (broche 12) d'un état BAS

  // initialize all the readings to 0:
  for (byte thisReading = 0; thisReading < numReadings; thisReading++){  
    readings[thisReading] = 0;
    TempProcess(StartConvert);   //let the DS18B20 start the convert
    AnalogSampleTime=millis();
    printTime=millis();
    tempSampleTime=millis();
  }

  //initialize serial communications at a 9600 baud rate
  Serial.begin(9600);
  lcd.begin(20,4); //initialisation du lcd de verif fonctionnement automate sans interface
  Wire.begin();
  dht.begin();
 
}

/******************* start loop ***************************/
void loop() 
{  
  byte second, minute, hour, dayOfWeek, dayOfMonth, month, year;

  getDateDs1307(&second, &minute, &hour, &dayOfWeek, &dayOfMonth, &month, &year);
  Serial.print(hour, DEC);
  Serial.print(":");
  Serial.print(minute, DEC);
  Serial.print(":");
  Serial.print(second, DEC);
  Serial.print(" ");
  Serial.print(month, DEC);
  Serial.print("/");
  Serial.print(dayOfMonth, DEC);
  Serial.print("/");
  Serial.print(year, DEC);
  Serial.print(" Day_of_week:");
  Serial.println(dayOfWeek, DEC);

    
  int selectedMode = 1; // Mode selectionné. 1 = Croissance, 2 = Floraison, 3 = Fin de floraison
  

  //Introduction du programme Croissance si bouton 1 subit une pression
  digitalWrite(brasseur, HIGH); //Ecriture en sortie (broche12) en état BAS

  dht.begin();

  float h = dht.readHumidity(); //Lecture de la constante "Humidité" de la sonde par l'arduino
  float t = dht.readTemperature(); //Lecture de la constate "Température" de la sonde par l'arduino


  temps_perso=String(hour, DEC)+String(minute, DEC);

    if (selectedMode == 1)
  {
    hourOn = 5;
    minuteOn = 30;
    hourOFF = 23;
    minuteOff = 30;
    chauffage_on = 18;
    chauffage_off = 19;
    hydro_on = 65;
    hydro_off = 85;
    extracteur_on = 21;
    extracteur_off = 18;
    intracteur_on = 29;
    intracteur_off = 27;
    lampe_on = hourOn+minuteOn;
    lampe_off = hourOFF+minuteOff;

    printToLCD(lampe, extracteur, intracteur, chauffage, hydro, brasseur, t, h, hour, minute);

    controlHardware(t, h, chauffage_off, chauffage_on, extracteur_on, extracteur_off, hydro_off, hydro_on, intracteur_on, intracteur_off);
 /* if (!(isnan(t) || isnan(h)))// Si l'arduino renvoit e la merde en sortie
  {
    if(t > chauffage_off) // Chauffage doit s'éteindre
    {  
      digitalWrite(chauffage, LOW); //écritue de la broche 8 en état BAS
    }

    if (t < chauffage_on) // Chauffage doit s'allumer
    {
      digitalWrite(chauffage, HIGH); //écritue de la broche 8 en état HAUT 
    }

    if(t > extracteur_on)
    { //Si extracteur allumé 
      digitalWrite(extracteur, HIGH); //écritue de la broche 13 en état HAUT
    }

    if(t < extracteur_off)
    { //si l'extracteur est éteint 
      digitalWrite(extracteur, LOW); //écriture de la broche 13 en etat BAS
    }

    if(h > hydro_off)
    { //si humidificateur éteint
      digitalWrite(hydro, LOW); //écriture de la broche 12 en état BAS
    }

    if(h < hydro_on)
    { //si humidificateur allumé
      digitalWrite(hydro, HIGH); //écriture de la broche 12 en état HAUT
    }

    if(t > intracteur_on)
    { //si l'intraction est allumée
      digitalWrite(intracteur, HIGH); //écriture de la broche 12 en état HAUT
    }

    if(t < intracteur_off)
    { //si l'intraction est éteinte 
      digitalWrite(intracteur, LOW); //écriture de la broche 12 en état BAS
    }

    if (selectedMode == 1)
    {
      Serial.print("temp_perso : ");
      Serial.print(temps_perso);
      if(temps_perso > lampe_on && temps_perso < lampe_off)
      {
        digitalWrite(lampe,HIGH); //écritue de la broche 9 en état HAUT
        Serial.print("Lampe allume");
      }
      else
      {
        digitalWrite(lampe, LOW);
        Serial.print("Lampe eteinte");
      }
    }
    else 
    {
       digitalWrite(lampe, LOW);
       Serial.print("Lampe eteinte car pas de mode");
    }
  }
*/
  /// Fin sample control hardware ////

  } // end selectMode=1 if    
      
  //Début du sample du pH metre
/*void readpHValueFromSensor(){
  for(int i=0;i<10;i++)       //Get 10 sample value from the sensor for smooth the value
  { 
    buf[i]=analogRead(PHPIN);
    delay(10);
  }
  for(int i=0;i<9;i++)        //sort the analog from small to large
  {
    for(int j=i+1;j<10;j++)
    {
      if(buf[i]>buf[j])
      {
        temp=buf[i];
        buf[i]=buf[j];
        buf[j]=temp;
      }
    }
  }
  
  avgValue=0;
  for(int i=2;i<8;i++)                      //take the average value of 6 center sample
    avgValue+=buf[i];
  float phValue=(float)avgValue*5.0/1024/6; //convert the analog into millivolt
  phValue=3.5*phValue;                      //convert the millivolt into pH value
  return(phValue)
} */
 float phValue = readpHValueFromSensor();
  //Fin du sample du pH metre

  //Début du sample de l'Ec metre
 /*
   Every once in a while,sample the analog value and calculate the average.
  */
  if(millis()-AnalogSampleTime>=AnalogSampleInterval)  
  {
    AnalogSampleTime=millis();
     // subtract the last reading:
    AnalogValueTotal = AnalogValueTotal - readings[index];
    // read from the sensor:
    readings[index] = analogRead(ECsensorPin);
    // add the reading to the total:
    AnalogValueTotal = AnalogValueTotal + readings[index];
    // advance to the next position in the array:
    index = index + 1;
    // if we're at the end of the array...
    if (index >= numReadings)
    // ...wrap around to the beginning:
    index = 0;
    // calculate the average:
    AnalogAverage = AnalogValueTotal / numReadings;
  }
  /*
   Every once in a while,MCU read the temperature from the DS18B20 and then let the DS18B20 start the convert.
   Attention:The interval between start the convert and read the temperature should be greater than 750 millisecond,or the temperature is not accurate!
  */
   if(millis()-tempSampleTime>=tempSampleInterval) 
  {
    tempSampleTime=millis();
    temperature = TempProcess(ReadTemperature);  // read the current temperature from the  DS18B20
    TempProcess(StartConvert);                   //after the reading,start the convert for next reading
  }
   /*
   Every once in a while,print the information on the serial monitor.
  */
  if(millis()-printTime>=printInterval)
  {
    printTime=millis();
    averageVoltage=AnalogAverage*(float)5000/1024;
    Serial.print("Analog value:");
    Serial.print(AnalogAverage);   //analog average,from 0 to 1023
    Serial.print("    Voltage:");
    Serial.print(averageVoltage);  //millivolt average,from 0mv to 4995mV
    Serial.print("mV    ");
    Serial.print("temp:");
    Serial.print(temperature);    //current temperature
    Serial.print("^C     EC:");
    
    float TempCoefficient=1.0+0.0185*(temperature-25.0);    //temperature compensation formula: fFinalResult(25^C) = fFinalResult(current)/(1.0+0.0185*(fTP-25.0));
    float CoefficientVolatge=(float)averageVoltage/TempCoefficient;   
    if(CoefficientVolatge<150)Serial.println("No solution!");   //25^C 1413us/cm<-->about 216mv  if the voltage(compensate)<150,that is <1ms/cm,out of the range
    else if(CoefficientVolatge>3300)Serial.println("Out of the range!");  //>20ms/cm,out of the range
    else
    { 
      if(CoefficientVolatge<=448)ECcurrent=6.84*CoefficientVolatge-0,7;   //1ms/cm<EC<=3ms/cm 
      else if(CoefficientVolatge<=1457)ECcurrent=6.98*CoefficientVolatge-127;  //3ms/cm<EC<=10ms/cm
      else ECcurrent=5.3*CoefficientVolatge+2278;                           //10ms/cm<EC<20ms/cm
      ECcurrent/=1000;    //convert us/cm to ms/cm
      Serial.print(ECcurrent,2);  //two decimal
      Serial.println("ms/cm");
    }
  }
  
//fin du sample de l'Ec metre
  
  debbuggingWithSerial(t, h, phValue, extracteur, intracteur, brasseur, lampe);
}

float readpHValueFromSensor(){
  for(int i=0;i<10;i++)       //Get 10 sample value from the sensor for smooth the value
  { 
    buf[i]=analogRead(PHPIN);
    delay(10);
  }
  for(int i=0;i<9;i++)        //sort the analog from small to large
  {
    for(int j=i+1;j<10;j++)
    {
      if(buf[i]>buf[j])
      {
        temp=buf[i];
        buf[i]=buf[j];
        buf[j]=temp;
      }
    }
  }
  
  avgValue=0;
  for(int i=2;i<8;i++)                      //take the average value of 6 center sample
    avgValue+=buf[i];
  float phValue=(float)avgValue*5.0/1024/6; //convert the analog into millivolt
  phValue=3.5*phValue;                      //convert the millivolt into pH value
  return(phValue);
}

/******************* debbuging function - for serial monitoring ********************/
void debbuggingWithSerial(float t, float h, float phValue, int extracteur, int intracteur, int brasseur, int lampe){
  // If data is available to read,
  if (Serial.available() > 0) 
  { 
    val = Serial.read(); // read it and store it in val
    
    //selectedMode = val;
  }
  // If arduino doesn't read correctly the sensors
  else if (!(isnan(t) || isnan(h) || isnan(phValue)))
  { //Debogage des different pin (affiche leurs etats en temps réel sur le moniteur série)
  
    Serial.println("Mode 1 selected");
    Serial.println("valeur de lamp-on: ");
    Serial.println(lampe_on);
    Serial.println("valeur de lamp-off: ");
    Serial.println(lampe_off);
    Serial.println("valeur de hourOn: ");
    Serial.println(hourOn);
     Serial.println("valeur de minuteOn: ");
    Serial.println(minuteOn);

    Serial.println(" Temperature Box: ");
    Serial.println(t);
    Serial.println(" Humidity Box:");
    Serial.println(h);
    Serial.println(" pH value:");
    Serial.println(phValue);
    Serial.println("extractor statement :");
    Serial.println(digitalRead(extracteur));
    Serial.println("light statement :");
    Serial.println(digitalRead(lampe));
    Serial.println("intractor statement :");
    Serial.println(digitalRead(intracteur));
    Serial.println("FAN statement :");
    Serial.print(digitalRead(brasseur));
    Serial.println();
  }
  
}

/*************** Gets the date and time from the ds1307 ***********************/
void getDateDs1307(byte *second,
byte *minute,
byte *hour,
byte *dayOfWeek,
byte *dayOfMonth,
byte *month,
byte *year)
{
// Reset the register pointer
Wire.beginTransmission(DS1307_I2C_ADDRESS);
Wire.write(0);
Wire.endTransmission();

Wire.requestFrom(DS1307_I2C_ADDRESS, 7);

// A few of these need masks because certain bits are control bits
*second = bcdToDec(Wire.read() & 0x7f);
*minute = bcdToDec(Wire.read());
*hour = bcdToDec(Wire.read() & 0x3f); // Need to change this if 12 hour am/pm
*dayOfWeek = bcdToDec(Wire.read());
*dayOfMonth = bcdToDec(Wire.read());
*month = bcdToDec(Wire.read());
*year = bcdToDec(Wire.read());
}


/*************** Gets the temp of water ***********************/
/*
ch=0,let the DS18B20 start the convert;ch=1,MCU read the current temperature from the DS18B20.
*/
float TempProcess(bool ch)
{
  //returns the temperature from one DS18B20 in DEG Celsius
  static byte data[12];
  static byte addr[8];
  static float TemperatureSum;
  if(!ch){
          if ( !ds.search(addr)) {
              Serial.println("no more sensors on chain, reset search!");
              ds.reset_search();
              return 0;
          }      
          if ( OneWire::crc8( addr, 7) != addr[7]) {
              Serial.println("CRC is not valid!");
              return 0;
          }        
          if ( addr[0] != 0x10 && addr[0] != 0x28) {
              Serial.print("Device is not recognized!");
              return 0;
          }      
          ds.reset();
          ds.select(addr);
          ds.write(0x44,1); // start conversion, with parasite power on at the end
  }
  else{  
          byte present = ds.reset();
          ds.select(addr);    
          ds.write(0xBE); // Read Scratchpad            
          for (int i = 0; i < 9; i++) { // we need 9 bytes
            data[i] = ds.read();
          }         
          ds.reset_search();           
          byte MSB = data[1];
          byte LSB = data[0];        
          float tempRead = ((MSB << 8) | LSB); //using two's compliment
          TemperatureSum = tempRead / 16;
    }
          return TemperatureSum;  
}

/*************** function to control hardware ***********************/

int controlHardware(int t, int h, int chauffage_off, int chauffage_on,int extracteur_on, int extracteur_off, int hydro_off, int hydro_on, int intracteur_on, int intracteur_off){
  if (!(isnan(t) || isnan(h)))// Si l'arduino renvoit e la merde en sortie
  {
    if(t > chauffage_off) // Chauffage doit s'éteindre
    {  
      digitalWrite(chauffage, LOW); //écritue de la broche 8 en état BAS
    }

    if (t < chauffage_on) // Chauffage doit s'allumer
    {
      digitalWrite(chauffage, HIGH); //écritue de la broche 8 en état HAUT 
    }

    if(t > extracteur_on)
    { //Si extracteur allumé 
      digitalWrite(extracteur, HIGH); //écritue de la broche 13 en état HAUT
    }

    if(t < extracteur_off)
    { //si l'extracteur est éteint 
      digitalWrite(extracteur, LOW); //écriture de la broche 13 en etat BAS
    }

    if(h > hydro_off)
    { //si humidificateur éteint
      digitalWrite(hydro, LOW); //écriture de la broche 12 en état BAS
    }

    if(h < hydro_on)
    { //si humidificateur allumé
      digitalWrite(hydro, HIGH); //écriture de la broche 12 en état HAUT
    }

    if(t > intracteur_on)
    { //si l'intraction est allumée
      digitalWrite(intracteur, HIGH); //écriture de la broche 12 en état HAUT
    }

    if(t < intracteur_off)
    { //si l'intraction est éteinte 
      digitalWrite(intracteur, LOW); //écriture de la broche 12 en état BAS
    }

      //Serial.print("temp_perso : "); // just for debbugging
      //Serial.print(temps_perso); // just for debbugging
      if(temps_perso > lampe_on && temps_perso < lampe_off)
      {
        digitalWrite(lampe,HIGH); //écritue de la broche 9 en état HAUT
        Serial.print("Light On");
      }
      else
      {
        digitalWrite(lampe, LOW);
        Serial.print("Light off");
      }
    }
    else 
    {
       digitalWrite(lampe, LOW);
       Serial.print("Box light off, no mode selected");
    }
 }//end function control hardware

/************************ function to print variable on the lcd *************************/
void printToLCD(int lampe, int extracteur, int intracteur, int chauffage, int hydro, int brasseur, float t, float h, byte hour, byte minute){  
    lcd.setCursor(0,0);
    lcd.print("  MODE  1  ");
    lcd.setCursor(0,1);
    lcd.print("TEMPERATURE ");
    lcd.print(t); 
    lcd.print(" C");
    lcd.setCursor(0,2);
    lcd.print("HYDROMETRIE ");
    lcd.print(h); 
    lcd.print(" %");
    lcd.setCursor(7,3);
     if(digitalRead(lampe) == HIGH)
     {
     lcd.print("LAMPE ALLUMEE");
     }
     else
     {
     lcd.print("LAMPE ETEINTE");
     }
     delay(10);
        lcd.setCursor(0,3);
     if (hour < 10)
     {
      lcd.print("0");
     } 
     lcd.print(hour, DEC); 
     lcd.print("H");
     if (minute < 10)
     {
      lcd.print("0");
     }
     {
     lcd.print(minute, DEC);
     lcd.print(" ");
     }

   delay(3000);
   lcd.clear();
   
   for (int i=0;i<10;i++)//lcd page 2
        //Début sketch affichage LCD de l'état des périphérique externes
     lcd.setCursor(0,0);
     lcd.print("INTRA  ");
     lcd.setCursor(7,0);
       if(digitalRead(extracteur) == HIGH)
       {
       lcd.print("ON ");
       }
       else
       {
       lcd.print("OFF");
       }
       
       lcd.setCursor(0,1);
      lcd.print("EXTRA  ");
      lcd.setCursor(7,1);
        if(digitalRead(intracteur) == HIGH)
        {
        lcd.print("ON ");
        }
        else
        {
        lcd.print("OFF");
        }
        
        lcd.setCursor(0,2);
      lcd.print("CHAUFFAGE ");
      lcd.setCursor(10,2);
       if(digitalRead(chauffage) == HIGH)
       {
       lcd.print("ON ");
       }
       else
       {
       lcd.print("OFF");
       }
       
       lcd.setCursor(0,3);
      lcd.print("HYDRO ");
      lcd.setCursor(6,3);
       if(digitalRead(hydro) == HIGH)
       {
       lcd.print("ON ");
       }
       else
       {
       lcd.print("OFF");
       }
       lcd.setCursor(11,3);
      lcd.print("BRA ");
      lcd.setCursor(15,3);
       if(digitalRead(brasseur) == HIGH)
       {
       lcd.print("ON ");
       }
       else
       {
       lcd.print("OFF");
       } 
  delay(4000);
 }// End function printToLCD()
