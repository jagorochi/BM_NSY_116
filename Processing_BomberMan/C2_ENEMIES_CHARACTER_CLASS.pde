
public class PACMAN extends BASE_CHARACTER {
  public PACMAN(int blockPosition, String ID) {
    super(blockPosition, ID);
    walkSpeed = 0.5;
    walkOverBomb = true;
    entityType = ENTITY_TYPE.ENEMY;
    //isSpriteTinted = true;
  }
  
  public void stepFrame() {
    super.stepFrame();
    
    if (bControl) {
      IA_Routine();
      if (isTouchingDeadlyObjects() && invulnerabilityDuration==0) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
        entityType = ENTITY_TYPE.PLAYER; // devient inoffensif
        gSound.playSFX(SOUND_ID.ENEMY_DYING, 1);
        bControl = false;
        SetDectructCountDown(170);
      }
    }else{
      WaitStance();
    }
  }
  
  private void IA_Routine() {
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
      IA_IdleCount = 5;
    }else{ // si on a reussi a bouger..
      // vérification si on est pas sur la même case qu'une bombe : on la mange !
      for (BASE_OBJECT o : controller.getMapBlockPositionObjectList(blockPosition)){
        if (o.category == OBJECT_CATEGORY.BOMB){
          ((BOMB) o).removeDropperReference();
          controller.RemoveObject(o.block, o);
          gSound.playSFX(SOUND_ID.HOLD,1);
        }
      }
    }
  }


  protected SpriteAnimation DefineSpriteAnimationFromAction(CHARACTER_ACTION a) {
    SpriteAnimation  sa = new SpriteAnimation();
    switch (a) {
    case LOOK_FRONT_WAIT:
    case LOOK_DOWN_WALK:
      sa.addSprite(new Sprite(180, 5));
      sa.addSprite(new Sprite(181, 5));
      sa.addSprite(new Sprite(182, 5));
      sa.addSprite(new Sprite(183, 5));
      sa.addSprite(new Sprite(182, 5));
      sa.addSprite(new Sprite(181, 5));
      break;
    case LOOK_LEFT_WAIT:
    case LOOK_LEFT_WALK:
      sa.addSprite(new Sprite(188, 5));
      sa.addSprite(new Sprite(189, 5));
      sa.addSprite(new Sprite(190, 5));
      sa.addSprite(new Sprite(191, 5));
      sa.addSprite(new Sprite(190, 5));
      sa.addSprite(new Sprite(189, 5));
      break;
    case LOOK_RIGHT_WAIT:
    case LOOK_RIGHT_WALK:
      sa.addSprite(new Sprite(192, 5));
      sa.addSprite(new Sprite(193, 5));
      sa.addSprite(new Sprite(194, 5));
      sa.addSprite(new Sprite(195, 5));
      sa.addSprite(new Sprite(194, 5));
      sa.addSprite(new Sprite(193, 5));
      break;
    case LOOK_UP_WAIT:
    case LOOK_UP_WALK:
      sa.addSprite(new Sprite(184, 5));
      sa.addSprite(new Sprite(185, 5));
      sa.addSprite(new Sprite(186, 5));
      sa.addSprite(new Sprite(187, 5));
      sa.addSprite(new Sprite(186, 5));
      sa.addSprite(new Sprite(185, 5));
      break;
    case DIE:
      sa.addSprite(new Sprite(196, 120));
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

/* ---------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------*/
public class CHICKEN extends BASE_CHARACTER {
  public CHICKEN(int blockPosition, String ID) {
    super(blockPosition, ID);
    walkSpeed = 0.4;
    entityType = ENTITY_TYPE.ENEMY;
  }
  
  public void stepFrame() {
    super.stepFrame();

    if (bControl) {
      Chicken_IA();
      if (isTouchingDeadlyObjects() && invulnerabilityDuration==0) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
        entityType = ENTITY_TYPE.PLAYER; // devient inoffensif
        gSound.playSFX(SOUND_ID.ENEMY_DYING, 1);
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
      sa.addSprite(new Sprite(171,10));
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

/* ---------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------*/