import java.util.Arrays;
import java.util.EnumMap;

Controls gCtrl;
GLC Controller;

int gSketchScale = 2;
boolean gDebug;
//Map gMap;
//BomberMan gBM;

void config() {
}
void settings() {
  int xSize = 480 * gSketchScale;
  int ySize = 240 * gSketchScale;
  size(xSize, ySize); // taille de la fenetre
  noSmooth();
  
  gDebug = false;
}

void setup() {
  noFill();
  gCtrl = new Controls();
  Controller = new GLC("bomber_man_tilemap.png", "BomberMan_Editeur_de_niveau.csv");

  //gMap = new Map("bomber_man_tilemap.png", 16, 101, "BomberMan_Editeur_de_niveau.csv");
  //gBM = new BomberMan("bomber_man_tilemap.png",94);
  //gBM.SetPlayerControl(true);
}



void draw() {
  Controller.GameLogicFrameUpdate();
  //gMap.UpdateDisplay();
  // gBM.actionUpdate();

  if (gDebug) {
    text("FPS : "  + round(frameRate), 10, 20);
  }
}