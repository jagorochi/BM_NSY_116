
public class BOMB extends BASE_OBJECT {
  private int power;
  private int duration;
  private boolean bExploded;
  public BASE_CHARACTER dropper;  // permet de suivre le compteur de bombe active du character qui a droppé la bombe.. 
  public BOMB(int block, BASE_CHARACTER dropper, int power, int duration) {
    super(block); // appel vers le constructeur parent
    this.category = OBJECT_CATEGORY.BOMB;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    movable = true; // est ce que l'objet est déplacable..
    this.kickable = true; // est ce que l'objet peut être kické.
    bExploded = false;
    this.dropper = dropper;   // character qui a droppé la bombe
    this.duration = duration; // frame duration
    this.power = power;
    // definition de l'animation
    Sprites = new int[]{51, 52, 51, 50}; // liste des sprites a utiliser dans l'animation de l'objet
    FrameTimings = new int[]{20, 40, 60, 80}; // duration des animations
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }


  public void stepFrame() {
    super.stepFrame();
    //lorsqu'une bombe est droppé, elle est forcément en contact avec un character donc elle 
    // ne doit pas le bloquer dans ses déplacements.
    if (!stopPlayer) { // 
      if (controller.getCollidingCharactersFromRect(block, rect).size()==0) { // dès qu'elle n'est plus en contact avec un character 
        stopPlayer = true; // on rebloque les mouvements du personnage
        stopEnemy = true; // // on bloque les mouvements des monstres..
      }
    }
    duration--;
    if (duration == 0) {
      flameHit();
    }
  }


  public void flameHit() {
    // afin d'éviter les bombes qui s'explosent mutuellement à l'infini via récursivité..
    // cette fonction ne doit être exécutée qu'une seule fois.
    if (bExploded) { 
      return;
    }
    bExploded = true; // 

    if (dropper != null) {
      dropper.DeleteBombRef(this); // on prévient le character qui a droppé cette bombe Qu'elle vient d'exploser : il peut en dropper une a nouveau
      dropper = null;
    }

    // verification si l'explosion se trouve sur un "Bomb explosion Maximizer"
    // ---------------------------------------------------------------------------------------- 
    ArrayList<BASE_OBJECT> objects = controller.getMapBlockPositionObjectList(block);
    int[] powerDir = new int[]{power, power, power, power};
    for (BASE_OBJECT object : objects) {
      if (object instanceof EXPLOSION_MAXIMIZER) {
        powerDir = ((EXPLOSION_MAXIMIZER) object).getPowerDirection();
        break;
      }
    }
    // maintenant on créer des objets "flammes autour" :)
    // ----------------------------------------------------------------------------------------
    ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>(); // liste des objets qui sont touchés par les flammes.. 
    // centre de la flamme
    controller.AppendObjectForInclusion(block, new FLAME(block, FLAME_TYPE.CENTER));
    FlameHitPendingObjects.addAll(controller.getMapBlockPositionObjectList(block));
    // vers la gauche
    FlameHitPendingObjects.addAll(deployFlame(powerDir[0], -1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_LEFT));
    // vers le haut
    FlameHitPendingObjects.addAll(deployFlame(powerDir[1], -gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_UP));
    // vers la droite
    FlameHitPendingObjects.addAll(deployFlame(powerDir[2], 1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_RIGHT));
    // vers le bas
    FlameHitPendingObjects.addAll(deployFlame(powerDir[3], gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_DOWN));
    // on "flameHit" tous les objets qui étaient sur le chemin des flammes :)
    for (BASE_OBJECT o : FlameHitPendingObjects) {
      o.flameHit();
    }
    FlameHitPendingObjects.clear();
    destruct();
  }

  private ArrayList<BASE_OBJECT> deployFlame(int pwr, int decal, FLAME_TYPE arm, FLAME_TYPE border) {
    FLAME_TYPE ft;
    ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>();
    for (int incr = 1; incr<=pwr; incr++) {
      int blockDecal = block + (incr*decal);
      if (controller.IsMapStoppingFlameBlock(blockDecal)) { // est ce un block de la map qui arrete les flammes ?
        break;
      }
      // verification si sur le bloc concerné il n'y justement pas un objet qui stoppe les flammes
      boolean stopFlame = false;
      for (BASE_OBJECT o : controller.getMapBlockPositionObjectList(blockDecal)) {
        if (o.stopFlame == true) {
          FlameHitPendingObjects.add(o); // cet objet doit au moins être touché par la flamme
          stopFlame = true;
          break;
        }
      }
      if (stopFlame== true) {
        break;
      }
      FlameHitPendingObjects.addAll(controller.getMapBlockPositionObjectList(blockDecal));
      if (incr == pwr) {
        ft = border;
      } else {
        ft = arm;
      }
      controller.AppendObjectForInclusion(blockDecal, new FLAME(blockDecal, ft));
    }
    return FlameHitPendingObjects;
  }

  public void playerHit() {
  }

  public void enemyHit() {
  }
}

public class DYNAMITE extends BASE_OBJECT {
  boolean bExploded;
  int duration;
  public DYNAMITE(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.BOMB;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    bExploded = false;
    Sprites = new int[]{4};
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
    duration = 30;
  }


  public void stepFrame() {
    super.stepFrame();
    if (bExploded) {
      duration--;
      if (duration == 0) {
        deploy2ndWaveFlame();
        destruct();
      }
    }
  }

  private void deploy2ndWaveFlame() {
    DeployWaveExplosion(block - 2);
    DeployWaveExplosion(block - (2*gMapBlockWidth));
    DeployWaveExplosion(block + 2);
    DeployWaveExplosion(block + (2*gMapBlockWidth));
  }


  public void flameHit() {
    if (bExploded) {
      return;
    }
    bExploded = true; // 
    // maintenant on créer des objets "flammes autour" :)
    // ----------------------------------------------------------------------------------------
    DeployWaveExplosion(block);
  }
  private void DeployWaveExplosion(int blockDecal) {
    ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>(); // liste des objets qui sont touchés par les flammes.. 

    // centre de la flamme
    if (!controller.IsMapStoppingFlameBlock(blockDecal)) {
      FlameHitPendingObjects.addAll(deployFlame(blockDecal, 1, 0, FLAME_TYPE.CENTER, FLAME_TYPE.CENTER));
      // vers la gauche
      FlameHitPendingObjects.addAll(deployFlame(blockDecal, 2, -1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_LEFT));
      // vers le haut
      FlameHitPendingObjects.addAll(deployFlame(blockDecal, 2, -gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_UP));
      // vers la droite
      FlameHitPendingObjects.addAll(deployFlame(blockDecal, 2, 1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_RIGHT));
      // vers le bas
      FlameHitPendingObjects.addAll(deployFlame(blockDecal, 2, gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_DOWN));
      // on "flameHit" tous les objets qui étaient sur le chemin des flammes :)
      for (BASE_OBJECT o : FlameHitPendingObjects) {
        o.flameHit();
      }
      FlameHitPendingObjects.clear();
    }
  }

  private ArrayList<BASE_OBJECT> deployFlame(int blockPos, int pwr, int decal, FLAME_TYPE arm, FLAME_TYPE border) {
    FLAME_TYPE ft;
    ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>();
    for (int incr = 1; incr<=pwr; incr++) {
      int blockDecal = blockPos + (incr*decal);
      if (controller.IsMapStoppingFlameBlock(blockDecal)) { // est ce un block de la map qui arrete les flammes ?
        break;
      }
      // verification si sur le bloc concerné il n'y a justement pas un objet qui stoppe les flammes
      boolean stopFlame = false;
      for (BASE_OBJECT o : controller.getMapBlockPositionObjectList(blockDecal)) {
        if (o.stopFlame == true) {
          FlameHitPendingObjects.add(o); // cet objet doit au moins être touché par la flamme
          //stopFlame = true;
          //break;
        }
      }
      if (stopFlame== true) {
        break;
      }

      FlameHitPendingObjects.addAll(controller.getMapBlockPositionObjectList(blockDecal));

      if (incr == pwr) {
        ft = border;
      } else {
        ft = arm;
      }
      controller.AppendObjectForInclusion(blockDecal, new FLAME(blockDecal, ft));
    }
    return FlameHitPendingObjects;
  }
}


public class FLAME extends BASE_OBJECT {
  private int duration;
  public FLAME(int block, FLAME_TYPE type) {
    super(block);
    this.category = OBJECT_CATEGORY.DEADLY;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    switch(type) { // liste des sprites a utiliser dans l'animation de la flamme
    case CENTER : 
      Sprites = new int[]{15, 16, 17, 18, 19, 18, 19, 18, 19, 18, 17, 16, 15};
      break;
    case HORIZONTAL :      
      Sprites = new int[]{20, 21, 22, 23, 24, 23, 24, 23, 24, 23, 22, 21, 20}; 
      break;
    case VERTICAL :
      Sprites = new int[]{25, 26, 27, 28, 29, 28, 29, 28, 29, 28, 27, 26, 25};
      break;
    case BORDER_LEFT :
      Sprites = new int[]{30, 31, 32, 33, 34, 33, 34, 33, 34, 33, 32, 31, 30};
      break;
    case BORDER_UP:
      Sprites = new int[]{35, 36, 37, 38, 39, 38, 39, 38, 39, 38, 37, 36, 35};
      break;
    case BORDER_RIGHT:
      Sprites = new int[]{40, 41, 42, 43, 44, 43, 44, 43, 44, 43, 42, 41, 40};
      break;
    case BORDER_DOWN:
      Sprites = new int[]{45, 46, 47, 48, 49, 48, 49, 48, 49, 48, 47, 46, 45};
      break;
    }

    FrameTimings = IncrementFrameTimingArray(new int[]{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 }); // durée des animations

    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
    duration = maxStepFrame;
  }
  public void stepFrame() {
    super.stepFrame();
    duration--;
    if (duration == 0) {
      destruct();
    }
  }
}

public class EXPLOSION_MAXIMIZER extends BASE_OBJECT {
  int[] powerDirection;
  public EXPLOSION_MAXIMIZER(int block, int[] powerDirection) {
    super(block);
    this.category = OBJECT_CATEGORY.STATIC;
    this.powerDirection = powerDirection;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...

    Sprites = new int[]{2};
    FrameTimings = new int[]{10};
    maxStepFrame = 10;
  }
  public int[] getPowerDirection() {
    return powerDirection;
  }
}

public class CHEST extends BASE_OBJECT {
  String strItem;
  boolean flameHit;
  public CHEST(int block, String strItem) {
    super(block);
    this.category = OBJECT_CATEGORY.INTERACTIVE;
    this.strItem = strItem;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    Sprites = new int[]{3};
    FrameTimings = new int[]{10};
    maxStepFrame = 10;
    flameHit = false;
  }

  public void flameHit() {
    if (flameHit) {
      return;
    }
    flameHit = true; // afin que cette fonction ne soit exécutée qu'une seule fois..
    if (strItem != "") {
      controller.AppendObjectForInclusion(block, new ITEM(block, strItem)); // on créer l'item avec la bonne propriété
    }
    controller.AppendObjectForInclusion(block, new EXPLODING_CHEST(block)); // et on ajoute l'exploding chest ensuite afin qu'il soit recouvert..
    destruct();
  }
}

public class EXPLODING_CHEST extends BASE_OBJECT {
  int duration;
  public EXPLODING_CHEST(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.INTERACTIVE;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    Sprites = new int[]{9, 10, 11, 12, 13, 14};
    FrameTimings = IncrementFrameTimingArray(new int[]{5, 5, 5, 5, 5, 5});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
    duration = maxStepFrame;
  }

  public void stepFrame() {
    super.stepFrame();
    duration--;
    if (duration == maxStepFrame/2) { // lorsque le coffre est a moitié disparu.. on peut commencer interagir avec le bloc a nouveau
      bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
      stopFlame = false; // est ce que cet objet arrete les flammes
      stopEnemy = false; // est ce que cet objet arrete les enemies
      stopPlayer = false; // est ce que cet objet arrete le joueur...
      stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    }
    if (duration == 0) {
      destruct();
    }
  }
}


public class ITEM extends BASE_OBJECT {
  
  public ITEM(int block, String strType) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM; // pour simplifier la detection des characters qui "touchent" cet objet 

    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    itemType = strType;
    switch (itemType) {
    case "BOMB_UP":
      Sprites = new int[]{58, 65};
      break;
    case "SPEED_UP":
      Sprites = new int[]{60, 67};
      break;
    case "FLAME_UP":
      Sprites = new int[]{59, 66};
      break;
    case "SPEED_DOWN":
      Sprites = new int[]{61, 68};
      break;
    case "LIFE_UP":
      Sprites = new int[]{62, 69};
      break;
    case "KICK":
      Sprites = new int[]{63, 70};
      break;
    case "REMOTE":
      Sprites = new int[]{64, 71};
      break;
    default:
      Sprites = new int[]{74, 75}; // ne devrait jamais être appelé.
      println("default : " + strType);
    }
    
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class CAPSULE_SWITCH extends BASE_OBJECT {

  public CAPSULE_SWITCH(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.SWITCH;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...

    Sprites = new int[]{0};
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }

  public void flameHit() {
    Sprites[0] = 1; // on change l'image en "SWITCH ON"
  }
}

public class MAGNET extends BASE_OBJECT {
  private DIRECTION direction;
  public MAGNET(int block, DIRECTION dir) {
    super(block);
    this.category = OBJECT_CATEGORY.STATIC;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    direction = dir;
    updateSpriteDirection();
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }

  private void updateSpriteDirection() {
    switch(direction) {
    case LEFT:
      Sprites = new int[]{7};
      break;
    case UP:
      Sprites = new int[]{8};
      break;
    case RIGHT:
      Sprites = new int[]{6};
      break;
    case DOWN :
      Sprites = new int[]{5};
      break;
    default :
    }
  }

  public void flameHit() {

    switch(direction) {
    case LEFT:
      direction = DIRECTION.UP;
      break;
    case UP:
      direction = DIRECTION.RIGHT;
      break;
    case RIGHT:
      direction = DIRECTION.DOWN;
      break;
    case DOWN :
      direction = DIRECTION.LEFT;
      break;
    default :
    }
    updateSpriteDirection();
  }
}