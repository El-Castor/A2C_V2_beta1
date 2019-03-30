import controlP5.*;
ControlP5 cp5;

int x = displayWidth/2;
int y = displayHeight/2;
int j,k;
int yOffset = displayHeight / 18;

float w = 30;
float h = 30;
boolean t=false;
boolean p=false;

void setup()
{

 size(displayWidth,displayHeight);
  
 
 cp5= new ControlP5(this);
 cp5.addButton("Temp").setPosition(800,700).setSize(100,50);
 cp5.addButton("Hygro").setPosition(800,600).setSize(100,50);
 
}

void draw()
{
  if(t){
    
    graphicTemp();
  }
  if(p){
    graphicHygro();
  }

}

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
  if(!p && !t){
    p=true;
  }else{
    p=false;
  }
  
}

void graphicTemp()
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
  text("Température (°C)", (displayWidth/2)+15,(displayHeight/2)+12);
 
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
      k=i*5;
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

void graphicHygro()
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
  text("Hygrometrie (%)", (displayWidth/2)+15,(displayHeight/2)+12);
 
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
      k=i*5;
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
