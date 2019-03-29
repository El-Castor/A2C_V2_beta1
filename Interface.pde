
/**
 * Control5 DropdownList
 * A dropdownList controller, extends the ListBox controller.
 * the most recently selected dropdownlist item is displayed inside
 * the menu bar of the DropdownList.
 *
 * find a list of public methods available for the DropdownList Controller 
 * at the bottom of this sketch's source code
 *
 *
 * by andreas schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 */

import processing.serial.*;
import controlP5.*;
import processing.video.*;

// Serial variables
Serial myPort;  // Create object from Serial class
String dataRead = null;

// Data received from the serial port
String temperature = "0"; 
String humidity = "0";
String phValue = "0";
String ecValue = "0";

boolean firstContact = false;

// GUI elements
ControlP5 cp5;
DropdownList serialPortDDList;
DropdownList modeDDList;
Button connectButton;
Textlabel errorLabel;
Textlabel[] constantLabels;
Numberbox[] constantNumberboxes;

// Video elements
Capture cam;

// Boolean variables
boolean isConnected;

// Data variables
String selectedPort;

// Run the app in fullscreen mode
boolean sketchFullScreen() 
{
  return true;
}

//initialisation variable pour le graphique de suivi des constantes

int temperature=25;      //Temperature mesurée par l'Arduino
int tempmini=34;         //Temperature mini mesurée par l'Arduino
int tempmax=12;          //Temperature maxi mesurée par l'Arduino
int j;                   //Indice de travail
int k;                   //Indice de travail
int x=0;                 //Abcisse
int x0=0;                //Abcisse précédente
int y=0;                 //Ordonnée
int y0;                  //Ordonnée précédente
int premier = 0;         // Bypass premiere valeur erronée


void setup() 
{
  size(displayWidth, displayHeight);

  if (frame != null) {
    frame.setResizable(true);
  }

  cp5 = new ControlP5(this);
  isConnected = false;

  connectionScreenSetup();
  initConstantViews();
  initSelectingViews();
}

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

  customizeSerialDDList(serialPortDDList);
}

void mainScreenSetup()
{
  //frame.setLocation(0, 0);
  //frame.setSize(displayWidth, displayHeight);
  connectButton.hide();
  serialPortDDList.hide();
  modeDDList.show();
  isConnected = true;

  myPort = new Serial(this, selectedPort, 9600);  
  dataRead = myPort.readStringUntil(10);

  for (int i = 0; i < 5; i++)
  {
    constantLabels[i].show();
    constantNumberboxes[i].show();
  }
  thread("cameraSetup");
}

void customizeSerialDDList(DropdownList ddl) 
{
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("Port COM");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;

  String[] serialPortList = Serial.list();
  for (int i = 0; i < serialPortList.length; i++) 
  {
    ddl.addItem(serialPortList[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void customizeModeDDList(DropdownList ddl)
{
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("Chosir mode");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;

  ddl.addItem("Mode croissance", 1);
  ddl.addItem("Mode floraison", 2);
  ddl.addItem("Mode fin de floraison", 3);

  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void initSelectingViews()
{
  // create a DropdownList for chossing Serial Port
  modeDDList = cp5.addDropdownList("mode_DDL")
    .setPosition(displayWidth / 40, displayHeight / 20)
      .setSize(300, 200)
        ;
  modeDDList.hide();
  customizeModeDDList(modeDDList);
}

void initConstantViews()
{
  int yOffset = displayHeight / 18;
  constantLabels = new Textlabel[5];
  constantNumberboxes = new Numberbox[5];

  constantLabels[0] = cp5.addTextlabel("tempLabel", "TEMPERATURE", 10, displayHeight / 2 + yOffset / 4);
  constantLabels[1] = cp5.addTextlabel("hydroLabel", "HYDROMETRIE", 10, displayHeight / 2 + 1 * yOffset + yOffset / 4);
  constantLabels[2] = cp5.addTextlabel("phLabel", "pH", 10, displayHeight / 2 + 2 * yOffset + yOffset / 4);
  constantLabels[3] = cp5.addTextlabel("ecLabel", "Ec", 10, displayHeight / 2 + 3 * yOffset + yOffset / 4);
  constantLabels[4] = cp5.addTextlabel("co2Label", "CO2", 10, displayHeight / 2 + 4 * yOffset + yOffset / 4);

  constantNumberboxes[0] = cp5.addNumberbox("tempNumberbox", 100, displayHeight / 2 + yOffset / 4, 40, 14);
  constantNumberboxes[1] = cp5.addNumberbox("hydroNumberbox", 100, displayHeight / 2 + 1 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[2] = cp5.addNumberbox("phNumberbox", 100, displayHeight / 2 + 2 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[3] = cp5.addNumberbox("ecNumberbox", 100, displayHeight / 2 + 3 * yOffset + yOffset / 4, 40, 14);
  constantNumberboxes[4] = cp5.addNumberbox("co2Numberbox", 100, displayHeight / 2 + 4 * yOffset + yOffset / 4, 40, 14);

  for (int i = 0; i < 5; i++)
  {
    // Dont display the name for controllers
    constantNumberboxes[i].getCaptionLabel().setVisible(false);
    constantLabels[i].hide();
    constantNumberboxes[i].hide();
    constantNumberboxes[i].lock();
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isGroup())
  {
    if (theEvent.getGroup().getName() == "portCOM_DDL")
    {
      errorLabel.hide();
      float eventValue = theEvent.getGroup().getValue();
      String[] serialPortList = Serial.list();
      selectedPort = serialPortList[(int)eventValue];
    } else if (theEvent.getGroup().getName() == "mode_DDL")
    {
      float eventValue = theEvent.getGroup().getValue();
      myPort.write((int)eventValue);
      println("New mode: ", (int)eventValue);
    }
  } else if (theEvent.isController()) 
  {
    if (theEvent.controller().name()=="Connect")
    {
      if (selectedPort != null) 
      {
        mainScreenSetup();
      } else
      {
        errorLabel.show();
      }
    }
  }
}

void serialEvent(Serial myPort) 
{
  dataRead = myPort.readStringUntil('\n');


  if (dataRead != null)
  {
    dataRead = trim(dataRead);
    println(dataRead);

    String[] dataBlocks = split(dataRead, ",");

    if (dataBlocks[0] != null)
    {
      temperature = dataBlocks[0];
    }
    if (dataBlocks[1] != null)
    {
      humidity = dataBlocks[1];
    }
    if (dataBlocks[2] != null)
    {
      phValue = dataBlocks[2];
    }
    
    if (temperature != null & humidity != null)
    {
      constantNumberboxes[0].setValue(float(temperature));
      constantNumberboxes[1].setValue(float(humidity));
      constantNumberboxes[2].setValue(float(phValue));
    }
  }
}

void draw() 
{
  background(128);

  if (isConnected == true) 
  {
    line(0, displayHeight/2, displayWidth, displayHeight/2);
    stroke(160);

    if (cam != null) 
    {
      if (cam.available() == true)
        cam.read();

      image(cam, displayWidth - displayWidth/3 - 10, 10, displayWidth / 3, displayHeight / 3);
    }
  }
}
