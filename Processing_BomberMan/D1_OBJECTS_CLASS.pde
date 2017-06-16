
public class BOMB extends BASE_OBJECT {
  private int power;
  private int CountDownExplosion;
  private int surroundingFlameHitDelay;
  private boolean bExploded;
  private ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>(); // liste des objets qui sont touchés par les flammes..

  public BASE_CHARACTER dropper;  // permet de suivre le compteur de bombe active du character qui a droppé la bombe.. 
  public BOMB(int block, BASE_CHARACTER dropper, int power, int countDown) {
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
    this.CountDownExplosion = countDown; // frame duration
    this.power = power;
    this.surroundingFlameHitDelay = -1;// en attente
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
    CountDownExplosion--;
    if (CountDownExplosion == 0) {
      flameHit();
    }
    if (surroundingFlameHitDelay>-1) {
      surroundingFlameHitDelay--;
      if (surroundingFlameHitDelay == 0) {
        for (BASE_OBJECT o : FlameHitPendingObjects) {
          o.flameHit();
        }
        FlameHitPendingObjects.clear();
        destruct();
      }
    }
  }

  public void removeDropperReference() {
    if (dropper != null) {
      dropper.DeleteBombRef(this); // on prévient le character qui a droppé cette bombe Qu'elle vient d'exploser : il peut en dropper une a nouveau
      dropper = null;
    }
  }

  public void flameHit() {
    // afin d'éviter les bombes qui s'explosent mutuellement à l'infini via récursivité..
    // cette fonction ne doit être exécutée qu'une seule fois.
    if (bExploded) { 
      return;
    }
    bExploded = true; // 
    gSound.playSFX(SOUND_ID.BOMB_EXPLODE1, 0.5);
    removeDropperReference();
    
    // verification si l'explosion se trouve sur un "Bomb explosion Maximizer"
    // ---------------------------------------------------------------------------------------- 
    int[] powerDir = new int[]{power, power, power, power};
    if (controller != null){ // anti bug si la bombe est est "mangé" par pacman à la frame ou elle explose...
      ArrayList<BASE_OBJECT> objects = controller.getMapBlockPositionObjectList(block);
      for (BASE_OBJECT object : objects) {
        if (object instanceof EXPLOSION_MAXIMIZER) {
          powerDir = ((EXPLOSION_MAXIMIZER) object).getPowerDirection();
          break;
        }
      }
    }
    // maintenant on créer des objets "flammes autour" :)
    // ----------------------------------------------------------------------------------------

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
    surroundingFlameHitDelay = 3;
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
    this.category = OBJECT_CATEGORY.DYNAMITE;
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
    duration = 38;
  }


  public void stepFrame() {
    super.stepFrame();
    if (bExploded) {
      duration--;
      /*
      if (duration == 6) {
       deploy2ndWaveFlame();
       destruct();
       }*/
      if (duration == 6) {
        gSound.playSFX(SOUND_ID.BOMB_EXPLODE6, 0.5);
        DeployWaveExplosion(block - 2);
      } else if (duration == 4) {
        DeployWaveExplosion(block - (2*gMapBlockWidth));
      } else if (duration == 2) {
        DeployWaveExplosion(block + 2);
      } else if (duration == 0) {
        DeployWaveExplosion(block + (2*gMapBlockWidth));
        destruct();
      }
    }
  }
  /*
  private void deploy2ndWaveFlame() {
   
   playSFX(SOUND_ID.BOMB_EXPLODE6);
   DeployWaveExplosion(block - 2);
   DeployWaveExplosion(block - (2*gMapBlockWidth));
   DeployWaveExplosion(block + 2);
   DeployWaveExplosion(block + (2*gMapBlockWidth));
   }
   */

  public void flameHit() {
    if (bExploded) {
      return;
    }
    bExploded = true; // 
    // maintenant on créer des objets "flammes autour" :)
    // ----------------------------------------------------------------------------------------
    gSound.playSFX(SOUND_ID.BOMB_EXPLODE2, 0.5);
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

public class SPIKE extends BASE_OBJECT {
  private boolean shadow;
  private boolean spiked;
  public SPIKE(int block, boolean shadow) {
    super(block);
    this.category = OBJECT_CATEGORY.SPIKE; // pour simplifier la detection des characters qui "touchent" cet objet 
    this.shadow = shadow; // ombre 
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    spiked = false;
    if (shadow) {
      Sprites = new int[]{74};
    } else {
      Sprites = new int[]{72};
    }
    FrameTimings = new int[]{10};
  }

  public void stepFrame() {
    super.stepFrame();
    if (spiked) return;

    for ( BASE_CHARACTER c : controller.getMapBlockPositionCharacterList(block)) {
      if (c.entityType == ENTITY_TYPE.PLAYER) {
        this.category = OBJECT_CATEGORY.DEADLY;
        gSound.playSFX(SOUND_ID.SWORD, 1);
        if (shadow) {
          Sprites = new int[]{75};
        } else {
          Sprites = new int[]{73};
        }
        spiked = true;
        break;
      }
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
  private boolean switched;
  public CAPSULE_SWITCH(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.SWITCH;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = false; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    switched = false;
    Sprites = new int[]{0};
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }

  public void flameHit() {
    if (!switched) {
      switched = true;
      gSound.playSFX(SOUND_ID.COMMAND_SET, 1);
      Sprites[0] = 1; // on change l'image en "SWITCH ON"
      controller.confirmSwitchEnabledForExit();
    }
  }
}

public class MAGNET extends BASE_OBJECT {
  private DIRECTION MagnetizeDirection;
  private int magnetDecal;
  private int maxDistanceAction;
  private int pauseMagnet;
  private boolean fixed;
  public MAGNET(int block, DIRECTION dir, boolean fixed) {
    super(block);
    this.category = OBJECT_CATEGORY.MAGNET;
    this.fixed = fixed;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    MagnetizeDirection = dir;
    updateMagnetDirection();
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }


  public void stepFrame() {
    super.stepFrame();
    if (pauseMagnet == 0) {
      magnetize();
    } else {
      pauseMagnet--;
    }
  }

  private void magnetize() {
    for (int decal = 1; decal <=maxDistanceAction; decal++) {
      int pos = block + (decal * magnetDecal);
      if (!controller.IsMapStoppingObjectBlock(pos)) {
        // if (decal > 1) {
        for (BASE_OBJECT o : controller.getMapBlockPositionObjectList(pos)) {
          if (o.category == OBJECT_CATEGORY.BOMB) {

            if (o.tryKicking(MagnetizeDirection, 2.1)) gSound.playSFX(SOUND_ID.MAGNET3, 1);
          }
        }
        // }
      } else {
        maxDistanceAction = decal-1;
        break;
      }
    }
  }


  private void updateMagnetDirection() {
    maxDistanceAction = 4; // a chaque nouvelle orientation on mets a jour la distance d'action..
    switch(MagnetizeDirection) {
    case LEFT:
      Sprites = new int[]{6};
      magnetDecal = 1;
      break;
    case UP:
      Sprites = new int[]{5};
      magnetDecal = gMapBlockWidth;
      break;
    case RIGHT:
      Sprites = new int[]{7};
      magnetDecal = -1;
      break;
    case DOWN :
      Sprites = new int[]{8};
      magnetDecal = -gMapBlockWidth;
      break;
    default :
    }
  }



  public void flameHit() {
    if (pauseMagnet > 0) {
      return;
    }
    gSound.playSFX(SOUND_ID.SWORD, 1);

    pauseMagnet = 10;
    if (!fixed) {
      switch(MagnetizeDirection) {
      case LEFT:
        MagnetizeDirection = DIRECTION.UP;
        break;
      case UP:
        MagnetizeDirection = DIRECTION.RIGHT;
        break;
      case RIGHT:
        MagnetizeDirection = DIRECTION.DOWN;
        break;
      case DOWN :
        MagnetizeDirection = DIRECTION.LEFT;
        break;
      default :
      }
      updateMagnetDirection();
    }
  }
}


public class EXIT_DOOR extends BASE_OBJECT {
  private DOOR_STATUS status;
  private int duration;
  public EXIT_DOOR(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.EXIT_DOOR;

    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    stopObject = true; // est ce que cet objet arrete les objets pouvant être kické ou poussés...
    duration = 0;
    updateStatus(DOOR_STATUS.LOCKED);
  }


  public void stepFrame() {
    super.stepFrame();
    switch (status) {
    case LOCKED:
      break;
    case HIT:
      duration--;
      if (duration == 0) {
        updateStatus(DOOR_STATUS.LOCKED);
      }
      break;

    case OPEN:
      duration--;
      if (duration == 0) { // le joueur peut marcher sur le bloc de la sortie
        stopPlayer = false; // est ce que cet objet arrete le joueur...
        stopFlame = false; // est ce que cet objet arrete les flammes
      }
      break;
    }
  }

  public void flameHit() {
    println("EXIT_DOOR flameHit !");
    if (status == DOOR_STATUS.LOCKED) {
      updateStatus(DOOR_STATUS.HIT);
      controller.RespawnAllDeadCharacters();
    }
  }

  public void open() {
    //println("EXIT_DOOR OPEN !");
    gSound.playSFX(SOUND_ID.SECRET, 1);
    updateStatus(DOOR_STATUS.OPEN);
  }

  private void updateStatus(DOOR_STATUS newStatus) {
    status = newStatus;
    stepFrame = 0;
    switch(newStatus) {
    case LOCKED:
      Sprites = new int[]{0};
      FrameTimings = new int[]{10};
      maxStepFrame = 10; // boucle sur la dernière frame
      firstStepFrame = 0;
      break;
    case HIT:
      Sprites = new int[]{1, 0};
      FrameTimings = new int[]{5, 10};
      maxStepFrame = 10; // boucle sur la dernière frame
      firstStepFrame = 0;
      duration = 120;
      break;
    case OPEN:
      Sprites = new int[]{0, 2, 3, 4, 5, 6, 7};
      FrameTimings = IncrementFrameTimingArray(new int[]{10, 10, 10, 10, 10, 10, 10});
      maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
      firstStepFrame = maxStepFrame-9; // boucle sur la dernière image...

      duration = 70;
    }
  }
}