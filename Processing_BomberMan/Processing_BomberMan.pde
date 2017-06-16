import java.util.*;


Controls gCtrl;
GLC Glc; // variable générale
SOUND_MANAGER gSound;
int gSketchScale = 3;
boolean gDebug;
Rect ScreenRect;
PImage buffer;
PFont fontMM,DefaultFont,HeartFont;

void settings() {
  int xSize = 272 ; // 17 blocks de 16px
  int ySize = 208 ; // 13 blocks de 16px
  ScreenRect = new Rect(0, 0, xSize, ySize);
  buffer = createImage(xSize, ySize, RGB);
  
  size(xSize* gSketchScale, ySize *gSketchScale); // taille de la fenetre
  noSmooth();
  gDebug = false;
}




void setup() {
  prepareExitHandler();
  noFill();
  fontMM = createFont("Boxy-Bold.ttf", 36);
  HeartFont = createFont("MWHeart.ttf", 70);
  DefaultFont = createFont("Georgia", 32);
  
  
  //textFont(fontMM);
  gSound = new SOUND_MANAGER();
  gCtrl = new Controls();
  String[] lvls = new String[]{ "LEVEL_1.csv",  "LEVEL_2.csv", "LEVEL_3.csv"};
  Glc = new GLC("bomber_man_tilemap.png", lvls);
  
}




void draw() {
  gCtrl.stepFrame();
  gSound.stepFrame();
  Glc.stepFrame();
  //Glc.GameLogicFrameUpdate(); 
  
  // popMatrix();
  if (gDebug) {
    fill(255);
    textFont(DefaultFont);
    scale(1);
    text("FPS : "  + round(frameRate), 80, 30);
    //textFont(fontMM);
    noFill();
    //text("NIVEAU 1", (ScreenRect.w * gSketchScale)/2,340);
  }  
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