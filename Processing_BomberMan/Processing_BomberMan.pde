import java.util.*;

Controls gCtrl;
GLC Glc; // variable générale

int gSketchScale = 3;
boolean gDebug;
Rect ScreenRect;

void settings() {
  int xSize = 272 ; // 17 blocks de 16px
  int ySize = 208 ; // 13 blocks de 16px
  ScreenRect = new Rect(0,0,xSize,ySize);
  size(xSize* gSketchScale, ySize *gSketchScale); // taille de la fenetre
  noSmooth();
  gDebug = false;
}

void setup() {
  noFill();
  gCtrl = new Controls();
  Glc = new GLC("bomber_man_tilemap.png", "LEVEL_1.csv");
  
  //gMap = new Map("bomber_man_tilemap.png", 16, 101, "BomberMan_Editeur_de_niveau.csv");
  //gBM = new BomberMan("bomber_man_tilemap.png",94);
  //gBM.SetPlayerControl(true);
}



void draw() {
  pushMatrix();
   scale(gSketchScale);
   rect(10,10,50,50);
  Glc.GameLogicFrameUpdate();  //<>// //<>//
  //gMap.UpdateDisplay();
  // gBM.actionUpdate();
  
  if (gDebug) {
    text("FPS : "  + round(frameRate), 10, 20);
  }
  popMatrix();
}