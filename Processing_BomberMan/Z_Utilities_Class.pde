enum CHARACTER_ACTION {
  LOOK_FRONT_WAIT, LOOK_LEFT_WAIT, LOOK_RIGHT_WAIT, LOOK_UP_WAIT, 
    LOOK_DOWN_WALK, LOOK_LEFT_WALK, LOOK_RIGHT_WALK, LOOK_UP_WALK, 
    LOOK_FRONT_CARRY_WAIT, LOOK_LEFT_CARRY_WAIT, LOOK_RIGHT_CARRY_WAIT, LOOK_UP_CARRY_WAIT, 
    LOOK_FRONT_CARRY_WALK, LOOK_LEFT_CARRY_WALK, LOOK_RIGHT_CARRY_WALK, LOOK_UP_CARRY_WALK, 
    LOOK_FRONT_THROW, LOOK_LEFT_THROW, LOOK_RIGHT_THROW, LOOK_UP_THROW, 
    DIE, VICTORY, GROUND_APPEAR, GROUND_DISAPPEAR, TINY_DISAPPEAR, VOID;
  public static int COUNT = CHARACTER_ACTION.values().length;
}

enum DIRECTION {
  UP, LEFT, RIGHT, DOWN, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT;
}

enum BOMB_OBJECT {
  SPAWN;
}

public class Rect {
  int x;
  int y;
  int w;
  int h;
  public Rect(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
}

class Sprite {
  int TileID;
  int xDecal;
  int yDecal;
  int duration;


  public Sprite(int TileID, int xDecal, int yDecal, int duration) {
    this.TileID = TileID;
    this.xDecal = xDecal;
    this.yDecal = yDecal;
    this.duration = duration;
  }

  public Sprite (int TileID) {
    this.TileID = TileID;
    xDecal = 0;
    yDecal = 0;
    duration = 60;
  }
  
  public Sprite (int TileID, int duration) {
    this.TileID = TileID;
    xDecal = 0;
    yDecal = 0;
    this.duration = duration;
  }
}

class SpriteAnimation {

  int FrameLoop = 0;
  int MaxFrame = 0;
  int[] framesPos;
  ArrayList<Sprite> sprites = new ArrayList<Sprite>();

  private void setFrameLoop(int nSprite) { // défaut : boucle de la dernière vers la première
    if (nSprite == 0) {
      FrameLoop = 0;
    } else {
      if (MaxFrame == 0) {
        rebuildFramesTiming();
      }
      FrameLoop = framesPos[nSprite];
    }
  }

  private void rebuildFramesTiming() {
    framesPos = new int[sprites.size()];
    Sprite s;
    for (int incr = 0; incr < sprites.size(); incr++) {
      s = sprites.get(incr);
      framesPos[incr] = s.duration + MaxFrame;
      MaxFrame += s.duration;
    }
  }

  private void addSprite(Sprite s) {
    sprites.add(s);
  }
}
// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------
// variable d'état des controles (fleches du pavé numérique)
// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------
public class Controls {
  public  boolean left = false;
  public  boolean right = false;
  public  boolean up = false;
  public  boolean down = false;
  public  boolean a = false;
  public  boolean b = false;
  public  boolean c = false;

  public void keyPressed() {
    if (keyCode == DOWN) {
      down = true;
    }
    if (keyCode == UP) {
      up = true;
    }
    if (keyCode == LEFT) {
      left = true;
    }
    if (keyCode == RIGHT) {
      right = true;
    }
    if (keyCode == 65 || keyCode == 97) {
      a = true;
    }
    if (keyCode == 90 || keyCode == 122) {
      b = true;
    }
    if (keyCode == 69 || keyCode == 101) {
      b = true;
    }
  }

  public void keyReleased() {
    if (keyCode == DOWN) {
      down = false;
    }
    if (keyCode == UP) {
      up = false;
    }
    if (keyCode == LEFT) {
      left = false;
    }
    if (keyCode == RIGHT) {
      right = false;
    }
    if (keyCode == 65 || keyCode == 97) {
      a = false;
    }
    if (keyCode == 90 || keyCode == 122) {
      b = false;
    }
    if (keyCode == 69 || keyCode == 101) {
      b = false;
    }
  }
}

// fonction de verification d'état lorsque les touches "fleches" sont pressées
void keyPressed() {
  gCtrl.keyPressed();
}

// fonction de verification d'état lorsque les touches "fleches" sont relachées
void keyReleased() {
  gCtrl.keyReleased();
}

// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------