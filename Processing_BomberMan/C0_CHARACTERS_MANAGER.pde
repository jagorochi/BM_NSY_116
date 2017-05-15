//public int gMapBlockWidth,gMapBlockHeight, gpxMapTileSize;

public class CHARACTERS_MANAGER {
  private ArrayList<PImage> lCharactersImages  = new ArrayList<PImage>();
  private int spriteWidth = 16;
  private int SpriteHeight = 32;
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private BOMBERMAN BM;

  private ArrayList<ArrayList<BASE_CHARACTER>> CharacterMapMatrix = new ArrayList<ArrayList<BASE_CHARACTER>>();
  private ArrayList<BASE_CHARACTER_FOR_REMOVAL> PendingCharactersForRemoval= new ArrayList<BASE_CHARACTER_FOR_REMOVAL>();
  private GLC oParent;

  public CHARACTERS_MANAGER(GLC oParent, PImage tileMapImg, String strMapPath) {
    this.oParent = oParent;
    // recuperation des sprites de taille 16*32 ------------------------------------------------------------------------------------------------------------
    int totalSprite = 172; // nombre total de sprite "character" (bomberman + monstres)
    spriteWidth = gpxMapTileSize;
    SpriteHeight = gpxMapTileSize * 2;
    int TilePerWidth = tileMapImg.width / spriteWidth; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile   */
    int yTileMapCharactersSpriteDecal = gpxMapTileSize*9; // les sprites de bomberman se trouve à une position plus basse dans l'image. (9 tuiles plus bas)

    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerWidth) * spriteWidth; // position x et y dans l'image source tileMap
      int ySource = (floor(incr1 / TilePerWidth) * SpriteHeight) + yTileMapCharactersSpriteDecal;
      PImage i = createImage(spriteWidth, SpriteHeight, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, spriteWidth, SpriteHeight, 0, 0, spriteWidth, SpriteHeight); // on copie le contenu
      lCharactersImages.add(i); // on stocke chaque miniature...
    }

    // recuperation des sprites de taille 24*32 ------------------------------------------------------------------------------------------------------------
    totalSprite = 39; // nombre total de sprite large
    spriteWidth = gpxMapTileSize / 2 * 3; // 1/3 plus large..
    SpriteHeight = gpxMapTileSize * 2;
    TilePerWidth = floor(tileMapImg.width / spriteWidth); // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    yTileMapCharactersSpriteDecal = gpxMapTileSize*19;

    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerWidth) * spriteWidth; // position x et y dans l'image source tileMap
      int ySource = (floor(incr1 / TilePerWidth) * SpriteHeight) + yTileMapCharactersSpriteDecal;
      PImage i = createImage(spriteWidth, SpriteHeight, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, spriteWidth, SpriteHeight, 0, 0, spriteWidth, SpriteHeight); // on copie le contenu
      lCharactersImages.add(i); // on stocke chaque miniature...
    }
    // declaration de la liste contenant les objets

    // spawn des characters du niveau------------------------------------------------------------------------------------------------------------
    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    //int gMapBlockHeight = strLevelMapInit.length;
    ///int gMapBlockWidth = split(strLevelMapInit[0], ';').length;

    int maxMapBlock = gMapBlockHeight * gMapBlockWidth;
    for (int incr = 0; incr < maxMapBlock; incr++) {
      CharacterMapMatrix.add(new ArrayList<BASE_CHARACTER>());
    }

    for (int incr1 = 0; incr1 < gMapBlockHeight; incr1++) {
      String[] strMapLineContent = split(strLevelMapInit[incr1], ";");
      for ( int incr2 = 0; incr2 < gMapBlockWidth; incr2++) {
        if (strMapLineContent[incr2].contains("'")) {
          String[] items = split(strMapLineContent[incr2], "'");
          for ( String item : items) {
            switch(item) {
            case "111": // bomberman
              int block = (incr1*gMapBlockWidth)+incr2;
              BM = new BOMBERMAN(this, block); // on doit garder une reference pour le rendu de la map
              addCharacter(block, BM);
              // addObject(BM);
              println("creation de l'objet bomberman :) sur le block n° " + (incr1*gMapBlockHeight)+incr2);
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

  public void MoveCharacter(int block, BASE_CHARACTER c) {
    addCharacter(block, c);
    AppendCharacterForRemoval(block, c);
  }

  public void addCharacter(int block, BASE_CHARACTER c) {
    CharacterMapMatrix.get(block).add(c);
    //ID++;
    //return ID;
  }




  void AppendCharacterForRemoval(int block, BASE_CHARACTER o) {
    /* les objets ne peuvent être supprimé de la liste ObjectMapMatrix lorsque la boucle 
     stepFrame() s'execute sous peine de générer une exception..
     on enregistre alors les reference de ces objets pour être supprimés.. 
     */
    PendingCharactersForRemoval.add(new BASE_CHARACTER_FOR_REMOVAL(block, o));
  }

  void RemovePendingCharacters() {
    // boucle appelé a la fin de stepFrame();
    for (BASE_CHARACTER_FOR_REMOVAL o : PendingCharactersForRemoval) {
      CharacterMapMatrix.get(o.block).remove(o.object);
    }
    PendingCharactersForRemoval.clear();
  }


  public void UpdateCharactersStepFrame() {
    for (ArrayList<BASE_CHARACTER> mapMatrix : CharacterMapMatrix) {
      for (BASE_CHARACTER o : mapMatrix) {
        o.stepFrame();
      }
    }
    RemovePendingCharacters();
  }

  public void RenderCharacters() {
    for (ArrayList<BASE_CHARACTER> mapMatrix : CharacterMapMatrix) {
      for (BASE_CHARACTER o : mapMatrix) {
        Sprite s = o.GetSpriteToRender();
        image(lCharactersImages.get(s.TileID), s.xDecal, s.yDecal);
      }
    }
  }

  public Rect getPlayerRect() {
    return BM.rect;
  }
  /*-----------------------------------------------------------------------------------------------------
   definition de l'interface d'accès aux autre gestionnaires d'objet : map et Object Manager
   isDroppingBombOk(int blockID)
   addItem()
   removeItem()
   getTouchingItemList();
   isRectPositionCollisionOK() // pour checker sur la map et directement dans les blocks "stoppe" le joueur..
   
   -----------------------------------------------------------------------------------------------------*/
  public void addObject(int block, BASE_OBJECT o) { // ajoute un objet
    oParent.OManager.AppendObjectForInclusion(block, o);
  }
  public void RemoveObject(int block, BASE_OBJECT o) { // ajoute un objet
    oParent.OManager.AppendObjectForRemoval( block, o);
  }

  public ArrayList<BASE_OBJECT> getTouchingObjectList(int block, Rect rect) {
    return oParent.OManager.getTouchingObjectList(block, rect);
  }
  public ArrayList<BASE_OBJECT> getMapBlockPositionObjectList(int block) {
    return oParent.OManager.getMapBlockPositionObjectList(block);
  }

  boolean IsStoppingPlayerMapBlock(int nBlock) {
    return Glc.map.IsStoppingPlayerBlock(nBlock);
  }

  boolean IsStoppingFlameMapBlock(int nBlock) {
    return Glc.map.IsStoppingFlameBlock(nBlock);
  }

  boolean IsStoppingEnemyMapBlock(int nBlock) {
    return Glc.map.IsStoppingEnemyBlock(nBlock);
  }

  boolean IsBombDroppableOnMapBlock(int nBlock) {
    return Glc.map.IsBombDroppableOnBlock(nBlock);
  }

  public int getXdifference(int nBlock, int x) {
    return Glc.map.getXdifference(nBlock, x);
  }
  public int getYdifference(int nBlock, int y) {
    return Glc.map.getYdifference(nBlock, y);
  }
  
  public boolean checkHardBlockCollision(int nBlock, Rect playerRect){
    return Glc.map.checkHardBlockCollision(nBlock, playerRect);
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
  //protected int gMapBlockWidth;
  //protected int gpxMapTileSize;
  public CHARACTERS_MANAGER controller;
  private  ArrayList<BASE_OBJECT> ActiveDroppedBombs;// liste des bombes droppées
  protected int flamePower;
  protected int DropBombCapacity;

  public BASE_CHARACTER(CHARACTERS_MANAGER controller, int blockPosition) {
    // on construit les animations
    this.controller = controller;
    this.blockPosition = blockPosition;

    ActiveDroppedBombs = new ArrayList<BASE_OBJECT>();

    rect = new Rect((blockPosition % gMapBlockWidth) * gpxMapTileSize, floor(blockPosition / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
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

  void DeleteBombRef(BASE_OBJECT o) {
    ActiveDroppedBombs.remove(o);
  }

  protected void tryDropBomb() {
    // est ce que je n'ai pas atteint ma capacité ?
    if (DropBombCapacity <= ActiveDroppedBombs.size()) {
      return;
    }
    // est ce que que je peux déposer une bombe sur cette dalle ?
    if (!controller.IsBombDroppableOnMapBlock(blockPosition)) {
      return;
    }
    // est ce que que je peux déposer une bombe sur cette dalle ?
    ArrayList<BASE_OBJECT> lObjects = controller.getMapBlockPositionObjectList(blockPosition);
    for (BASE_OBJECT object : lObjects) {
      if (object.bombDrop == false) {
        return;
      }
    }
    // on droppe une bombe :)
    
    int duration = 180;
    BASE_OBJECT bomb = new BOMB(blockPosition, this, flamePower, duration);
    ActiveDroppedBombs.add(bomb); // on retient la référence de cette bombe..
    controller.addObject(blockPosition, bomb);
  }
  
  //-----------------------------------------------------------------------------------------------------------------------------

  protected boolean tryRightStep() {
    if ( controller.checkHardBlockCollision(blockPosition+1, rect)) {
      rect.x +=walkSpeed; 
      int yDiff = controller.getYdifference(blockPosition+1, rect.y);
      if (yDiff < 0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition+1 + gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff);
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition+1 - gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y += abs(yDiff);
          } else {
            rect.y += walkSpeed;
          }
        }
      }
      blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK);
      return true;
    } else {
      int yDiff = controller.getYdifference(blockPosition+1, rect.y);
      if (yDiff < 0) {
        if (!controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth) && !controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth+1)) {
          rect.y +=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {
        if (!controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth) && !controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth+1)) {
          rect.y -=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK);// on marche sur place...
    return false;
  }

  protected boolean tryLeftStep() {
    if ( controller.checkHardBlockCollision(blockPosition-1, rect)) {
      rect.x -=walkSpeed; // on avance
      int yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition-1 + gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff); // +
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition -1 - gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition  - gMapBlockWidth)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y += abs(yDiff);
          } else {
            rect.y += walkSpeed;
          }
        }
      }
      blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
      return true;
    } else {
      int yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) { // plus bas

        if (!controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth) && !controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth-1)) {
          rect.y +=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {

        if (!controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth) && !controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth-1)) {
          rect.y -=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
    return false;
  }

  protected boolean tryUpStep() {
    if ( controller.checkHardBlockCollision(blockPosition- gMapBlockWidth, rect)) {
      rect.y -=walkSpeed; // on avance
      int xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition - 1 - gMapBlockWidth) || controller.IsStoppingPlayerMapBlock(blockPosition -1 )) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition + 1 - gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition +1)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
      return true;
    } else {
      int xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsStoppingPlayerMapBlock(blockPosition - 1) && !controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth-1)) {
          rect.x -=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsStoppingPlayerMapBlock(blockPosition +1 ) && !controller.IsStoppingPlayerMapBlock(blockPosition - gMapBlockWidth+1)) {
          rect.x +=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_RIGHT_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
    return false;
  }

  protected boolean tryDownStep() {
    if (controller.checkHardBlockCollision(blockPosition +  gMapBlockWidth, rect)) {
      rect.y +=walkSpeed; // on avance
      int xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition - 1 + gMapBlockWidth) || controller.IsStoppingPlayerMapBlock(blockPosition -1 )) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsStoppingPlayerMapBlock(blockPosition + 1 + gMapBlockWidth)||controller.IsStoppingPlayerMapBlock(blockPosition +1)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
      return true;
    } else {
      int xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsStoppingPlayerMapBlock(blockPosition - 1) && !controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth-1)) {
          rect.x -=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsStoppingPlayerMapBlock(blockPosition +1 ) && !controller.IsStoppingPlayerMapBlock(blockPosition + gMapBlockWidth+1)) {
          rect.x +=1;
          blockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);
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
  public BOMBERMAN(CHARACTERS_MANAGER controller, int blockPosition) {
    super(controller, blockPosition);

    flamePower = 3;
    DropBombCapacity = 2;
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
      } else {
        WaitStance();
      }
      if (gCtrl.a) {
        tryDropBomb(); //updateSpriteAnimationFrame(CHARACTER_ACTION.DIE);
      } 
      if (gCtrl.b) {
        updateSpriteAnimationFrame(CHARACTER_ACTION.VICTORY);
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