#include <SPI.h> //Inclusion librarie SPI.h
#include <Ethernet.h>//Inclusion librarie Ethernet.h
#include <Wire.h>//Inclusion librarie Wire.h (pour DS1307)
#include <Arduino.h>//Inclusion librarie Arduino.h
#include <DS1307.h>//Inclusion librarie DS1307 (Horloge)
#include <Time.h>//Inclusion librarie Time
#include <DHT.h>
#include <LiquidCrystal.h>
#include "DFRobot_EC.h"
#include <EEPROM.h>
#include <OneWire.h>

#define DHTPIN A0 // pin du DHT
#define DHTTYPE DHT22 // type de dht
//#define EC_PIN A8
//float voltage,voltageBeforeTreatment,ecValue,temperature = 25;
//DFRobot_EC ec;

#define PHPIN 7          
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

const byte numReadings = 20;     //the number of sample times
byte ECsensorPin = A1;  //EC Meter analog output,pin on analog 1
byte DS18B20_Pin = 2; //DS18B20 signal, pin on digital 2
unsigned int AnalogSampleInterval=25,printInterval=700,tempSampleInterval=850;  //analog sample interval;serial print interval;temperature sample interval
unsigned int readings[numReadings];      // the readings from the analog input
byte index = 0;                  // the index of the current reading
unsigned long AnalogValueTotal = 0;                  // the running total
unsigned int AnalogAverage = 0,averageVoltage=0;                // the average
unsigned long AnalogSampleTime,printTime,tempSampleTime;
float temperature,ECcurrent; 

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);
//Temperature chip i/o
OneWire ds(DS18B20_Pin);  // on digital pin 2

char val;

void setup()  //Fonction d'initialisation de la carte
{  //Début contenue de l'initialisation
  /* RTC.stop();
   RTC.set(DS1307_SEC,00);        //réglage secondes
   RTC.set(DS1307_MIN,54);        //réglage minutes
   RTC.set(DS1307_HR,00);         //réglage heures
   RTC.set(DS1307_DOW,4);         //réglage jour de la semaine
   RTC.set(DS1307_DATE,28);       //réglage date
   RTC.set(DS1307_MTH,11);        //réglage mois
   RTC.set(DS1307_YR,13);         //réglage année
   RTC.start();
   */
  /*pinMode(13,OUTPUT);   */        //initialisation de la broche ? comme étant une sortie
  pinMode(chauffage, OUTPUT);   //initialisation de la broche 8 comme étant une sortie
  pinMode(lampe, OUTPUT);       //initialisation de la broche 9 comme étant une sortie
  pinMode(brasseur, OUTPUT);    //initialisation de la broche 12 comme étant une sortie
  pinMode(hydro, OUTPUT);       //initialisation de la broche 11 comme étant une sortie
  pinMode(extracteur, OUTPUT);  //initialisation de la broche 13 comme étant une sortie
  pinMode(intracteur, OUTPUT); //initialisation de la broche 12 comme étant une sortie

  digitalWrite(chauffage, LOW);   //écriture en sortie (broche 8) d'un état BAS
  digitalWrite(lampe, LOW);       //écriture en sortie (broche 9) d'un état BAS
  digitalWrite(brasseur, LOW);    //écriture en sortie (broche 12) d'un état BAS
  digitalWrite(hydro, LOW);       //écriture en sortie (broche 11) d'un état BAS
  digitalWrite(extracteur, LOW);  //écriture en sortie (broche 13) d'un état BAS
  digitalWrite(intracteur, LOW); //écriture en sortie (broche 12) d'un état BAS

  // initialize all the readings to 0:
  for (byte thisReading = 0; thisReading < numReadings; thisReading++)
    readings[thisReading] = 0;
  TempProcess(StartConvert);   //let the DS18B20 start the convert
  AnalogSampleTime=millis();
  printTime=millis();
  tempSampleTime=millis();

  //initialize serial communications at a 9600 baud rate
  Serial.begin(9600);
  lcd.begin(20,4); //initialisation du lcd de verif fonctionnement automate sans interface
  //ec.begin();
}

//Nouvelles fonctions qui s'affiche "choix des modes de cultures"***********************************************************************************
void loop() 
{  
  int selectedMode = 1; // Mode selectionné. 1 = Croissance, 2 = Floraison, 3 = Fin de floraison

  int minut;       // Introduction Minutes
  int heure;       // Introduction Heures
  int seconde;     // Introduction secondes
  int date;        // Introduction date
  int mois;        // Introdction mois
  int annee;       // Introduction années
  int temps_perso; // temps actuels interpréter

  int chauffage_on;
  int chauffage_off;
  int hydro_on;
  int hydro_off;
  int extracteur_on;
  int extracteur_off;
  int intracteur_on;
  int intracteur_off;
  int lampe_on;
  int lampe_off;

  int extracteurStateON = digitalRead(extracteur_on);
  int extracteurStateOFF = digitalRead(extracteur_off);
  

  //Introduction du programme Croissance si bouton 1 subit une pression
  digitalWrite(brasseur, HIGH); //Ecriture en sortie (broche12) en état BAS

  dht.begin();

  heure = RTC.get(DS1307_HR,true);  
  minut = RTC.get(DS1307_MIN,false);
  seconde = RTC.get(DS1307_SEC,false);
  date = RTC.get(DS1307_DATE,false);
  mois = RTC.get(DS1307_MTH,false);
  annee = RTC.get(DS1307_YR,false);
  temps_perso = (heure * 100) + minut;  //creation temps_perso

  float h = dht.readHumidity(); //Lecture de la constante "Humidité" de la sonde par l'arduino
  float t = dht.readTemperature(); //Lecture de la constate "Température" de la sonde par l'arduino

  if (selectedMode == 1)
  {
    chauffage_on = 18;
    chauffage_off = 19;
    hydro_on = 65;
    hydro_off = 85;
    extracteur_on = 21;
    extracteur_off = 18;
    intracteur_on = 29;
    intracteur_off = 27;
    lampe_on = 530;
    lampe_off = 2330;
    
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
     if (heure < 10)
     {
      lcd.print("0");
     } 
     lcd.print(RTC.get(DS1307_HR,true)); 
     lcd.print("H");
     if (minut < 10)
     {
      lcd.print("0");
     }
     {
     lcd.print(RTC.get(DS1307_MIN,false));
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
  //lcd.clear();
  }    
      
  else if (selectedMode == 2)
  {
    chauffage_on = 18;
    chauffage_off = 20;
    hydro_on = 50;
    hydro_off = 60;
    extracteur_on = 21;
    extracteur_off = 18;
    intracteur_on = 29;
    intracteur_off = 27;
    lampe_on = 659;
    lampe_off = 1900;

    lcd.setCursor(0,0);
    lcd.print("  MODE  2  ");
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
    if (heure < 10)
    {
      lcd.print("0");
    } 
    lcd.print(RTC.get(DS1307_HR,true)); 
    lcd.print("H");
    if (minut < 10)
    {
      lcd.print("0");
    }
    lcd.print(RTC.get(DS1307_MIN,false));
    lcd.print(" ");
  }
  else 
  {
    chauffage_on = 18;
    chauffage_off = 19;
    hydro_on = 40;
    hydro_off = 50;
    extracteur_on = 21;
    extracteur_off = 18;
    intracteur_on = 29;
    intracteur_off = 27;
    lampe_on = 659;
    lampe_off = 2000;

    lcd.setCursor(0,0);
    lcd.print("  MODE  3  ");
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
    if (heure < 10)
    {
      lcd.print("0");
    } 
    lcd.print(RTC.get(DS1307_HR,true)); 
    lcd.print("H");
    if (minut < 10)
    {
      lcd.print("0");
    }
    lcd.print(RTC.get(DS1307_MIN,false));
    lcd.print(" ");
    }

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

    if (selectedMode == 1)
    {
      if(temps_perso > lampe_on && temps_perso < lampe_off)
      {
        digitalWrite(lampe,HIGH); //écritue de la broche 9 en état HAUT
      }
      else
      {
        digitalWrite(lampe, LOW);
      }
    }
    else 
    {
       digitalWrite(lampe, LOW);
    }
  }

  //Début du sample du pH metre
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
  //digitalWrite(13, HIGH);       
  //delay(800);
  //digitalWrite(13, LOW); 

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
      if(CoefficientVolatge<=448)ECcurrent=6.84*CoefficientVolatge-64.32;   //1ms/cm<EC<=3ms/cm
      else if(CoefficientVolatge<=1457)ECcurrent=6.98*CoefficientVolatge-127;  //3ms/cm<EC<=10ms/cm
      else ECcurrent=5.3*CoefficientVolatge+2278;                           //10ms/cm<EC<20ms/cm
      ECcurrent/=1000;    //convert us/cm to ms/cm
      Serial.print(ECcurrent,2);  //two decimal
      Serial.println("ms/cm");
    }
  }
  /* //Début du sample de l'Ec metre v2 
  static unsigned long timepoint = millis();
    if(millis()-timepoint>1000U)  //time interval: 1s
    {
      timepoint = millis();
      voltageBeforeTreatment = analogRead(EC_PIN);
      Serial.print("VoltageBeforeTreatment=");
      Serial.print(voltageBeforeTreatment);
      voltage = analogRead(EC_PIN)/1024.0*5000;  // read the voltage
      Serial.print("voltageEcmeter");
      Serial.print(voltage);
      temperature = dht.readTemperature();  // read your temperature sensor to execute temperature compensation
      ecValue =  ec.readEC(voltage,temperature);  // convert voltage to EC with temperature compensation
      Serial.print("temperature:");
      Serial.print(temperature,1);
      Serial.print("^C  EC:");
      Serial.print(ecValue,2);
      Serial.println("ms/cm");
    }
    ec.calibration(voltage,temperature);  // calibration process by Serail CMD
    //fin du sample de l'Ec metre
*/
//fin du sample de l'Ec metre

  // If data is available to read,
  if (Serial.available() > 0) 
  { 
    val = Serial.read(); // read it and store it in val

    selectedMode = val;
  }
  // If arduino doesn't read correctly the sensors
  else if (!(isnan(t) || isnan(h) || isnan(phValue)))
  { //Debogage des different pin (affiche leurs etats en temps réel sur le moniteur série)
    Serial.print(t);
    Serial.print(",");
    Serial.print(h);
    Serial.print(",");
    Serial.print(phValue);
    Serial.print(",");
    //Serial.print("température:");
    //Serial.print(temperature,1);
    //Serial.print("^C  EC:");
    //Serial.print(ecValue,2);
    //Serial.println("ms/cm");
    //Serial.print("voltageEcmeter:");
    //Serial.println(analogRead(voltage));
    Serial.println(digitalRead(extracteur));
    Serial.println(digitalRead(lampe));
    Serial.println(digitalRead(intracteur));
    Serial.print(digitalRead(brasseur));
    Serial.println();
  }
 {
  delay(1000);

  }
}

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

