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
enum DOOR_STATUS {
  LOCKED, HIT, OPEN;
}

enum OBJECT_CATEGORY {
  DEADLY, STATIC, ITEM, BOMB, INTERACTIVE, SWITCH, DEFAULT, EXIT_DOOR, MAGNET;
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
    return ((x + ( gpxMapTileSize / 2)) / gpxMapTileSize) + (((y + (gpxMapTileSize /2)) / gpxMapTileSize)* gMapBlockWidth);
  } else {
    return (x  / gpxMapTileSize) + ((y  / gpxMapTileSize) * gMapBlockWidth);
  }
}

public Rect getCoordinateFromBlockPosition(int block) {
  // calcul un Rect a partir de la position d'un block dans la matrice de jeu.  
  return new Rect((block % gMapBlockWidth) * gpxMapTileSize, floor(block / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
}

public float getGridMapAxisDecalage(float xPos) {
  float mod = xPos % gpxMapTileSize;
  if (mod == 0) {
    return 0;
  } else if (mod > (gpxMapTileSize/2)) {
    return mod - gpxMapTileSize;
  } else {
    return mod;
  }
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
  private int leftCounter, rightCounter, upCounter, downCounter, aCounter, bCounter, cCounter;
  private boolean leftPressed, rightPressed, upPressed, downPressed; 
  public boolean leftHold, rightHold, upHold, downHold, aHold, bHold, cHold;
  // private int[] directionCounter = {0, 0, 0, 0};
  public  boolean leftKP = false;
  public  boolean rightKP = false;
  public  boolean upKP = false;
  public  boolean downKP = false;
  public  boolean aKP = false;
  public  boolean bKP = false;
  public  boolean cKP = false;

  public void keyPressed() {
    if (keyCode == DOWN) {
      downPressed = true;
    }
    if (keyCode == UP) {
      upPressed = true;
    }
    if (keyCode == LEFT) {
      leftPressed = true;
    }
    if (keyCode == RIGHT) {
      rightPressed = true;
    }
    if (keyCode == 65 || keyCode == 97 || keyCode == 96) {
      aHold = true;
    }
    if (keyCode == 90 || keyCode == 122) {
      bHold = true;
    }
    if (keyCode == 69 || keyCode == 101) {
      cHold = true;
    }
  }

  public void keyReleased() {
    if (keyCode == DOWN) {
      downPressed = false;
      downCounter = 0;// reactivation du compteur ok
    }
    if (keyCode == UP) {
      upPressed = false;
      upCounter = 0;// reactivation du compteur ok
    }
    if (keyCode == LEFT) {
      leftPressed = false;
      
      leftCounter = 0;// reactivation du compteur ok
    }
    if (keyCode == RIGHT) {
      rightPressed = false;
      rightCounter = 0;// reactivation du compteur ok
    }

    if (keyCode == 65 || keyCode == 97 || keyCode == 96) {
      aHold = false;
    }
    if (keyCode == 90 || keyCode == 122) {
      bHold = false;
    }
    if (keyCode == 69 || keyCode == 101) {
      cHold = false;
    }
  }

  public void stepFrame() {
    // afin d'eviter les conflits dans les directions que presse le joueur, on va prioriser la derniere direction enclenché en cas de conflit, et remettre à annuler les autres..
    // il faut donc compter le nombre de frame durant lequel les boutons sont pressés..
    leftKP = false; 
    rightKP = false;
    upKP = false;
    downKP = false;
    leftHold = false;
    rightHold = false;
    upHold = false;
    downHold = false;


    if (leftPressed && leftCounter != -1) {
      leftCounter++;
      leftHold = true;
      if (leftCounter == 1) { // si c'est la première frame enclenchée de cette direction et que les autres directions sont déjà enclenchées : on n'en tient plus compte jusqu'a ce que le joueur les aient relachés
        if (rightCounter > 0)  rightCounter = -1; 
        if (upCounter > 0)  upCounter = -1;
        if (downCounter > 0)  downCounter = -1;
        leftKP = true;
      }
    }

    if (upPressed && upCounter != -1) {
      upCounter++;
      upHold = true;
      if (upCounter == 1) { // si c'est la première frame enclenchée de cette direction et que les autres directions sont déjà enclenchées : on n'en tient plus compte jusqu'a ce que le joueur les aient relachés
        if (rightCounter > 0)  rightCounter = -1; 
        if (leftCounter > 0)  leftCounter = -1;
        if (downCounter > 0)  downCounter = -1;
        upKP = true;
      }
    }

    if (rightPressed && rightCounter != -1) {
      rightCounter++;
      rightHold = true;
      if (rightCounter == 1) { // si c'est la première frame enclenchée de cette direction et que les autres directions sont déjà enclenchées : on n'en tient plus compte jusqu'a ce que le joueur les aient relachés
        if (leftCounter > 0)  leftCounter = -1;
        if (upCounter > 0)  upCounter = -1;
        if (downCounter > 0)  downCounter = -1;
        rightKP = true;
      }
    }

    if (downPressed && downCounter != -1) {
      downCounter++;
      downHold = true;
      if (downCounter == 1) { // si c'est la première frame enclenchée de cette direction et que les autres directions sont déjà enclenchées : on n'en tient plus compte jusqu'a ce que le joueur les aient relachés
        if (rightCounter > 0)  rightCounter = -1;
        if (upCounter > 0)  upCounter = -1;
        if (leftCounter > 0)  leftCounter = -1;
        downKP = true; // 1ère frame ou le joueur presse la direction
      }
    }

    /*
    int pos = 0;
     for (int incr = 1; incr < 4; incr++) {
     if (directionCounter[incr] > directionCounter[ipos]) {
     pos = incr;
     }
     }
     
     switch (pos) {
     case 0:
     leftHold = true;
     if (directionCounter[0] == 0) leftKP = true;
     break;
     case 1:
     upHold = true;
     if (directionCounter[1] == 0) upKP = true;
     break;
     case 2:
     rightHold = true;
     if (directionCounter[2] == 0) rightKP = true;
     break;
     case 3:
     downHold = true;
     if (directionCounter[3] == 0) downKP = true;
     }*/



    if (aHold) {
      aCounter++;
      if (aCounter == 1) {
        aKP = true;
      } else {
        aKP = false;
      }
    } else {
      aCounter = 0;
      aKP = false;
    }

    if (bHold) {
      bCounter++;
      if (bCounter == 1) {
        bKP = true;
      } else {
        bKP = false;
      }
    } else {
      bCounter = 0;
      bKP = false;
    }

    if (cHold) {
      cCounter++;
      if (cCounter == 1) {
        cKP = true;
      } else {
        cKP = false;
      }
    } else {
      cCounter = 0;
      cKP = false;
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