
public class BOMB extends BASE_OBJECT {

  private int power;
  private int duration;
  private boolean bExploded;
  public BASE_CHARACTER dropper;  // permet de suivre le compteur de bombe active du character qui a droppé la bombe.. 
  public BOMB(int block, BASE_CHARACTER dropper, int power, int duration) {
    super(block); // appel vers le constructeur parent
    bombDrop = false; // est ce qu'on peut déposer une bombe sur cet objet
    stopFlame = true; // est ce que cet objet arrete les flammes
    stopEnemy = true; // est ce que cet objet arrete les enemies
    stopPlayer = true; // est ce que cet objet arrete le joueur...
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

    /* maintenant on créer des objets "flammes autour" :)
     ---------------------------------------------------------------------------------------- 
     */
    ArrayList<BASE_OBJECT> FlameHitPendingObjects = new ArrayList<BASE_OBJECT>(); // liste des objets qui sont touchés par les flammes.. 
    
    // centre de la flamme
    controller.AppendObjectForInclusion(block, new FLAME(block, FLAME_TYPE.CENTER));
    // vers la gauche
    FlameHitPendingObjects.addAll(deployFlame(power, -1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_LEFT));
    // vers le haut
    FlameHitPendingObjects.addAll(deployFlame(power, -gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_UP));
    // vers la droite
    FlameHitPendingObjects.addAll(deployFlame(power, 1, FLAME_TYPE.HORIZONTAL, FLAME_TYPE.BORDER_RIGHT));
    // vers le bas
    FlameHitPendingObjects.addAll(deployFlame(power, gMapBlockWidth, FLAME_TYPE.VERTICAL, FLAME_TYPE.BORDER_DOWN));
    // on "flameHit" tous les objets qui étaient sur le chemin des flammes :)
    for (BASE_OBJECT o : FlameHitPendingObjects){
      o.flameHit();
    }
    FlameHitPendingObjects.clear();
    destruct();
  }
  
  private ArrayList<BASE_OBJECT> deployFlame(int pwr, int decal, FLAME_TYPE arm, FLAME_TYPE border){
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


/*
15,16,17,18,19,18,19,18,19,18,17,16,15 centre
 20,21,22,23,24,23,24,23,24,23,22,21,20 horizontal
 25,26,27,28,29,28,29,28,29,28,27,26,25 vertical
 30,31,32,33,34,33,34,33,34,33,32,31,30 bout gauche
 35,36,37,38,39,38,39,38,39,38,37,36,35 bout haut
 40,41,42,43,44,43,44,43,44,43,42,41,40 bout droite
 45,46,47,48,49,48,49,48,49,48,47,46,45 bout bas
 */