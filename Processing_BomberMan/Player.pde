
enum Action {
  LOOK_FRONT_WAIT, LOOK_LEFT_WAIT, LOOK_RIGHT_WAIT, LOOK_UP_WAIT, 
    LOOK_DOWN_WALK, LOOK_LEFT_WALK, LOOK_RIGHT_WALK, LOOK_UP_WALK, 
    LOOK_FRONT_CARRY_WAIT, LOOK_LEFT_CARRY_WAIT, LOOK_RIGHT_CARRY_WAIT, LOOK_UP_CARRY_WAIT, 
    LOOK_FRONT_CARRY_WALK, LOOK_LEFT_CARRY_WALK, LOOK_RIGHT_CARRY_WALK, LOOK_UP_CARRY_WALK, 
    LOOK_FRONT_THROW, LOOK_LEFT_THROW, LOOK_RIGHT_THROW, LOOK_UP_THROW, 
    DIE, VICTORY, GROUND_APPEAR, GROUND_DISAPPEAR, TINY_DISAPPEAR, VOID;
  public static int COUNT = Action.values().length;
}


public class BomberMan {
  private ArrayList<PImage> lPlayerImages  = new ArrayList<PImage>();
  private int spriteWidth = 16;
  private int SpriteHeight = 32;
  private int totalSprite = 134;
  // private boolean playerControl = false;
  //private ArrayList<SpriteAnimation> lAnimation;
  private EnumMap<Action, SpriteAnimation> lAnimation = new EnumMap<Action, SpriteAnimation>(Action.class);
  private int xPos, yPos;
  private Action previousAction = Action.LOOK_FRONT_WAIT; // par défaut
  private int frameCounter = 0;

  public BomberMan(PImage tileMapImg, int SpawnPosition) {
    // = loadImage(strTileMapPath);
    int TilePerWidth = tileMapImg.width / spriteWidth; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile
     */

    int yDecal = 16*9; // les sprites de bomberman se trouve à une position plus basse dans l'image. (9 tuiles plus bas)
    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerWidth) * spriteWidth; // position x et y dans l'image source tileMap
      int ySource = (floor(incr1 / TilePerWidth) * SpriteHeight) + yDecal;
      PImage i = createImage(spriteWidth, SpriteHeight, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, spriteWidth, SpriteHeight, 0, 0, spriteWidth, SpriteHeight); // on copie le contenu
      lPlayerImages.add(i); // on stocke chaque miniature...
    }



    // on construit les animations
    for (Action a : Action.values()) {
      //lAnimation.add(GetAnimation(Action.values()[incr]));
      lAnimation.put(a, GetAnimation(a));
    }

    // spawn position
    // 95
    xPos = (SpawnPosition % 30 ) * 16;
    yPos = floor(SpawnPosition / 30) * 16;
  }

  public void drawAnimation(Action b, int x, int y) {
    /* mise a jour de l'affichage du personnage
     - en fonction de l'action en cours
     - en fonction du sprite de l'animation en cours
     - en fonction du décalage x et Y
     */
    // Action b ;
    /*
    if (gCtrl.left) {
     b = Action.LOOK_LEFT_WALK;
     } else if (gCtrl.right) {
     b = Action.LOOK_RIGHT_WALK;
     } else if (gCtrl.up) {
     b = Action.LOOK_UP_WALK;
     } else if (gCtrl.down) {
     b = Action.LOOK_DOWN_WALK;
     } else if (gCtrl.a){
     b = Action.DIE;
     } else if (gCtrl.b){
     b = Action.VICTORY;
     } else {
     */

    if (b == Action.VOID) {
      switch (previousAction) {

      case LOOK_LEFT_WALK:
        b = Action.LOOK_LEFT_WAIT;
        break;
      case LOOK_RIGHT_WALK:
        b = Action.LOOK_RIGHT_WAIT;
        break;
      case LOOK_UP_WALK:
        b = Action.LOOK_UP_WAIT;
        break;
      case LOOK_DOWN_WALK:
        b = Action.LOOK_FRONT_WAIT;
        break;
      default:
        b = previousAction;
        break;
      }
    }
    // }



    if (b != previousAction) { // reset du compteur de frame s'il y a reset.
      previousAction = b;
      frameCounter = 0;
    }


    SpriteAnimation sa =   lAnimation.get(b);
    Sprite s;
    int index = Arrays.binarySearch(sa.framesPos, frameCounter);
    if (index >= 0) {
      s = sa.sprites.get(index);
    } else { // negative value is the conditional new entry index 
      s = sa.sprites.get(abs(index)-1);
    }
    pushMatrix();
    scale(gSketchScale);
    //image(lPlayerImages.get(s.TileID), xPos+s.xDecal+x, yPos + s.yDecal+y);
    image(lPlayerImages.get(s.TileID), s.xDecal+x, s.yDecal+y -16);
    popMatrix();

    frameCounter++;
    if (frameCounter> sa.MaxFrame) {
      frameCounter = sa.FrameLoop;
    }
  }

  /*
  public void SetPlayerControl(boolean bCtrl) {
   playerControl = bCtrl;
   }
   
   */






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
  }

  class SpriteAnimation {
    //int nbFrame = 0;
    int FrameLoop = 0;
    int MaxFrame = 0;
    int[] framesPos;
    ArrayList<Sprite> sprites = new ArrayList<Sprite>();


    public void setFrameLoop(int nSprite) { // défaut : boucle de la dernière vers la première
      if (nSprite == 0) {
        FrameLoop = 0;
      } else {
        if (MaxFrame == 0) {
          rebuildFramesTiming();
        }
        FrameLoop = framesPos[nSprite];
      }
    }

    public void rebuildFramesTiming() {
      framesPos = new int[sprites.size()];

      Sprite s;
      for (int incr = 0; incr < sprites.size(); incr++) {
        s = sprites.get(incr);
        framesPos[incr] = s.duration + MaxFrame;
        MaxFrame += s.duration;
      }
    }



    public void addSprite(int TileID, int xDecal, int yDecal, int duration) {
      sprites.add(new Sprite(TileID-1, xDecal, yDecal, duration));
    }
    public void addSprite(int TileID) {
      addSprite(TileID, 0, 0, 60);
    }
    public void addSprite(int TileID, int duration) {
      addSprite(TileID, 0, 0, duration);
    }
  }



  private SpriteAnimation GetAnimation(Action t) {
    SpriteAnimation s = new SpriteAnimation();
    switch (t) {
    case LOOK_FRONT_WAIT:
      s.addSprite(7);
      break;
    case LOOK_LEFT_WAIT:
      s.addSprite(10);
      break;
    case LOOK_RIGHT_WAIT:
      s.addSprite(4);
      break;
    case LOOK_UP_WAIT:
      s.addSprite(1);
      break;
    case LOOK_DOWN_WALK:
      s.addSprite(8, 10);
      s.addSprite(7, 10);
      s.addSprite(9, 10);
      s.addSprite(7, 10);
      break;
    case LOOK_LEFT_WALK:
      s.addSprite(11, 10);
      s.addSprite(10, 10);
      s.addSprite(12, -1, 0, 10);
      s.addSprite(10, 10);
      break;
    case LOOK_RIGHT_WALK:
      s.addSprite(5, 1, 0, 10);
      s.addSprite(4, 10);
      s.addSprite(6, 10); // decalage sur X
      s.addSprite(4, 10);
      break;
    case LOOK_UP_WALK:
      s.addSprite(2, 10);
      s.addSprite(1, 10);
      s.addSprite(3, 10);
      s.addSprite(1, 10);
      break;
    case DIE:
      //s.addSprite(7, 120);
      //s.addSprite(37, 30); 
      s.addSprite(37, 1);   // 4 spins !
      s.addSprite(39, 1);
      s.addSprite(14, 1);
      s.addSprite(38, 1);
      s.addSprite(37, 1);   // 4 spins !
      s.addSprite(39, 1);
      s.addSprite(14, 1);
      s.addSprite(38, 1);
      s.addSprite(37, 1);
      s.addSprite(39, 1);   //22
      s.addSprite(14, 2);
      s.addSprite(38, 2); 
      s.addSprite(37, 2);
      s.addSprite(39, 2);   //22
      s.addSprite(14, 2);
      s.addSprite(38, 2);   //32    
      s.addSprite(37, 2);
      s.addSprite(39, 2);   //22
      s.addSprite(14, 2);
      s.addSprite(38, 2);   //32    
      s.addSprite(37, 3);
      s.addSprite(39, 5);
      s.addSprite(14, 8);   //56
      s.addSprite(38, 10);   //131
      s.addSprite(37, 15);  //78
      s.addSprite(40, 15);
      s.addSprite(41, 15);
      s.addSprite(42, 5);
      s.addSprite(43, 5);
      s.addSprite(44, 5);
      s.addSprite(43, 5);
      s.addSprite(45, 5);
      s.addSprite(43, 5);
      s.addSprite(44, 5);
      s.addSprite(43, 5);
      s.addSprite(45, 5);
      s.addSprite(43, 5);
      s.addSprite(44, 5);
      s.addSprite(43, 5);
      s.addSprite(45, 5);
      s.addSprite(43, 5);
      s.addSprite(42, 5);
      s.addSprite(43, 5);
      s.setFrameLoop(40); // loop depuis le sprite 40
      break;
    case VICTORY:
      s.addSprite(134, 60);
      s.addSprite(132, 10);
      s.addSprite(133, 10);
      s.addSprite(132, 10);
      s.addSprite(133, 10);
      s.addSprite(132, 10);
      s.addSprite(133, 60);
      s.setFrameLoop(6); // loop sur le dernier sprite
      break;
      // les animations suivantes ne sont pas détaillées pour le moment....
    case GROUND_APPEAR:
    case GROUND_DISAPPEAR:
    case TINY_DISAPPEAR:
    case LOOK_FRONT_CARRY_WAIT:
    case LOOK_LEFT_CARRY_WAIT:
    case LOOK_RIGHT_CARRY_WAIT:
    case LOOK_UP_CARRY_WAIT:
    case LOOK_FRONT_CARRY_WALK:
    case LOOK_LEFT_CARRY_WALK:
    case LOOK_RIGHT_CARRY_WALK:
    case LOOK_UP_CARRY_WALK:
    case LOOK_FRONT_THROW:
    case LOOK_LEFT_THROW:
    case LOOK_RIGHT_THROW:
    case LOOK_UP_THROW:
    default:
      s.addSprite(110);
      break;
    }
    if (s.MaxFrame == 0) {
      s.rebuildFramesTiming();
    }
    return s;
  }
}  