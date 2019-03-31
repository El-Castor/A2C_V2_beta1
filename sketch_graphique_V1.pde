import controlP5.*;
ControlP5 cp5;

//initiatlisations des variables*******************************************************************
Serial myPort;  //Déclaration port série pour la lecture des données envoyées par l'Arduino
int mesure;      //Mesure lue sur le port 

int x = displayWidth/2;
int y = displayHeight/2;
int j,k;
int yOffset = displayHeight / 18;

float w = 30;
float h = 30;
boolean t=false;
boolean hy=false;
boolean e=false;
boolean p=false;
boolean s=false;

int m;                   //Indice de travail
int kn;                   //Indice de travail
int xg=0;                 //Abcisse
int xg0=0;                //Abcisse précédente
int yg=0;                 //Ordonnée
int yg0;                  //Ordonnée précédente

int premier = 0;         // Bypass premiere valeur erronée

void setup()
{

 size(displayWidth,displayHeight);
  
 
 cp5= new ControlP5(this);
 cp5.addToggle("TempSol").setValue(0).setPosition(800,700).setSize(50,25).setState(false);
 cp5.addToggle("Temp").setValue(0).setPosition(800,700).setSize(50,25).setState(false);
 cp5.addToggle("Hygro").setValue(0).setPosition(800,600).setSize(50,25).setState(false);
 cp5.addToggle("pH").setValue(0).setPosition(800,800).setSize(50,25).setState(false);
 cp5.addToggle("Ec").setValue(0).setPosition(800,900).setSize(50,25).setState(false);
 
}

void draw()
{
  if(t){
    graphic("Température, °C", 5);
  }
  if(hy){
    graphic("Hygrométrie, %", 10);
  }
  if(e){
    graphic("Ec, µS", 1);
  }
  if(p){
    graphic("pH", 14);
  }
  if(s){
    graphic("Température solution, °C", 5);
  }
}
/*
void controlEvent(ControlEvent theEvent) {
 if(theEvent.isController()) {
 print("control event from : "+theEvent.getController().getName());
 println(", value : "+theEvent.getController().getValue());
 
 // clicking on toggle sets toggle value to 1 (true) 
 if(theEvent.getController().getName()=="Temp") {
 cp5.getController("Temp").setValue(1);
 cp5.getController("Hygro").setValue(0);
 }
 if(theEvent.getController().getName()=="Hygro") {
 cp5.getController("Hygro").setValue(1);
 cp5.getController("Temp").setValue(0);
 }
 if(theEvent.getController().getName()=="pH") {
 cp5.getController("pH").setValue(1);
 }
 if(theEvent.getController().getName()=="Ec") {
 cp5.getController("Ec").setValue(1);
 }
}
}*/

public void Temp(){
  println("temperature selectionné");
  if(!t){
    t=true;
  }else{
    t=false;
  }
}

public void Hygro(){
  println("Hygrométrie selectionné");
  if(!hy && !t){
    hy=true;
  }else{
    hy=false;
  }
  
}

public void Ec(){
  println("Ec selectionné");
  if(!e){
    e=true;
  }else{
    e=false;
  }
}

public void pH(){
  println("pH selectionné");
  if(!p){
    p=true;
  }else{
    p=false;
  }
}

public void TempSol(){
  println("Température solution selectionné");
  if(!s){
    s=true;
  }else{
    s=false;
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

void graphic(String constChoice, int yValue)
{
  int x = displayWidth/2;
  int y = displayHeight/2;
  int j,k;
  int yOffset = displayHeight / 18;
  //Affichage case pour les grahiques
  fill(255, 255, 255);
  rect((displayWidth/2)-20,displayHeight/2,((displayWidth/2) - yOffset)+20,((displayHeight/2-yOffset) - yOffset)+20);
  
  
  //affichages axes
  fill(0,0,255);
  stroke(#0650E4);
  strokeWeight(2);
  
  //horizontal
  line ((displayWidth/2)+10,(displayHeight/2)+6,(displayWidth/2)+10,(displayWidth/2) -10);
  triangle(((displayWidth/2)+5), (displayHeight/2)+10, (displayWidth/2)+10, (displayHeight/2)+2, (displayWidth/2)+15,(displayHeight/2)+10 );
  text(constChoice, (displayWidth/2)+15,(displayHeight/2)+12);
 
  //vertical
  line ((displayWidth/2)+10,(displayWidth/2)-10,(displayWidth-yOffset)-10,(displayWidth/2)-10);
  triangle(((displayWidth/2)+(displayWidth/2-yOffset))-15,(displayWidth/2)-15, ((displayWidth/2)+(displayWidth/2-yOffset))-15,(displayWidth/2) -6, (displayWidth-yOffset)-5, (displayWidth/2)-10);
  text("Temps", ((displayWidth/2)+(displayWidth/2-yOffset))-40,(displayWidth/2)-20);
 
  //Gradations et textes tous les 5 degrés
  fill(0,0,255);
  strokeWeight(2);
  stroke(#0650E4);
  for (int i = 0; i < 11; i++) {
      j=i*40;
      k=i*yValue;
      line(((displayWidth/2)+10)-5, (displayWidth/2)-10-j, (displayWidth/2)+10,(displayWidth/2)-10-j);
      text(k, ((displayWidth/2)+10)-23, (displayWidth/2)-8-j);
  }
 
//Gradations fines des degrés
  strokeWeight(1);
  stroke(#0650E4);
  for (int i = 0; i < 50; i++) {
          j=i*8;
          line(((displayWidth/2)+10)-5, (displayWidth/2)-10-j, (displayWidth/2)+10,(displayWidth/2)-10-j);
}
 
//Gradations des minutes
 strokeWeight(2);
 for (int i = 0; i < 15; i++) {
          j=i*60;
          line(((displayWidth/2)+10)+j, (displayWidth/2)-3, ((displayWidth/2)+10)+j,((displayWidth/2)-8));
          text(i, ((displayWidth/2)+7)+j, ((displayWidth/2)+10));
 }
}


//Recuperation des données envoyé par le arduino/******************************************************************************

//Traitements à réception d'une fin de ligne
 void serialEvent (Serial myPort) {
 
 //Récupération sur le port série de la temperature sous forme de chaine de caractères
 String tempcar = myPort.readStringUntil('\n');
 if (tempcar != null && premier == 1) {
      tempcar = trim(tempcar); // Suppression des blancs
      int tempInt = int(tempcar);
      float temperature = float (tempcar);
  //    float temperature = tempInt;
      println ("La temperature est de : " + temperature + " : " + tempInt);
      
 //Dessin graphe avec temperature actuelle -----------------------
      stroke (0,255,0);
      strokeWeight(1);
  
      //dessin du nouveau point sur la courbe
      xg0=x; // Mémorisation abscisse point précédent
      xg=xg+5; // L'Arduino envoie une nouvelle mesure de température toutes les 5 secondes
      if (xg >600) {xg=5;}
    
      yg0=yg; // Mémorisation ordonnée point précédent
      yg = tempInt*8; // Un degré correpond à 8 points sur les ordonnées
    
      if (yg > tempmax*8)  {tempmax = yg/8;} //Mise à jour temp max
      if (yg < tempmini*8) {tempmini = yg/8;} //Mise à jour temp min
    
      if (xg == 5) {   //Si on rédémarre une nouvelle courbe
        noStroke();
        fill(255, 255, 255);
        rect((displayWidth/2)-20,displayHeight/2,((displayWidth/2) - yOffset)+20,((displayHeight/2-yOffset) - yOffset)+20); //Effacement courbe précédente
        point(x+(((displayWidth/2)+10)-5)+2,((displayWidth/2)-10)-y);
      }
      else {
        line(x0+(((displayWidth/2)+10)-5)+2,((displayWidth/2)-10)-y0,x+(((displayWidth/2)+10)-5)+1,((displayWidth/2)-10)-y);
      }
 
 }
premier = 1;
}
