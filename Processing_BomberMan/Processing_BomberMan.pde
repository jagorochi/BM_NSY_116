import java.util.Arrays;
Controls gCtrl;
int gFrameCounter = 0;
Map gMap;

void setup() {

  frameRate(60);
  size(480, 240); // taille de la fenetre
  gCtrl = new Controls();

  gMap = new Map("bomber_man_tilemap.png", 16, 101, "BomberMan_Editeur_de_niveau.csv");
  // gMap.display();

  //test();
}



void draw() {
  gFrameCounter++;
  if (gFrameCounter % 60 == 0){e
    println(frameRate);
  }
  gMap.UpdateDisplay();
}