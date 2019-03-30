void setup()
{
  
  int yOffset = displayHeight / 18;
  size(displayWidth,displayHeight);
  
  //Affichage case pur les grahiques
  rect(displayWidth/2,displayHeight/2,(displayWidth/2) - yOffset,(displayHeight/2-yOffset) - yOffset);
  
  //affichages axes
 fill(0,0,255);
 stroke(#0650E4);
 strokeWeight(2);
  
 //horizontal
 line (290,475,960,475);
 triangle(960, 475, 950, 480, 950, 470);
 text("Température (°C)", 250, 40);
 
 //vertical
 line (290,475,290,50);
 triangle(290, 50, 295, 60, 285, 60);
 text("Temps", 910, 510);
  
  
  
}
