public class BOMBERMAN extends BASE_CHARACTER {
  public BOMBERMAN(int blockPosition, String ID) {
    super(blockPosition, ID);
    flamePower = 1;
    DropBombCapacity = 1;
    entityType = ENTITY_TYPE.PLAYER;
  }

  public void stepFrame() {
    //boolean bool = false;
    
    if (bControl) { // si le joueur a l'accès...
      if (gCtrl.leftHold) {
        tryLeftStep();
      } else if (gCtrl.rightHold) {
        tryRightStep();
      } else if (gCtrl.upHold) {
        tryUpStep();
      } else if (gCtrl.downHold) {
        tryDownStep();
      } else {
        WaitStance();
      }
      // si deplacement réussi on check si on touche un ITEM
      if ((isTouchingDeadlyObjects() || isTouchingDeadlyEnemy()) && invulnerabilityDuration==0) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
        gSound.playSFX(SOUND_ID.BOMBERMAN_DYING, 1);
        bControl = false;
        controller.levelEndingEvent(LEVEL_END_EVENT.PLAYER_DIE);
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
        // gSound.playSFX(SOUND_ID.HOLD, 1);
      }
    } else if (gCtrl.cKP && gDebug) {
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