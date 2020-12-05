// TODO : - add good coordonate for Ec value  / issues with the graduation 1 to 7 is to big
//        - create a warning message box if pH is under the streshold that the plant can support for each data condition read by the automate
//        - range all the data in database

import cc.arduino.*;
import controlP5.*;
import processing.serial.*;
import processing.video.*;

// GUI elements
ControlP5 cp5;
DropdownList serialPortDDList;
DropdownList modeDDList;
Button connectButton;
Textlabel errorLabel;
Textlabel[] constantLabels, constantPanelLabels;
Numberbox[] constantNumberboxes;
Slider[] constantSlider;

// Video elements
Capture cam;

// Boolean variables
boolean isConnected;

// Data variable
String selectedPort;

//******************************************************************* initiatlisations des pin de l'arduino *******************************************************************
//arduino = new Arduino(this, Arduino.list()[0], 57600); // change the 0 by the number of port where the arduino is connect
Arduino arduino;

int intracteur = 12; //Extracteur n°2 introduit en pin 12 (numérique)
int extracteur = 13; //Extracteur numéro 1 en pin 13 (numérique)
int hydro = 11; //Humidificateur introduit en pin 11 (numérique)
int brasseur = 10; //Ventillo brasseur introduit en pin 10 (numérique)
int lampe = 9; //Lampe introduit en pin 9 (numérique)
int chauffage = 8; //Chauffage introduit en pin 8 (numérique)

//******************************************************************* initiatlisations des variables *******************************************************************
String myPort = "25"; //Serial monPort;  //Déclaration port série pour la lecture des données envoyées par l'Arduino
//int mesure; //Mesure lue sur le port 

// List all the available serial ports
//println(Serial.list());
//myPort = new Serial(this, Serial.list()[0], 9600);
//myPort.bufferUntil('\n');

int x = displayWidth/2;
int y = displayHeight/2;
int j,k;
int yOffset = displayHeight / 18;

int sliderLumValue = 100;

float w = 30;
float h = 30;
boolean t=false;
boolean hy=false;
boolean e=false;
boolean p=false;
boolean s=false;

Toggle constantToogleHy;

//TODO rename one letter variable for Vivien pleasure ex: pH_checkbox
int constante=25;      //constante d'interêt mesurée par l'Arduino
float constmini=34;         //constante d'interêt mini mesurée par l'Arduino
float constmax=12;          // maxi mesurée par l'Arduino
int constCar=25;
int m;                   //Indice de travail
int kn;  //Indice de travail

int yOffset_tmp = displayHeight / 18;

int xg=0;
int xg0=0;                //Abcisse précédente

float yg=0;
float yg0=0;                  //Ordonnée précédente

int premier = 0;         // Bypass premiere valeur erronée

StringList togglesNamesList;
StringList constantLabelsPanelNamesList;


//******************************************************************* Void Setup *******************************************************************//
// TODO get the maximum value for tempMax and Mini
void setup()
{
//calibration of the object position related to the screen laptop
int yOffset = displayHeight / 18;
  
 int spaceToggles = 40;
  
 togglesNamesList = new StringList();
 togglesNamesList.append("Temp");
 togglesNamesList.append("Hygro");
 togglesNamesList.append("TempSol");
 togglesNamesList.append("pH");
 togglesNamesList.append("Ec");
 
 constantLabelsPanelNamesList = new StringList();
 constantLabelsPanelNamesList.append("tempMinLabel");
 constantLabelsPanelNamesList.append("tempMaxLabel");
 

 size(displayWidth,displayHeight);
 
 cp5= new ControlP5(this);
 
 //Checking the connection of the arduino to the arduino or computer
 isConnected=false;

 //TODO [Toggle] listToggles = array vide
 
 //listToggles[] = new Numberbox[5];

println(togglesNamesList);
println(constantLabelsPanelNamesList);

cp5.addToggle("Temp").setValue(0).setPosition(displayWidth/2-100, displayHeight / 2 + yOffset / 4).setSize(50,25).setState(false); //each function return the toggle so at the end you add t
constantToogleHy = cp5.addToggle("Hygro").setValue(0).setPosition(displayWidth/2-100,displayHeight / 2 + spaceToggles + yOffset / 4).setSize(50,25).setState(false);
cp5.addToggle("TempSol").setValue(0).setPosition(displayWidth/2-100,displayHeight / 2 + spaceToggles*2 + yOffset / 4).setSize(50,25).setState(false);
cp5.addToggle("pH").setValue(0).setPosition(displayWidth/2-100,displayHeight / 2 + spaceToggles*2+40 + yOffset / 4).setSize(50,25).setState(false);
cp5.addToggle("Ec").setValue(0).setPosition(displayWidth/2-100,displayHeight / 2 + spaceToggles*2+80 + yOffset / 4).setSize(50,25).setState(false);

//connectionScreenSetup();
initConstantViews();
mainScreenSetup();

}


//******************************************************************* Void Draw *******************************************************************//

void draw()
{
  if(cp5.getController("Temp").getValue()==1){
    initPanelMinMaxViews("Temp");
    graphic("Température, °C", 5);
    newPointConst("25", 8); // sera remplaçé par la fonction serialEvent
  }
  if(cp5.getController("Hygro").getValue()==1){
    initPanelMinMaxViews("Hygro");
    graphic("Hygrométrie, %", 14);
    newPointConst("45", 3); // lorsque je plot l'hydro la valeur n'est pas a 45 mais a 15-16. (normalement le facteur doit etre set up a 2,8 mais il la fonction ne prend pas en charge de float pour le moment)
  }
  if(cp5.getController("Ec").getValue()==1){
    initPanelMinMaxViews("Ec");
    graphic("Ec, µS", 1);
    newPointConst("1.5", 40);
  }
  if(cp5.getController("pH").getValue()==1){
    initPanelMinMaxViews("pH");
    graphic("pH", 2);
    newPointConst("6", 20); // ajustement valeur ok mais n'accepte pas 6.3 alors que pas de problème avec 6.5
  }
  if(cp5.getController("TempSol").getValue()==1){
    initPanelMinMaxViews("TempSol");
    graphic("Température solution, °C", 5);
    newPointConst("5", 8);
  }
  
  if (cam != null) 
    {
      if (cam.available() == true)
        cam.read();

      image(cam, displayWidth - displayWidth/3 - 10, 10, displayWidth / 3, displayHeight / 3);
    }
  
}

//******************************************************************* Control Event *******************************************************************//

void controlEvent(ControlEvent theEvent) {
 if(theEvent.isController()) {
   if(theEvent.getController().getValue()!=0){
     print("control event from : "+theEvent.getController().getName());
     println(", value : "+theEvent.getController().getValue());
     
     // clicking on toggle sets toggle value to 1 (true)
     String clickedToggleName=theEvent.getController().getName();
     println("clicked toggle name :  "+clickedToggleName);
     redraw();
     if (togglesNamesList.hasValue(clickedToggleName)){
       for(int i=0; i<togglesNamesList.size(); i++){
         if(togglesNamesList.get(i)!=clickedToggleName){
           cp5.getController(togglesNamesList.get(i)).setValue(0);          
         }
       }
     }
   }
 }
}

//******************************************************************* Public Void *******************************************************************//
//basic function to get the value on the console
public void Temp(){
  if(cp5.getController("Temp").getValue()==1){
    println("temperature selectionné");
  }
}

public void Hygro(){
  if(cp5.getController("Hygro").getValue()==1){
    println("Hygrométrie selectionné");
  }
}

public void Ec(){
  if(cp5.getController("Ec").getValue()==1){
    println("Ec selectionné");
  }
}

public void pH(){
  if(cp5.getController("pH").getValue()==1){
    println("pH selectionné");
  }
}

public void TempSol(){
  if(cp5.getController("TempSol").getValue()==1){
    println("TempSol selectionné");
  }
}




/*String constSelectPrint 
public void pH(String constSelectPrint,boolean constSelect){
  println(constSelectPrint);
  if(!constSelect){
    constSelect=true;
  }else{
    constSelect=false;
  }
}*/

//******************************************************************* Camera Setup *******************************************************************//

void cameraSetup()
{
  String[] cameras = Capture.list();

  if (cameras.length == 0) 
  {
    exit();
  } else 
  {
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]); 
    cam.start();
  }
}
//******************************************************************* connection screen Setup *******************************************************************//
/*
void connectionScreenSetup()
{
  errorLabel = cp5.addTextlabel("errorLabel", "Veuillez choisir un port", 150, 134);
  errorLabel.setColorValue(color(255, 0, 0));
  errorLabel.hide();

  connectButton = cp5.addButton("Connect", 1, displayWidth / 2 - 40, 2 * displayHeight / 3, 80, 20);
  connectButton.getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

  // create a DropdownList for chossing Serial Port
  serialPortDDList = cp5.addDropdownList("portCOM_DDL")
    .setPosition(displayWidth / 2 - 100, displayHeight / 2)
      .setSize(200, 200)
        ;

  //customizeSerialDDList(serialPortDDList);
}
*/
//******************************************************************* Serial Port screen Setup *******************************************************************//

void initSelectingViews()
{
  // create a DropdownList for chossing Serial Port
  modeDDList = cp5.addDropdownList("mode_DDL")
    .setPosition(displayWidth / 40, displayHeight / 20)
      .setSize(300, 200)
        ;
  modeDDList.hide();
  //customizeModeDDList(modeDDList);
}


//******************************************************************* Main Screen Setup *******************************************************************//

void mainScreenSetup()
{
  frame.setLocation(0, 0);
  //frame.setSize(displayWidth, displayHeight); //avaible for processign 2
  surface.setSize(displayWidth, displayHeight); // avaible for processing 3
  //connectButton.hide();
  //serialPortDDList.hide();
 // modeDDList.show();
  isConnected = true;

  //myPort = new Serial(this, selectedPort, 9600);  
  //dataRead = myPort.readStringUntil(10);

  for (int i = 0; i < 5; i++)
  {
    constantLabels[i].show();
    constantNumberboxes[i].show();
  }
  thread("cameraSetup");
}

//******************************************************************* customizeSerialList Function for portCom connection*******************************************************************//
/*
void customizeSerialDDList(DropdownList ddl) 
{
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set("Port COM");
  ddl.getCaptionLabel().getStyle().marginTop = 3;
  ddl.getCaptionLabel().getStyle().marginLeft = 3;
  ddl.getValueLabel().getStyle().marginTop = 3;

  String[] serialPortList = Serial.list();
  for (int i = 0; i < serialPortList.length; i++) 
  {
    ddl.addItem(serialPortList[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
*/
//******************************************************************* customizeModeDDList Function *******************************************************************//
/*
void customizeModeDDList(DropdownList ddl)
{
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set("Chosir mode");
  ddl.getCaptionLabel().getStyle().marginTop = 3;
  ddl.getCaptionLabel().getStyle().marginLeft = 3;
  ddl.getValueLabel().getStyle().marginTop = 3;

  ddl.addItem("Mode croissance", 1);
  ddl.addItem("Mode floraison", 2);
  ddl.addItem("Mode fin de floraison", 3);

  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}
*/
//******************************************************************* Graphic Function *******************************************************************//

void graphic(String constChoice, int yValue)
{
  int j,k;
  int idealWidth = width;
  int idealHeight = height;
  int xCal = displayWidth / idealWidth;
  int yCal = displayHeight / idealHeight;
  
  int yOffset_tmp = displayHeight / 18;
  
 
  
  // set up plot construction structur variable
  // set up background square
  int xSquare = (displayWidth/2)-20;
  //print("xSquare : ", xSquare);
  int ySquare = displayHeight/2;
  //print("ySquare : ", ySquare);
  int width_square = ((displayWidth/2) - yOffset_tmp)+20;
  //print("width_square : ", width_square);
  int height_square = ((displayHeight/2-yOffset_tmp) - yOffset_tmp)+20;
  //print("height_square : ", height_square);
  int Offset = height_square / 16;
  //print("Offset = ", Offset);

  // coordonate for plot line (x and y coordonate)
  // usage : line(x1, y1, x2, y2)
  // y axis
  int xA = Offset + xSquare;
  //print("coordonées de xA", xA);
  int yA = height_square - Offset + ySquare;
  //print("coordonées de yA", yA);
  
  int xB = Offset + xSquare;
  //print("coordonées de xB", xB);
  int yB = Offset + ySquare;
  //print("coordonées de yB", yB);
  
  // x axis
  int xC = Offset + xSquare;
  //print("coordonées de xC", xC);
  int yC = height_square - Offset + ySquare;
  //print("coordonées de yC", yC);
  
  int xD = (width_square - 2*Offset) + xSquare;
  //print("coordonées de xD", xD);
  int yD = (height_square - Offset) + ySquare;
  //print("coordonées de yD", yD);
  
  // coordonate for the triangle
  // usage : triangle(x1, y1, x2, y2, x3, y3)
  // for the x axis
  int xAt = ((width_square - 2*Offset) + xSquare + Offset ) - 1/4*Offset;
  int yAt = (height_square - Offset) + ySquare;
  
  int xBt = ((width_square - 2*Offset) + xSquare);
  int yBt = (((height_square - Offset) + ySquare) - Offset) + Offset - Offset/3;
  
  int xCt = ((width_square - 2*Offset) + xSquare);
  int yCt = (((height_square - Offset) + ySquare) + Offset) - Offset + Offset/3;
  
  //for the y axis
  int xDt = ( Offset + xSquare );
  int yDt = ySquare + Offset/3;
  
  int xEt = ( Offset + xSquare ) - Offset/3;
  int yEt = Offset + ySquare;
  
  int xFt =  (Offset + xSquare ) + Offset/3;
  int yFt = (Offset + ySquare);
  
  
  // coordonate for the finest graduation of each axis
  /*
  int xAf = 
  int yAf =
  
  int xBf =
  int yBf =
  */
  // initialisation of the Offset
  
  //Affichage case pour les grahiques
  fill(255, 255, 255);
  stroke(0,0,0);
  rect(xSquare,ySquare,width_square,height_square);
  
  //affichages axes
  fill(0,0,255);
  //stroke(#0650E4);
  stroke(0,0,0);
  strokeWeight(2);
  
  //vertical (y axis)
  stroke(0,0,0);
  line (xA,yA,xB,yB);
  stroke(0,0,0);
  triangle(xDt,yDt, xEt, yEt, xFt,yFt);
  text(constChoice, (displayWidth/2)+15*xCal,(displayHeight/2)+12*yCal);
 
  //horizontal (x axis)
  stroke(0,0,0);
  line (xC,yC,xD,yD);
  stroke(0,0,0);
  triangle(xAt,yAt, xBt, yBt, xCt, yCt);
  text("Temps", xD ,yD + Offset/2 + Offset/3);
 
  //Gradations et textes tous les 5 degrés
  fill(0,0,255);
  strokeWeight(2);
  //stroke(#0650E4);
  stroke(0,0,0);
  for (int i = 0; i < 8; i++) {
      j=i*40;
      k=i*yValue;
      line(((displayWidth/2)+10)-5*xCal, yA - j, (displayWidth/2)+10*xCal,yA - j);
      text(k, ((displayWidth/2)+10)-23*xCal, yA - j);
  }
 
//Gradations fines des degrés
  strokeWeight(1);
  //stroke(#0650E4);
  stroke(0,0,0);
  for (int i = 0; i < 35; i++) {
          j=i*8;
          line(((displayWidth/2)+10)-5*xCal, yA - j, (displayWidth/2)+10*xCal,yA - j);
}
 
//Gradations des minutes
 strokeWeight(2);
 for (int i = 0; i < 10; i++) {
          j=i*60;
          line(xA + j, yA, xA + j,yA - Offset/3);
          text(i, xA + j, yA + Offset/2);
 }
 
}

//******************************************************************* New constante point for Graphic *****************************************************************//

/*************************************************************************************************************************************************************************/
// TODO : probleme avec hygrometrie, la ligne n'est pas dans le champs malgré que les coordonnées soit correctement indiquer sur le graphique
//function to mime the serialEvent
 void newPointConst(String myPort,float dataAdjustValue) {
 //set up des variables pour situer le point au nivo 0 pour chaque abscisse
 int xSquare = (displayWidth/2)-20;
 int yOffset_tmp = displayHeight / 18;
 int height_square = ((displayHeight/2-yOffset_tmp) - yOffset_tmp)+20;
 int Offset = height_square / 16;
 int xA=Offset + xSquare;
 int ySquare = displayHeight/2;
 int yA = height_square - Offset + ySquare;
 //set variable to adjust the data value related to the axis graduation
 float dataAdjust=dataAdjustValue;
 //Récupération sur le port série de la temperature sous forme de chaine de caractères
 //int idealWidth = width;
 //int idealHeight = height;
 //int xCal = displayWidth / idealWidth;
 //int yCal = displayHeight / idealHeight;
 String constCar = myPort; 
 if (constCar != null && premier == 1) {
      constCar = trim(constCar); // Suppression des blancs
      float constInt = float(constCar);
     // float constante = float (constCar);
  //    float temperature = tempInt;
      //println ("La temperature est de : " + temperature + " : " + tempInt);
      
 //Dessin graphe avec temperature actuelle -----------------------
      strokeWeight(1);
  
      //dessin du nouveau point sur la courbe
      xg0=x; // Mémorisation abscisse point précédent
      xg=xg+5; // L'Arduino envoie une nouvelle mesure de température toutes les 5 secondes
      if (xg >600) {xg=5;}
    
      yg0=yg; // Mémorisation ordonnée point précédent
      yg = constInt*dataAdjust; // Un degré correpond à 8 points sur les ordonnées
    
      if (yg > constmax*dataAdjust)  {constmax = yg/dataAdjust;} //Mise à jour temp max
      if (yg < constmini*dataAdjust) {constmini = yg/dataAdjust;} //Mise à jour temp min
    
      if (xg == 5) {   //Si on rédémarre une nouvelle courbe
        noStroke();
        fill(230);
        point(xg+xA,yg+yA);
      }
      else {
        fill(230);
        line(xg0+xA,yA - yg0,xg+xA,yA - yg);
      }

      /*textAlign(RIGHT);
      fill(#0BB305);
      text(constInt+"°C", displayWidth/2+125*xCal, displayHeight/2-20*yCal);
      fill(0,0,255);
      text(constmini+"°C", displayWidth/2+300*xCal, displayHeight/2-20*yCal);
      fill(255,0,0);
      text(constmax+"°C", displayWidth/2+500*xCal, displayHeight/2-20*yCal);
      textAlign(LEFT);*/
 }
premier = 1;
}



//******************************************************************* Real time Point Section Building ****************************************************************//


/*************************************************************************************************************************************************************************/
// start part for the live plot building *********************************************************************************************************************************
// TODO : - set-up a good offSet
//        - reShape the plot structure
//        - get the value for each data to plot
//        - create variable for each coordonate for each plot structure to improve clarity result
/*

// test 1 to integrate real data capture

//function to mime the serialEvent

 void newPointConst(String myPort) {
 //set up des variables pour situer le point au nivo 0 pour chaque abscisse
 int xSquare = (displayWidth/2)-20;
 int yOffset_tmp = displayHeight / 18;
 int height_square = ((displayHeight/2-yOffset_tmp) - yOffset_tmp)+20;
 int Offset = height_square / 16;
 int xA=Offset + xSquare;
 int ySquare = displayHeight/2;
 int yA = height_square - Offset + ySquare;
 
 //Récupération sur le port série de la temperature sous forme de chaine de caractères
 //int idealWidth = width;
 //int idealHeight = height;
 //int xCal = displayWidth / idealWidth;
 //int yCal = displayHeight / idealHeight;
 
 String constCar = myPort; //myPort.readStringUntil('\n')
 if (constCar != null && premier == 1) {
      constCar = trim(constCar); // Suppression des blancs
      int constInt = int(constCar);
      float constante = float (constCar);
  //    float temperature = tempInt;
      //println ("La temperature est de : " + temperature + " : " + tempInt);
      
 //Dessin graphe avec temperature actuelle -----------------------
      strokeWeight(1);
  
      //dessin du nouveau point sur la courbe
      xg0=x; // Mémorisation abscisse point précédent
      xg=xg+5; // L'Arduino envoie une nouvelle mesure de température toutes les 5 secondes
      if (xg >600) {xg=5;}
    
      yg0=yg; // Mémorisation ordonnée point précédent
      yg = constInt*8; // Un degré correpond à 8 points sur les ordonnées
    
      if (yg > constmax*8)  {constmax = yg/8;} //Mise à jour temp max
      if (yg < constmini*8) {constmini = yg/8;} //Mise à jour temp min
    
      if (xg == 5) {   //Si on rédémarre une nouvelle courbe
        noStroke();
        fill(230);
        point(xg+xA,yg+yA);
      }
      else {
        fill(230);
        line(xg0+xA,yA - yg0,xg+xA,yA - yg);
      }

      /*textAlign(RIGHT);
      fill(#0BB305);
      text(constInt+"°C", displayWidth/2+125*xCal, displayHeight/2-20*yCal);
      fill(0,0,255);
      text(constmini+"°C", displayWidth/2+300*xCal, displayHeight/2-20*yCal);
      fill(255,0,0);
      text(constmax+"°C", displayWidth/2+500*xCal, displayHeight/2-20*yCal);
      textAlign(LEFT);
 }
premier = 1;
}
/*

//TEST 1//

//function to mime the serialEvent
 void newPointConst(String myPort) {
   
 // myPort = new Serial(this, Serial.list()[0], 9600);
 // myPort.bufferUntil('\n');
   
//set up des variables pour situer le point au nivo 0 pour chaque abscisse
 int xSquare = (displayWidth/2)-20;
 int yOffset_tmp = displayHeight / 18;
 int height_square = ((displayHeight/2-yOffset_tmp) - yOffset_tmp)+20;
 int Offset = height_square / 16;
 int xA=Offset + xSquare;
 int ySquare = displayHeight/2;
 int yA = height_square - Offset + ySquare;
 
 int xPos = xA;

 void serialEvent (Serial myPort) {
 // get the ASCII string:
 String inString = myPort.readStringUntil('\n');
 
 if (inString != null) {
 // trim off any whitespace:
 
 print("Temperature: ");
 print(inString);
 println("Degree Celcius");
 inString = trim(inString);
 
 // convert to an int and map to the screen height:
 float inByte = float(inString+(char)9); 
 inByte = map(inByte, 0,117, 0, height);
 
 println(inByte);

// draw the line:
 int shift=xA;            // set trace origin //origine du graphe 
 stroke(255,0,0);              // trace colour
 for(int i=0;i<2;i++)
 {
// line(xPos, height-inByte-1, xPos, height - inByte);
   line(xPos, height-inByte-(shift+2), xPos, height-inByte-shift);
   xPos++;
 }
 if (xPos >= width)         //  go back to begining
 {
 xPos = xA;
 background(100); 
 }
 }
}
  
    
     
*/
 
 // TEST 2 - With the function used by the graphic of the mime of the cseriallEvent
 // function to have a real time point of each constante in the graphic
 
 //Traitements à réception d'une fin de ligne
 void serialEvent (Serial monPort) {
 
 //Initialisation des variables d'entrées pour l'acquésition de données température
 int x0=0;
 int y0=0;
//TODO: trouver un moyen de récupérer la valeur max envoyé par l'arduino dans la liste des temperatures enregistrer dans la journée...
 int tempmini=0;         //Temperature mini mesurée par l'Arduino
 int tempmax=0;          //Temperature maxi mesurée par l'Arduino
 
 //Récupération sur le port série de la temperature sous forme de chaine de caractères
 String tempcar = monPort.readStringUntil('\n');
 
 // TODO : add command to get all the constantes in differente variable
 // Create a function which get the constante value when it is selected by the correspondante select box
 
 
 if (tempcar != null && premier == 1) {
      tempcar = trim(tempcar); // Suppression des blancs
      int tempInt = int(tempcar);
      float temperature = float (tempcar);
  //    float temperature = tempInt;
      println("La temperature est de : " + temperature + " : " + tempInt);
 
      //Dessin graphe avec temperature actuelle -----------------------
      stroke (0,255,0);
      strokeWeight(1);
  
      //dessin du nouveau point sur la courbe
      x0=x; // Mémorisation abscisse point précédent
      x=x+5; // L'Arduino envoie une nouvelle mesure de température toutes les 5 secondes
      if (x >600) {x=5;}
    
      y0=y; // Mémorisation ordonnée point précédent
      y = tempInt*8; // Un degré correpond à 8 points sur les ordonnées // TODO verifier si cela est vrai sur notre graphique
    
      if (y > tempmax*8)  {tempmax = y/8;} //Mise à jour temp max
      if (y < tempmini*8) {tempmini = y/8;} //Mise à jour temp min
    
      if (x == 5) {   //Si on rédémarre une nouvelle courbe
        noStroke();
        fill(230);
        rect(291,65,655,410); //Effacement courbe précédente
        point(x+287,475-y);
      }
      else {
        line(x0+287,475-y0,x+286,475-y);
      }
      
      //Affichage des températures ----------------
    
      //Dessin des cadres -------------------------
      stroke(0);
      strokeWeight(1);
      fill(230);
     
    
      //Dessin temperature actuelle -----------------------
      noStroke();
      fill(#0BB305);
      rect(105,475-temperature*8,10,temperature*8+5);
      fill(#08F500);
      rect(110,480-temperature*8,3,temperature*8-5);
    
    
   }
   premier = 1;
 }
     
/*************************************************************************************************************************************************************************/
     
//******************************************************************* Panel Min - Max View *******************************************************************//     
     
  void initPanelMinMaxViews(String constChoiceBis)
{
  //int yOffset = displayHeight / 18;
  //String currentControllerName = cp5.getController(constantLabelsPanelNamesList[1]).getName()
  if(cp5.getController(constChoiceBis).getValue()==1){
  background(215);
  cp5.getController(constantLabelsPanelNamesList.get(0)).setValueLabel(constChoiceBis + " mini :");
  cp5.getController(constantLabelsPanelNamesList.get(1)).setValueLabel(constChoiceBis+ " max :");
  }
}

//******************************************************************* Init Constant View *******************************************************************//

  void initConstantViews()
{
  int yOffset = displayHeight / 18;
  //Calibrate the object related to the laptop screen size
  //int idealWidth = width;
  //int idealHeight = height;
  //int xCalbis = displayWidth / idealWidth;
  //int yCalbis = displayHeight / idealHeight;
  constantLabels = new Textlabel[5];
  constantNumberboxes = new Numberbox[7];
  constantSlider = new Slider[1];
  constantPanelLabels = new Textlabel[2];
  
  
  constantSlider[0] = cp5.addSlider(" Power lighting").setRange(0,100).setValue(0).setPosition(10, displayHeight / 2 + 5 * yOffset + yOffset / 4).setSize(100,10);
  //constantSlider[0] = cp5.addSlider(" Power lighting").setRange(0,100).setValue(0).setPosition(10, displayHeight / 2 + 5 * yOffset + yOffset / 4).setSize(100,10);

  constantLabels[0] = cp5.addTextlabel("tempLabel", "TEMPERATURE", 10, displayHeight / 2 + yOffset / 4);
  constantLabels[1] = cp5.addTextlabel("hydroLabel", "HYDROMETRIE", 10, displayHeight / 2 + 1 * yOffset + yOffset / 4);
  constantLabels[2] = cp5.addTextlabel("phLabel", "pH", 10, displayHeight / 2 + 2 * yOffset + yOffset / 4);
  constantLabels[3] = cp5.addTextlabel("ecLabel", "Ec", 10, displayHeight / 2 + 3 * yOffset + yOffset / 4);
  constantLabels[4] = cp5.addTextlabel("co2Label", "CO2", 10, displayHeight / 2 + 4 * yOffset + yOffset / 4);
  //constantLabels[5] = cp5.addTextlabel("tempMinLabel", constChoiceBis + " mini :",displayWidth/2+200*xCalbis, displayHeight/2-20*yCalbis);
  //constantLabels[6] = cp5.addTextlabel("tempMaxLabel", constChoiceBis + " max :",displayWidth/2+400*xCalbis, displayHeight/2-20*yCalbis);

  constantNumberboxes[0] = cp5.addNumberbox("tempNumberbox", 100, displayHeight / 2 + yOffset / 4, 40, 14);
  constantNumberboxes[1] = cp5.addNumberbox("hydroNumberbox", 100, displayHeight / 2 + 1 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[2] = cp5.addNumberbox("phNumberbox", 100, displayHeight / 2 + 2 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[3] = cp5.addNumberbox("ecNumberbox", 100, displayHeight / 2 + 3 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[4] = cp5.addNumberbox("co2Numberbox", 100, displayHeight / 2 + 4 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[5] = cp5.addNumberbox("  ").setValue(0).setPosition(displayWidth/2+100,displayHeight / 2 - 1 * yOffset + yOffset / 4);
  constantNumberboxes[6] = cp5.addNumberbox("").setValue(0).setPosition(displayWidth/2+300, displayHeight / 2 - 1 * yOffset + yOffset / 4);
  
  constantPanelLabels[0] = cp5.addTextlabel("tempMinLabel").setValueLabel(" mini :").setPosition(displayWidth/2,displayHeight / 2 - 1 * yOffset + yOffset / 4);
  constantPanelLabels[1] = cp5.addTextlabel("tempMaxLabel").setValueLabel(" max :").setPosition(displayWidth/2+200,displayHeight / 2 - 1 * yOffset + yOffset / 4);


//******************************************************************* first Screen Before Conection ******************************************************************//

//Don't put this code if you have not automate connected to the pc
  for (int i = 0; i < 5; i++)
  {
    // Dont display the name for controllers
    constantNumberboxes[i].getCaptionLabel().setVisible(false);
    constantLabels[i].hide();
    constantNumberboxes[i].hide();
    constantNumberboxes[i].lock();
  }
}
 
 
 //******************************************************************* control hardware ******************************************************************//
 /*
 // créer des test si allumé ou éteint renvoyé on ou off pour chaque appareils connecter
 if (){
   
 }
 
 */
 
 // test with firmata library 
 //println(Arduino.list()); // to see how the list is build

// function pour afficher l'état on off des hardware connecté a l'arduino
//println(arduino.digitalRead(extracteur));

  for (int i = 0; i <= 5; i++)
    arduino.pinMode(i, Arduino.INPUT);

void hardwareTest(){
  color off = color(4, 79, 111);
  color on = color(84, 145, 158);
  
  background(off);
  stroke(on);
  
  for (int i = 0; i <= 13; i++) {
    if (values[i] == Arduino.HIGH)
      fill(on);
    else
      fill(off);
      
    rect(420 - i * 30, 30, 20, 20);
  }
}


 
