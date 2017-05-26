import java.util.*;


Controls gCtrl;
GLC Glc; // variable générale

int gSketchScale = 3;
boolean gDebug;
Rect ScreenRect;


void settings() {
  int xSize = 272 ; // 17 blocks de 16px
  int ySize = 208 ; // 13 blocks de 16px
  ScreenRect = new Rect(0, 0, xSize, ySize);
  size(xSize* gSketchScale, ySize *gSketchScale); // taille de la fenetre
  noSmooth();
  gDebug = true;
  
}

void stop() {
  // soundBank.clear();
  println("stop");
}


void setup() {
  prepareExitHandler();
  noFill();
  populateSoundBank();
  gCtrl = new Controls();

  Glc = new GLC("bomber_man_tilemap.png", "LEVEL_1.csv");
}




void draw() {
  pushMatrix();
  scale(gSketchScale);
  rect(10, 10, 50, 50);
  gCtrl.stepFrame();
  Glc.GameLogicFrameUpdate();  

  if (gDebug) {
    text("FPS : "  + round(frameRate), 10, 20);
  }
  popMatrix();
}


private void prepareExitHandler() {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {

    public void run () {
      soundBank.clear();
      System.out.println("SHUTDOWN HOOK");

      // application exit code here
    }
  }
  ));
}