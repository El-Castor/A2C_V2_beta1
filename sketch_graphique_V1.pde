 int yOffset = displayHeight / 18;
  size(displayWidth,displayHeight);
  
  //Affichage case pur les grahiques
  rect(displayWidth/2,displayHeight/2,(displayWidth/2) - yOffset,(displayHeight/2-yOffset) - yOffset);
  
  //affichages axes
 fill(0,0,255);
 stroke(#0650E4);
 strokeWeight(2);
  
 //horizontal
 line ((displayWidth/2)+10,(displayHeight/2)+6,(displayWidth/2)+10,(displayWidth/2) -10);
 triangle(((displayWidth/2)+10)-2, (displayHeight/2)+6, (displayWidth/2)+15, (displayHeight/2)-9, (displayWidth/2)+20,(displayHeight/2)+6 );
 text("Température (°C)", 250, 40);
 
 //vertical
 line ((displayWidth/2)+10,(displayWidth/2)-10,(displayWidth-yOffset)-10,(displayWidth/2)-10);
 triangle(290, 50, 295, 60, 285, 60);
 text("Temps", 910, 510);
