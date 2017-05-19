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
  UP, LEFT, RIGHT, DOWN, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, NEUTRAL;
}

enum FLAME_TYPE {
  CENTER, HORIZONTAL, VERTICAL, BORDER_LEFT, BORDER_RIGHT, BORDER_UP, BORDER_DOWN;
  
}

enum OBJECT_CATEGORY {
  DEADLY, STATIC, ITEM, BOMB, INTERACTIVE, SWITCH, DEFAULT;
}

enum ENTITY_TYPE {
  PLAYER, ENEMY, OBJECT;
}

public int[] convertStringArrayToIntArray(String[] strArray) {
  int[] intArray = new int[strArray.length];
  for (int incr = 0; incr < strArray.length; incr++) {
    intArray[incr] = Integer.parseInt(strArray[incr]);
  }
  return intArray;
}

// la classe suivante défini un rectangle
// x et y définissent le coin supérieur gauche du rectangle
// w et h sont la longueur et la largeur de ce rectangle

public class Rect {
  float x; // position x
  float y; // position y
  int w; // longueur (width)
  int h; // hauteur (height)
  public Rect(float x, float y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  public Rect move(DIRECTION dir, float step) {
    // renvoie un nouvel objet après avoir appliqué un décalage..
    switch(dir) {
    case UP:
      //y -= step;
      return new Rect(x, y-step, w, h);
    case LEFT:
      //x -= step;
      return new Rect(x-step, y, w, h);
    case RIGHT:
      //x+= step;
      return new Rect(x+step, y, w, h);
    case DOWN :
      //y += step;
      return new Rect(x, y+step, w, h);
    default:
      return new Rect(x, y, w, h);
    }
  }
}

// cette fonction booléenne permets de vérifier si 2 rectangle s'intersectent
public boolean isRectCollision(Rect rect1, Rect rect2) {
  return !((rect1.x >= rect2.x + rect2.w)      // trop à droite
    || (rect1.x + rect1.w <= rect2.x) // trop à gauche
    || (rect1.y >= rect2.y + rect2.h) // trop en bas
    || (rect1.y + rect1.h <= rect2.y)) ;// trop en haut
}

public int getBlockPositionFromCoordinate(float fx, float fy, boolean bDecal) {
  /* Cette fonction permet de calculer le numéro de bloc de la map en fonction de coordonnées x et y.
   utile pour recalculer la position des objets qui "bougent" et ainsi limiter les futurs tests de collisions
   a l'environnement proche.. */
   int x = (int)fx;
   int y = (int)fy;
  if (bDecal) {
    return floor((x + ( gpxMapTileSize / 2)) / gpxMapTileSize) + (((y + (gpxMapTileSize /2)) / gpxMapTileSize)* gMapBlockWidth);
  } else {
    return floor(x  / gpxMapTileSize) + ((y  / gpxMapTileSize) * gMapBlockWidth);
  }
}

public Rect getCoordinateFromBlockPosition(int block) {
  // calcul un Rect a partir de la position d'un block dans la matrice de jeu.  
  return new Rect((block % gMapBlockWidth) * gpxMapTileSize, floor(block / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
}

public class PENDING_BASE_OBJECT { //QUICKFIX
  // utilisé pour les objets qui doivent être retirés de manière différés a la fin de la boucle "stepFrame"
  // pour éviter l'exception ConcurrentModificationException
  public BASE_OBJECT ref;
  public int block;
  public PENDING_BASE_OBJECT(int block, BASE_OBJECT object) {
    this.block = block;
    this.ref = object;
  }
}

public class PENDING_BASE_CHARACTER { 
  // utilisé pour les characters qui doivent être retirés de manière différés a la fin de la boucle "stepFrame"
  // pour éviter l'exception ConcurrentModificationException
  public BASE_CHARACTER ref;
  public int block;
  public PENDING_BASE_CHARACTER(int block, BASE_CHARACTER object) {
    this.block = block;
    this.ref = object;
  }
}


class Sprite {
  int TileID;
  float xDecal;
  float yDecal;
  int duration;


  public Sprite(int TileID, float xDecal, float yDecal, int duration) {
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

public int[] IncrementFrameTimingArray(int[] oldArray) {
  //int[] newArray = new int[oldArray.length];
  for (int incr = 1; incr < oldArray.length; incr++) {
    oldArray[incr]+= oldArray[incr-1];
  }
  return oldArray;
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
    if (keyCode == 65 || keyCode == 97 || keyCode == 96) {
      a = true;
    }
    if (keyCode == 90 || keyCode == 122) {
      b = true;
    }
    if (keyCode == 69 || keyCode == 101) {
      c = true;
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
    if (keyCode == 65 || keyCode == 97 || keyCode == 96) {
      a = false;
    }
    if (keyCode == 90 || keyCode == 122) {
      b = false;
    }
    if (keyCode == 69 || keyCode == 101) {
      c = false;
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