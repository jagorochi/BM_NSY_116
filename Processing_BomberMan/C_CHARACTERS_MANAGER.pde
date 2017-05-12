public class CHARACTERS_MANAGER {
  private ArrayList<PImage> lCharactersImages  = new ArrayList<PImage>();
  private int spriteWidth = 16;
  private int SpriteHeight = 32;
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private BOMBERMAN BM;
  private ArrayList<BASE_CHARACTER> CHARACTERS  = new ArrayList<BASE_CHARACTER>();
  // private GLC oParent;

  public CHARACTERS_MANAGER( PImage tileMapImg, int pxTileSize, String strMapPath) {


    // recuperation des sprites de taille 16*32 ------------------------------------------------------------------------------------------------------------
    int totalSprite = 172; // nombre total de sprite "character" (bomberman + monstres)
    spriteWidth = pxTileSize;
    SpriteHeight = pxTileSize * 2;
    int TilePerWidth = tileMapImg.width / spriteWidth; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap

    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     
     
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile   */
    int yTileMapCharactersSpriteDecal = pxTileSize*9; // les sprites de bomberman se trouve à une position plus basse dans l'image. (9 tuiles plus bas)

    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerWidth) * spriteWidth; // position x et y dans l'image source tileMap
      int ySource = (floor(incr1 / TilePerWidth) * SpriteHeight) + yTileMapCharactersSpriteDecal;
      PImage i = createImage(spriteWidth, SpriteHeight, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, spriteWidth, SpriteHeight, 0, 0, spriteWidth, SpriteHeight); // on copie le contenu
      lCharactersImages.add(i); // on stocke chaque miniature...
    }

    // recuperation des sprites de taille 24*32 ------------------------------------------------------------------------------------------------------------
    totalSprite = 39; // nombre total de sprite large
    spriteWidth = pxTileSize / 2 * 3; // 1/3 plus large..
    SpriteHeight = pxTileSize * 2;
    TilePerWidth = floor(tileMapImg.width / spriteWidth); // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    yTileMapCharactersSpriteDecal = pxTileSize*19;

    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerWidth) * spriteWidth; // position x et y dans l'image source tileMap
      int ySource = (floor(incr1 / TilePerWidth) * SpriteHeight) + yTileMapCharactersSpriteDecal;
      PImage i = createImage(spriteWidth, SpriteHeight, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, spriteWidth, SpriteHeight, 0, 0, spriteWidth, SpriteHeight); // on copie le contenu
      lCharactersImages.add(i); // on stocke chaque miniature...
    }

    // spawn des characters du niveau------------------------------------------------------------------------------------------------------------
    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    int blocksHeight = strLevelMapInit.length;
    int blocksWidth = split(strLevelMapInit[0], ';').length;


    for (int incr1 = 0; incr1 < blocksHeight; incr1++) {
      String[] strMapLineContent = split(strLevelMapInit[incr1], ";");
      for ( int incr2 = 0; incr2 < blocksWidth; incr2++) {
        if (strMapLineContent[incr2].contains("'")) {
          String[] items = split(strMapLineContent[incr2], "'");
          for ( String item : items) {
            switch(item){
            case "111": // bomberman
                BM = new BOMBERMAN((incr1*blocksWidth)+incr2,pxTileSize, blocksWidth);
                
                addObject(BM);
                
                println("creation de l'objet bomberman :) sur le block n° " + (incr1*blocksHeight)+incr2);
              break;
            case "112": // enemie 1
              break;
            case "113": // enemie 2
              break;
            case "114": // enemie 3
              break;
            }
          }
        }
      }
    }
  }

  

  public void addObject(BASE_CHARACTER o) {
    CHARACTERS.add(o);
    //ID++;
    //return ID;
  }

  void removeObject(BASE_CHARACTER o) {
    CHARACTERS.remove(o);
  }

  public void UpdateCharactersStepFrame() {
    for (BASE_CHARACTER o : CHARACTERS) {
      o.stepFrame();
    }
  }
  
  
  public void RenderCharacters() {
    for (BASE_CHARACTER o : CHARACTERS) {
      Sprite s = o.GetSpriteToRender();
      image(lCharactersImages.get(s.TileID), s.xDecal, s.yDecal);
    }
  }
  
  public Rect getPlayerRect(){
    return BM.rect;
  }
  
}


public class BASE_CHARACTER {
  protected EnumMap<CHARACTER_ACTION, SpriteAnimation> lAnimation = new EnumMap<CHARACTER_ACTION, SpriteAnimation>(CHARACTER_ACTION.class);
  protected CHARACTER_ACTION previousAction = CHARACTER_ACTION.LOOK_FRONT_WAIT; // par défaut
  protected int frameCounter = 0;
  public int  blockPosition;
  protected boolean bControl = true;
  protected Rect rect ;
  protected int walkSpeed;
  protected Sprite spriteToRender;
  protected int mapBlockWidth;

  public BASE_CHARACTER(int blockPosition, int pxTileSize, int blockWidth) {
    // on construit les animations
    this.blockPosition = blockPosition;
    mapBlockWidth = blockWidth;
    rect = new Rect((blockPosition % mapBlockWidth) * pxTileSize, floor(blockPosition / mapBlockWidth) * pxTileSize, pxTileSize, pxTileSize);
    walkSpeed = 1;
    bControl = true;
    spriteToRender = new Sprite(1, rect.x, rect.y, 0); // default..
    
    for (CHARACTER_ACTION Action : CHARACTER_ACTION.values()) {
      SpriteAnimation sa = DefineSpriteAnimationFromAction(Action);
      if (sa.MaxFrame == 0) {
        sa.rebuildFramesTiming();
      }
      lAnimation.put(Action, sa);
    }
  }


  public void stepFrame() {
    /* mise a jour de l'affichage du personnage
     - en fonction de l'action en cours
     - en fonction du sprite de l'animation en cours
     - en fonction du décalage x et Y
     */
  }

  void updateSpriteAnimationFrame(CHARACTER_ACTION Action) {
    if (Action != previousAction) { // reset du compteur de frame s'il y a reset.
      previousAction = Action;
      frameCounter = 0;
    }
    SpriteAnimation sa = lAnimation.get(Action);
    Sprite s;
    int index = Arrays.binarySearch(sa.framesPos, frameCounter);
    if (index >= 0) {
      s = sa.sprites.get(index);
    } else { // negative value is the conditional new entry index 
      s = sa.sprites.get(abs(index)-1);
    }
    spriteToRender = new Sprite(s.TileID, s.xDecal + rect.x, s.yDecal + rect.y - 16, 0);
    //image(lPlayerImages.get(s.TileID), s.xDecal+x, s.yDecal+y -16);
    frameCounter++;
    if (frameCounter> sa.MaxFrame) {
      frameCounter = sa.FrameLoop;
    }
  }

  protected void WaitStance() {
    CHARACTER_ACTION Action;
    switch (previousAction) {
    case LOOK_LEFT_WALK:
      Action = CHARACTER_ACTION.LOOK_LEFT_WAIT;
      break;
    case LOOK_RIGHT_WALK:
      Action = CHARACTER_ACTION.LOOK_RIGHT_WAIT;
      break;
    case LOOK_UP_WALK:
      Action = CHARACTER_ACTION.LOOK_UP_WAIT;
      break;
    case LOOK_DOWN_WALK:
      Action = CHARACTER_ACTION.LOOK_FRONT_WAIT;
      break;
    default:
      Action = previousAction;
      break;
    }
    updateSpriteAnimationFrame(Action);
  }

  protected boolean tryRightStep() {
    if ( Glc.map.checkHardBlockCollision(blockPosition+1, rect)) {
      rect.x +=walkSpeed; 
      int yDiff = Glc.map.getYdifference(blockPosition+1, rect.y);
      if (yDiff < 0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition+1 + mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff);
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition+1 - mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y += abs(yDiff);
          } else {
            rect.y += walkSpeed;
          }
        }
      }
      blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK);
      return true;
    } else {
      int yDiff = Glc.map.getYdifference(blockPosition+1, rect.y);
      if (yDiff < 0) {

        if (!Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth) && !Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth+1)) {
          rect.y +=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {
        if (!Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth) && !Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth+1)) {
          rect.y -=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK);// on marche sur place...
    return false;
  }

  protected boolean tryLeftStep() {
    if ( Glc.map.checkHardBlockCollision(blockPosition-1, rect)) {
      rect.x -=walkSpeed; // on avance
      int yDiff = Glc.map.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition-1 + mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff); // +
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition -1 - mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition  - mapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y += abs(yDiff);
          } else {
            rect.y += walkSpeed;
          }
        }
      }
      blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
      return true;
    } else {
      int yDiff = Glc.map.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) { // plus bas

        if (!Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth) && !Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth-1)) {
          rect.y +=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {

        if (!Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth) && !Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth-1)) {
          rect.y -=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
    return false;
  }

  protected boolean tryUpStep() {
    if ( Glc.map.checkHardBlockCollision(blockPosition- mapBlockWidth, rect)) {
      rect.y -=walkSpeed; // on avance
      int xDiff = Glc.map.getXdifference(blockPosition- mapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition - 1 - mapBlockWidth) || Glc.map.IsStopPlayerBlock(blockPosition -1 )) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition + 1 - mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition +1)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
      return true;
    } else {
      int xDiff = Glc.map.getXdifference(blockPosition- mapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!Glc.map.IsStopPlayerBlock(blockPosition - 1) && !Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth-1)) {
          rect.x -=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!Glc.map.IsStopPlayerBlock(blockPosition +1 ) && !Glc.map.IsStopPlayerBlock(blockPosition - mapBlockWidth+1)) {
          rect.x +=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_RIGHT_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
    return false;
  }

  protected boolean tryDownStep() {
    if (Glc.map.checkHardBlockCollision(blockPosition +  mapBlockWidth, rect)) {
      rect.y +=walkSpeed; // on avance
      int xDiff = Glc.map.getXdifference(blockPosition+ mapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition - 1 + mapBlockWidth) || Glc.map.IsStopPlayerBlock(blockPosition -1 )) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (Glc.map.IsStopPlayerBlock(blockPosition + 1 + mapBlockWidth)||Glc.map.IsStopPlayerBlock(blockPosition +1)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
      return true;
    } else {
      int xDiff = Glc.map.getXdifference(blockPosition+ mapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!Glc.map.IsStopPlayerBlock(blockPosition - 1) && !Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth-1)) {
          rect.x -=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!Glc.map.IsStopPlayerBlock(blockPosition +1 ) && !Glc.map.IsStopPlayerBlock(blockPosition + mapBlockWidth+1)) {
          rect.x +=1;
          blockPosition = Glc.map.getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_RIGHT_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
    return false;
  }

  protected SpriteAnimation DefineSpriteAnimationFromAction(CHARACTER_ACTION a) {
    SpriteAnimation  sa = new SpriteAnimation();
    /*
    cette partie doit être défini explicitement pour toutes les animations de chaque personnage
     switch (a) {
     case LOOK_FRONT_WAIT:
     case LOOK_LEFT_WAIT:
     case LOOK_RIGHT_WAIT:
     case LOOK_UP_WAIT:
     case LOOK_DOWN_WALK:
     case LOOK_LEFT_WALK:
     case LOOK_RIGHT_WALK:
     case LOOK_UP_WALK:
     case DIE:
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
     sa.addSprite(new Sprite(110));
     break;
     }
     */
    sa.addSprite(new Sprite(110));
    
    return sa;
  }

  public Sprite GetSpriteToRender() {
    return spriteToRender;
  }
}
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------------------------------------------------

public class BOMBERMAN extends BASE_CHARACTER {

  public BOMBERMAN(int blockPosition, int pxTileSize, int blockWidth) {
    super( blockPosition,  pxTileSize,  blockWidth);
    
  }
  public void stepFrame() {
    boolean bool = true;
    if (bControl) { // si le joueur a l'accès...
      if (gCtrl.left) {
        bool =  tryLeftStep();
      } else if (gCtrl.right) {
        bool = tryRightStep();
      } else if (gCtrl.up) {
        bool = tryUpStep();
      } else if (gCtrl.down) {
        bool = tryDownStep();
      } else if (gCtrl.a) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
      } else if (gCtrl.b) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.VICTORY);
      } else {
        WaitStance();
      }
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