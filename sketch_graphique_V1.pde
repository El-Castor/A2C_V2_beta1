import controlP5.*;
ControlP5 cp5;

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

void setup()
{

 size(displayWidth,displayHeight);
  
 
 cp5= new ControlP5(this);
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
  //Affichage case pur les grahiques
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
