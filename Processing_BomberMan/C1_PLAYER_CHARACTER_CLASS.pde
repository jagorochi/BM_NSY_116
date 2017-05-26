// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------

public class CHICKEN extends BASE_CHARACTER {

  public CHICKEN(int blockPosition) {
    super(blockPosition);
    walkSpeed = 0.5;
    entityType = ENTITY_TYPE.ENEMY;
  }

  public void stepFrame() {
    super.stepFrame();

    if (bControl) {
      Chicken_IA();
      if (isTouchingDeadlyItems()) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
        playSFX(SOUND_ID.ENEMY_DYING, 1);
        bControl = false;
        SetDectructCountDown(170);
      }
    } else {
      WaitStance();
    }
  }

  private void Chicken_IA() {
    if (IA_IdleCount >0) { // attente
      IA_IdleCount--;
      WaitStance();
      return;
    }
    if (IA_direction == DIRECTION.NEUTRAL) { // si on est en position neutral
      IA_direction = IA_getNewRandomAvailableDirection(); // essayons d'obtenir une voie libre
      if (IA_direction == DIRECTION.NEUTRAL) { // si aucune nouvelle direction disponible
        IA_IdleCount = 60; // on attend...
      }
    }
    if (!IA_tryDirectionStep()) {
      IA_direction =DIRECTION.NEUTRAL;
      IA_IdleCount = 60;
    }
  }
  

  protected SpriteAnimation DefineSpriteAnimationFromAction(CHARACTER_ACTION a) {
    SpriteAnimation  sa = new SpriteAnimation();
    switch (a) {
    case LOOK_FRONT_WAIT:
    case LOOK_DOWN_WALK:
      sa.addSprite(new Sprite(167, 10));
      sa.addSprite(new Sprite(168, 10));
      sa.addSprite(new Sprite(167, 10));
      sa.addSprite(new Sprite(169, 10));
      break;
    case LOOK_LEFT_WAIT:
    case LOOK_LEFT_WALK:
      sa.addSprite(new Sprite(170, 10));
      sa.addSprite(new Sprite(171, 10));
      sa.addSprite(new Sprite(170, 10));
      sa.addSprite(new Sprite(172, 10));
      break;
    case LOOK_RIGHT_WAIT:
    case LOOK_RIGHT_WALK:
      sa.addSprite(new Sprite(178, 10));
      sa.addSprite(new Sprite(176, 10));
      sa.addSprite(new Sprite(178, 10));
      sa.addSprite(new Sprite(177, 10));
      break;
    case LOOK_UP_WAIT:
    case LOOK_UP_WALK:
      sa.addSprite(new Sprite(173, 10));
      sa.addSprite(new Sprite(174, 10));
      sa.addSprite(new Sprite(173, 10));
      sa.addSprite(new Sprite(175, 10));
      break;




    case DIE:
      sa.addSprite(new Sprite(179, 120));
      sa.addSprite(new Sprite(229, 5));
      sa.addSprite(new Sprite(230, 5));
      sa.addSprite(new Sprite(231, 5));
      sa.addSprite(new Sprite(232, 5));
      sa.addSprite(new Sprite(233, 5));
      sa.addSprite(new Sprite(234, 5));
      sa.addSprite(new Sprite(235, 5));
      sa.addSprite(new Sprite(236, 5));
      sa.addSprite(new Sprite(237, 5));
      sa.addSprite(new Sprite(238, 5));
      sa.setFrameLoop(10); // loop depuis le sprite 40
      break;

    case VICTORY:
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
      sa.addSprite(new Sprite(200));
      break;
    }
    if (sa.MaxFrame == 0) {
      sa.rebuildFramesTiming();
    }
    return sa;
  }
}



public class BOMBERMAN extends BASE_CHARACTER {
  public BOMBERMAN(int blockPosition) {
    super(blockPosition);
    flamePower = 4;
    DropBombCapacity = 3;
    entityType = ENTITY_TYPE.PLAYER;
  }

  public void stepFrame() {
    boolean bool = false;

    if (bControl) { // si le joueur a l'accès...
      if (gCtrl.leftHold) {
        bool =  tryLeftStep();
      } else if (gCtrl.rightHold) {
        bool = tryRightStep();
      } else if (gCtrl.upHold) {
        bool = tryUpStep();
      } else if (gCtrl.downHold) {
        bool = tryDownStep();
      } else {
        WaitStance();
      }
      // si deplacement réussi on check si on touche un ITEM
      if (isTouchingDeadlyItems() || isTouchingDeadlyEnemy()) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
        playSFX(SOUND_ID.BOMBERMAN_DYING, 1);
        bControl = false;
      }



      if (gCtrl.aKP) {
        tryDropBomb(); //updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
      }
      if (gCtrl.bKP) {
        // updateSpriteAnimationFrame(CHARACTER_ACTION.VICTORY);
        // test de kick sur bomb
        IsKicking = true;

        /*  if (ActiveDroppedBombs.size()>0) {
         ActiveDroppedBombs.get(0).kick(DIRECTION.RIGHT, 1.5);
         }*/
      } else {
        IsKicking = false; // simple test
      }


      if (gCtrl.cKP) {
        //playSFX(SOUND_ID.BOMB_EXPLODE2);
        playSFX(SOUND_ID.BOMBERMAN_DYING, 1);
      }
    } else if (gCtrl.cKP) {
      bControl = true;
    } else {
      WaitStance();
    }
  }

  protected SpriteAnimation DefineSpriteAnimationFromAction(CHARACTER_ACTION a) {
    SpriteAnimation  sa = new SpriteAnimation();
    switch (a) {
    case LOOK_FRONT_WAIT:
      sa.addSprite(new Sprite(6));
      break;
    case LOOK_LEFT_WAIT:
      sa.addSprite(new Sprite(9));
      break;
    case LOOK_RIGHT_WAIT:
      sa.addSprite(new Sprite(3));
      break;
    case LOOK_UP_WAIT:
      sa.addSprite(new Sprite(0));
      break;
    case LOOK_DOWN_WALK:
      sa.addSprite(new Sprite(7, 10));
      sa.addSprite(new Sprite(6, 10));
      sa.addSprite(new Sprite(8, 10));
      sa.addSprite(new Sprite(6, 10));
      break;
    case LOOK_LEFT_WALK:
      sa.addSprite(new Sprite(10, 10));
      sa.addSprite(new Sprite(9, 10));
      sa.addSprite(new Sprite(11, -1, 0, 10));
      sa.addSprite(new Sprite(9, 10));
      break;
    case LOOK_RIGHT_WALK:
      sa.addSprite(new Sprite(4, 1, 0, 10));
      sa.addSprite(new Sprite(3, 10));
      sa.addSprite(new Sprite(5, 10)); // decalage sur X
      sa.addSprite(new Sprite(3, 10));
      break;
    case LOOK_UP_WALK:
      sa.addSprite(new Sprite(1, 10));
      sa.addSprite(new Sprite(0, 10));
      sa.addSprite(new Sprite(2, 10));
      sa.addSprite(new Sprite(0, 10));
      break;
    case DIE:
      sa.addSprite(new Sprite(36, 1));   // 4 spins !
      sa.addSprite(new Sprite(38, 1));
      sa.addSprite(new Sprite(13, 1));  
      sa.addSprite(new Sprite(37, 1));
      sa.addSprite(new Sprite(36, 1));   // 4 spins !
      sa.addSprite(new Sprite(38, 1));
      sa.addSprite(new Sprite(13, 1));
      sa.addSprite(new Sprite(37, 1));
      sa.addSprite(new Sprite(36, 1));
      sa.addSprite(new Sprite(38, 1));  
      sa.addSprite(new Sprite(13, 2));
      sa.addSprite(new Sprite(37, 2)); 
      sa.addSprite(new Sprite(36, 2));
      sa.addSprite(new Sprite(38, 2));  
      sa.addSprite(new Sprite(13, 2));
      sa.addSprite(new Sprite(37, 2));       
      sa.addSprite(new Sprite(36, 2));
      sa.addSprite(new Sprite(38, 2));   
      sa.addSprite(new Sprite(13, 2));
      sa.addSprite(new Sprite(37, 2));      
      sa.addSprite(new Sprite(36, 3));
      sa.addSprite(new Sprite(38, 5));
      sa.addSprite(new Sprite(13, 8));   
      sa.addSprite(new Sprite(37, 10));  
      sa.addSprite(new Sprite(36, 15)); 
      sa.addSprite(new Sprite(39, 15));
      sa.addSprite(new Sprite(40, 15));
      sa.addSprite(new Sprite(41, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(43, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(44, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(43, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(44, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(43, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(44, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.addSprite(new Sprite(41, 5));
      sa.addSprite(new Sprite(42, 5));
      sa.setFrameLoop(40); // loop depuis le sprite 40
      break;
    case VICTORY:
      sa.addSprite(new Sprite(133, 60));
      sa.addSprite(new Sprite(131, 10));
      sa.addSprite(new Sprite(132, 10));
      sa.addSprite(new Sprite(131, 10));
      sa.addSprite(new Sprite(132, 10));
      sa.addSprite(new Sprite(131, 10));
      sa.addSprite(new Sprite(132, 60));
      sa.setFrameLoop(6); // loop sur le dernier sprite
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
      sa.addSprite(new Sprite(110));
      break;
    }
    if (sa.MaxFrame == 0) {
      sa.rebuildFramesTiming();
    }
    return sa;
  }
}
