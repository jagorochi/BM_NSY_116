
public class BOMB extends BASE_OBJECT {

  private int power;
  private int duration;
  private boolean bExploded;
  public BASE_CHARACTER dropper;  // permet de suivre le compteur de bombe active du character qui a droppé la bombe.. 
  public BOMB(int block, BASE_CHARACTER dropper, int power, int duration) {
    super(block); // appel vers le constructeur parent
    this.category = OBJECT_CATEGORY.INTERACTIVE;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = true; // est ce que l'objet est déplacable..
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
  public CHEST(int block, String strItem) {
    super(block);
    this.category = OBJECT_CATEGORY.INTERACTIVE;
    this.strItem = strItem;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{3};
    FrameTimings = new int[]{10};
    maxStepFrame = 10;
  }

  public void flameHit() {
    switch (strItem) {
    case "BOMB_UP":
      controller.AppendObjectForInclusion(block, new ITEM_BOMB_UP(block));
      break;
    case "SPEED_UP":
      controller.AppendObjectForInclusion(block, new ITEM_SPEED_UP(block));
      break;
    case "FLAME_UP":
      controller.AppendObjectForInclusion(block, new ITEM_FLAME_UP(block));
      break;
    case "SPEED_DOWN":
      controller.AppendObjectForInclusion(block, new ITEM_SPEED_DOWN(block));
      break;
    case "LIFE_UP":
      controller.AppendObjectForInclusion(block, new ITEM_LIFE_UP(block));
      break;
    case "KICK":
      controller.AppendObjectForInclusion(block, new ITEM_KICK(block));
      break;
    case "DETONATOR":
      controller.AppendObjectForInclusion(block, new ITEM_DETONATOR(block));
      break;


    default:
      break;
    }
    controller.AppendObjectForInclusion(block, new EXPLODING_CHEST(block));
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
    }
    if (duration == 0) {

      destruct();
    }
  }
}


public class ITEM_BOMB_UP extends BASE_OBJECT {

  public ITEM_BOMB_UP(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..

    Sprites = new int[]{58, 65};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_FLAME_UP extends BASE_OBJECT {

  public ITEM_FLAME_UP(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..

    Sprites = new int[]{59, 66};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_SPEED_UP extends BASE_OBJECT {

  public ITEM_SPEED_UP(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{60, 67};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_SPEED_DOWN extends BASE_OBJECT {

  public ITEM_SPEED_DOWN(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{61, 68};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_LIFE_UP extends BASE_OBJECT {

  public ITEM_LIFE_UP(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{62, 69};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_KICK extends BASE_OBJECT {

  public ITEM_KICK(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{63, 70};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class ITEM_DETONATOR extends BASE_OBJECT {

  public ITEM_DETONATOR(int block) {
    super(block);
    this.category = OBJECT_CATEGORY.ITEM;
    bombDrop = true; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..
    Sprites = new int[]{64, 71};
    FrameTimings = IncrementFrameTimingArray(new int[]{4, 4});
    maxStepFrame = FrameTimings[FrameTimings.length-1]; // boucle sur la dernière frame
  }

  public void flameHit() {
    destruct();
  }
}

public class SWITCH extends BASE_OBJECT {
  
  public SWITCH(int block){
    super(block);
    this.category = OBJECT_CATEGORY.SWITCH;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = false; // est ce que cet objet arrete les flammes
    stopEnemy = false; // est ce que cet objet arrete les enemies
    stopPlayer = false; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..

    Sprites = new int[]{0};
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }

  public void flameHit() {
    Sprites[0] = 1; // on change l'image en "SWITCH ON"
  }
}

public class DYNAMITE extends BASE_OBJECT {
  
  public DYNAMITE(int block){
    super(block);
    this.category = OBJECT_CATEGORY.INTERACTIVE;
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
    movable = false; // est ce que l'objet est déplacable..

    Sprites = new int[]{4};
    FrameTimings = new int[]{10};
    maxStepFrame = 10; // boucle sur la dernière frame
  }
  
  public void flameHit() {
    destruct();
    
  }
  
  
}