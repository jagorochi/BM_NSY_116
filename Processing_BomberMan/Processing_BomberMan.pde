import java.util.Arrays;
import java.util.EnumMap;

Controls gCtrl;

int gSketchScale = 2;
boolean gDebug;
Map gMap;
BomberMan gBM;

void config(){
  
}
void settings(){
    int xSize = 480 * gSketchScale;
    int ySize = 240 * gSketchScale;
    size(xSize, ySize); // taille de la fenetre
    noSmooth();
    gDebug = true;
    
}

void setup() {
  gCtrl = new Controls();
  gMap = new Map("bomber_man_tilemap.png", 16, 101, "BomberMan_Editeur_de_niveau.csv");
  gBM = new BomberMan("bomber_man_tilemap.png",94);
  gBM.SetPlayerControl(true);
}



void draw() {
  
  gMap.UpdateDisplay();
  gBM.displayUpdate();
   if (gDebug){
    text("fps : "  + round(frameRate), 10,20);
  }
}