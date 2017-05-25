// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------


public class BOMBERMAN extends BASE_CHARACTER {
  public BOMBERMAN(int blockPosition) {
    super(blockPosition);
    flamePower = 4;
    DropBombCapacity = 3;
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

      for (BASE_OBJECT o : controller.getTouchingObjectsWithCharacterRect(blockPosition, rect)) {
        switch (o.category) {
        case DEADLY :
          updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
          playSFX(SOUND_ID.BOMBERMAN_DYING,1);
          bControl = false;
          break;
        case EXIT_DOOR:
          updateSpriteAnimationFrame(CHARACTER_ACTION.VICTORY);
          bControl = false;
          break;
        case ITEM :
          switch (o.itemType) {
          case "BOMB_UP":
            DropBombCapacity++;
            if (DropBombCapacity>5) {
              DropBombCapacity = 5;
            }
            break;
          case "SPEED_UP":
            walkSpeed+=0.2;
            if (walkSpeed>2.0) {
              walkSpeed = 2;
            }
            break;
          case "FLAME_UP":
            flamePower++;
            if (flamePower>10) {
              flamePower = 10;
            }
            break;
          case "SPEED_DOWN":
            if (walkSpeed<0.6) {
              walkSpeed = 0.6; // faut pas abuser non plus ^^
            }
            break;
          case "LIFE_UP":
              playSFX(SOUND_ID.ONE_UP,1);
            break;
          case "KICK":
            kickingAbility = true;
            break;
          case "REMOTE":

            break;
          }
          
          playSFX(SOUND_ID.ITEM_GET,1);
          controller.RemoveObject(o.block, o);
          
          break;
        default:
          break;
        }
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
      
      
      if (gCtrl.cKP){
        //playSFX(SOUND_ID.BOMB_EXPLODE2);
        playSFX(SOUND_ID.BOMBERMAN_DYING,1);
      }
      
    } else if (gCtrl.cKP) {
      bControl = true;
      
    } else {
      WaitStance();
    }
    if (bool) {
      // nothing
    }
    /* mise a jour de l'affichage du personnage
     - en fonction de l'action en cours
     - en fonction du sprite de l'animation en cours
     - en fonction du décalage x et Y
     */
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