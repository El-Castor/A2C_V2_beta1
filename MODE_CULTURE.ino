#include <SPI.h> //Inclusion librarie SPI.h
#include <Ethernet.h>//Inclusion librarie Ethernet.h
#include <Wire.h>//Inclusion librarie Wire.h (pour DS1307)
#include <Arduino.h>//Inclusion librarie Arduino.h
#include <DS1307.h>//Inclusion librarie DS1307 (Horloge)
#include <Time.h>//Inclusion librarie Time
#include <DHT.h>
#include <LiquidCrystal.h>

#define DHTPIN A0 // pin du DHT
#define DHTTYPE DHT22 // type de dht

#define PHPIN 7          

DHT dht(DHTPIN, DHTTYPE); // test du fonctionnement

unsigned long int avgValue;  //Store the average value of the sensor feedback
float b;
int buf[10],temp;

int intracteur = 12; //Extracteur n°2 introduit en pin 12 (numérique)
int extracteur = 13; //Extracteur numéro 1 en pin 13 (numérique)
int hydro = 11; //Humidificateur introduit en pin 11 (numérique)
int brasseur = 10; //Ventillo brasseur introduit en pin 10 (numérique)
int lampe = 9; //Lampe introduit en pin 9 (numérique)
int chauffage = 8; //Chauffage introduit en pin 8 (numérique)

LiquidCrystal lcd(7, 6, 5, 4, 3, 2);

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

  //initialize serial communications at a 9600 baud rate
  Serial.begin(9600);
  lcd.begin(20,4); //initialisation du lcd de verif fonctionnement automate sans interface
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
  digitalWrite(13, HIGH);       
  delay(800);
  digitalWrite(13, LOW); 

  //Fin du sample du pH metre

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
