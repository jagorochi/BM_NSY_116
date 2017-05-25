//public int gMapBlockWidth,gMapBlockHeight, gpxMapTileSize;

public class CHARACTERS_MANAGER {
  private ArrayList<PImage> lCharactersImages  = new ArrayList<PImage>();
  private int spriteWidth = 16;
  private int SpriteHeight = 32;
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private BOMBERMAN BM;

  private ArrayList<ArrayList<BASE_CHARACTER>> CharacterMapMatrix = new ArrayList<ArrayList<BASE_CHARACTER>>();
  private ArrayList<PENDING_BASE_CHARACTER> PendingCharactersForRemoval= new ArrayList<PENDING_BASE_CHARACTER>();
  private ArrayList<PENDING_BASE_CHARACTER> PendingCharactersForInclusion= new ArrayList<PENDING_BASE_CHARACTER>();
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
              BM = new BOMBERMAN( block); // on doit garder une reference pour le rendu de la map
              AppendCharacterForInclusion(block, BM);
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

  public void PermuteCharacterMapMatrixPosition(int FromBlock, int ToBlock, BASE_CHARACTER c) {
    AppendCharacterForRemoval(FromBlock, c);
    AppendCharacterForInclusion(ToBlock, c);
  }



  void AppendCharacterForInclusion(int block, BASE_CHARACTER o) {
    /* les objets ne peuvent être ajoutés dans la liste ObjectMapMatrix lorsque la boucle 
     stepFrame() s'execute sous peine de générer une exception..
     on enregistre alors les reference de ces objets pour être ajouté pour la "frame suivante".. 
     */
    // o.setController(this);
    PendingCharactersForInclusion.add(new PENDING_BASE_CHARACTER(block, o));
  }

  void IncludePendingCharacters() {
    // boucle appelé a la fin de stepFrame();
    for (PENDING_BASE_CHARACTER Pending_Character : PendingCharactersForInclusion) {
      CharacterMapMatrix.get(Pending_Character.block).add(Pending_Character.ref);
      Pending_Character.ref.setController(this);
    }
    PendingCharactersForInclusion.clear();
  }


  void AppendCharacterForRemoval(int block, BASE_CHARACTER o) {
    /* les objets ne peuvent être supprimé de la liste ObjectMapMatrix lorsque la boucle 
     stepFrame() s'execute sous peine de générer une exception..
     on enregistre alors les reference de ces objets pour être supprimés.. 
     */
    PendingCharactersForRemoval.add(new PENDING_BASE_CHARACTER(block, o));
  }

  void RemovePendingCharacters() {
    // boucle appelé a la fin de stepFrame();
    for (PENDING_BASE_CHARACTER Pending_Character : PendingCharactersForRemoval) {
      CharacterMapMatrix.get(Pending_Character.block).remove(Pending_Character.ref);
      Pending_Character.ref.setController(null);
    }
    PendingCharactersForRemoval.clear();
  }


  public void UpdateCharactersStepFrame() {
    for (ArrayList<BASE_CHARACTER> mapMatrix : CharacterMapMatrix) {
      for (BASE_CHARACTER o : mapMatrix) {
        o.stepFrame();
      }
    }
    RemovePendingCharacters(); // l'ordre à son importance..
    IncludePendingCharacters();
  }

  public void RenderCharacters() {
    for (ArrayList<BASE_CHARACTER> mapMatrix : CharacterMapMatrix) {
      for (BASE_CHARACTER o : mapMatrix) {
        Sprite s = o.GetSpriteToRender();
        image(lCharactersImages.get(s.TileID), s.xDecal, s.yDecal);
        if (gDebug) {
          stroke(100, 100, 100);
          rect(o.rect.x, o.rect.y, o.rect.h, o.rect.h);
          stroke(0, 0, 255);
          Rect r = getCoordinateFromBlockPosition(o.blockPosition);
          rect(r.x+1, r.y+1, r.w-2, r.h-2);
        }
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


  public ArrayList<BASE_OBJECT> getMapBlockPositionObjectList(int block) {
    return oParent.OManager.getMapBlockPositionObjectList(block);
  }

  public ArrayList<BASE_CHARACTER>getMapBlockPositionCharacterList(int block) {
    return CharacterMapMatrix.get(block);
  }

  boolean IsBlockOrObjectStoppingCharacterAtPosition(int nBlock, ENTITY_TYPE entity) {
    // cette fonction permet de savoir si dans une position matricielle donnée de la map se trouve un block bloquant pour le character. 
    return (Glc.OManager.IsObjectStoppingEntityAtPosition(nBlock, entity) || Glc.map.IsHardBlockStoppingEntityAtPosition(nBlock, entity));
  }

  public boolean isStoppingBlockOrObjectCollidingWithEntityRect(int CharacterBlock, int nBlock, Rect EntityRect, ENTITY_TYPE entity) {
    // cette fonction est différente de "IsBlockOrObjectStoppingCharacterAtPosition" car elle permet de verifier plus finement si le rectangle d'un bloc est en collision avec celui du joueur.
    return (Glc.map.isStoppingHardBlockCollidingWithEntityRect(nBlock, EntityRect, entity) || Glc.OManager.isStoppingObjectsCollidingWithEntityRect(CharacterBlock, EntityRect, entity, null));
  }

  public ArrayList<BASE_OBJECT> getTouchingObjectsWithCharacterRect(int block, Rect rect) {
    // cette fonction permet de savoir si un block sur lequel un personnage peut marcher.
    // ces block ont un "hitbox" plus réduit afin que la collision soit "visuellement"  plus marquée
    return oParent.OManager.getTouchingObjectsFromRect(block, rect);
  }


  boolean IsStoppingFlameMapBlock(int nBlock) {
    return Glc.map.IsHardBlockStoppingFlame(nBlock);
  }
  /*
  boolean IsStoppingEnemyMapBlock(int nBlock) {
   return Glc.map.IsHardBlockStoppingEnemy(nBlock);
   }
   */
  boolean IsBombDroppableOnMapBlock(int nBlock) {
    return Glc.map.IsHardBlockBombDroppable(nBlock);
  }

  public float getXdifference(int nBlock, float x) {
    return Glc.map.getXdifference(nBlock, x);
  }
  public float getYdifference(int nBlock, float y) {
    return Glc.map.getYdifference(nBlock, y);
  }


  public ArrayList<BASE_CHARACTER> getCollidingCharactersFromRect(int block, Rect rect) {
    ArrayList<BASE_CHARACTER> lst = new ArrayList<BASE_CHARACTER>();
    for (int yDecal = -1; yDecal <=1; yDecal++) {
      for (int xDecal = -1; xDecal <=1; xDecal++) {
        int nBlockDecal =  block + (yDecal * gMapBlockWidth) + xDecal;
        for (BASE_CHARACTER o : CharacterMapMatrix.get(nBlockDecal)) {
          if (isRectCollision(rect, o.rect)) {
            lst.add(o);
          }
        }
      }
    }
    return lst;
  }
}




public class BASE_CHARACTER {
  protected EnumMap<CHARACTER_ACTION, SpriteAnimation> lAnimation = new EnumMap<CHARACTER_ACTION, SpriteAnimation>(CHARACTER_ACTION.class);
  protected CHARACTER_ACTION previousAction = CHARACTER_ACTION.LOOK_FRONT_WAIT; // par défaut
  protected int frameCounter = 0;
  public int  blockPosition;
  protected boolean bControl = true;
  protected Rect rect ;
  protected float walkSpeed;
  protected Sprite spriteToRender;
  protected boolean kickingAbility;
  protected boolean IsKicking; // variable utilisée pour vérifier si l'utilisateur est en train de "kicker"..
  public CHARACTERS_MANAGER controller;
  protected  ArrayList<BASE_OBJECT> ActiveDroppedBombs;// liste des bombes droppées
  protected int flamePower;
  protected int DropBombCapacity;

  public BASE_CHARACTER(int blockPosition) {
    // on construit les animations
    this.blockPosition = blockPosition;

    ActiveDroppedBombs = new ArrayList<BASE_OBJECT>();

    rect = new Rect((blockPosition % gMapBlockWidth) * gpxMapTileSize, floor(blockPosition / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
    walkSpeed = 1.0;
    bControl = true;
    IsKicking = false;
    kickingAbility = false;
    spriteToRender = new Sprite(1, rect.x, rect.y, 0); // default..
    for (CHARACTER_ACTION Action : CHARACTER_ACTION.values()) {
      SpriteAnimation sa = DefineSpriteAnimationFromAction(Action);
      if (sa.MaxFrame == 0) {
        sa.rebuildFramesTiming();
      }
      lAnimation.put(Action, sa);
    }
  }

  public void setController(CHARACTERS_MANAGER controller) {
    this.controller = controller;
  }

  public void stepFrame() {
    // comportement & actions à définir dans les classes spécialisées
  }

  public void destruct() {
    controller.AppendCharacterForRemoval(blockPosition, this);
    controller = null;
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
    playSFX(SOUND_ID.BOMB_DROP1,0.5);
  }

  //-----------------------------------------------------------------------------------------------------------------------------
  protected void checkMapMatrixPermutation() {
    int newBlockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);  
    if (blockPosition !=  newBlockPosition) {
      controller.PermuteCharacterMapMatrixPosition(blockPosition, newBlockPosition, this);
      blockPosition = newBlockPosition;
    }
  }

  protected boolean tryRightStep() {
    Rect testRect = rect.move(DIRECTION.RIGHT, walkSpeed); // position a tester : on avance vers la droite
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition+1, testRect, ENTITY_TYPE.PLAYER)) { // si pas de block qui bloque dans la direction voulue (droite)
      rect = testRect; // on ecrase vu que le test a reussi//rect.x +=walkSpeed; // on avance vers la droite
      float yDiff = controller.getYdifference(blockPosition+1, rect.y); // est ce qu'on est tout de même bien dans l'axe du couloir ?
      if (yDiff < 0) { // si on est trop vers le bas
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition+1 + gMapBlockWidth, ENTITY_TYPE.PLAYER)
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, ENTITY_TYPE.PLAYER)) { // s'il y a un bloc juste en bas ou bas/droite
          if (abs(yDiff)< walkSpeed) { // si la distance est inférieure a la vitesse de marche
            rect.y -= abs(yDiff); // on se recale pile dans l'axe du couloir
          } else {
            rect.y -= walkSpeed; // on se recale progressivement à la vitesse de deplacement (vers le haut) -> le personnage de déplace vers la diagonale haut/droite
          }
        }
      } else if (yDiff>0) { // si on est trop vers le haut
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition+1 - gMapBlockWidth, ENTITY_TYPE.PLAYER) ||
          controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, ENTITY_TYPE.PLAYER)) { // s'il y a un block juste en haut ou haut/droite
          if (abs(yDiff)< walkSpeed) { // si la distance est inférieure à la vitesse de marche
            rect.y += abs(yDiff); // on se recale pile dans l'axe du couloir
          } else {
            rect.y += walkSpeed; // on se recale progressivement à la vitesse de deplacement (vers le bas) -> le personnage de déplace vers la diagonale bas/droite
          }
        }
      }
      checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
      updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK); // on mets a jour l'animation..
      return true; // action de déplacement réussi
    } else { //--------------------------------------------  le déplacement vers la droite est bloquée : on essaye de contourner..
      float yDiff = controller.getYdifference(blockPosition+1, rect.y); // est ce que l'on est plus vers le haut ou le bas du bloc
      if (yDiff < 0) { // on est plus vers le bas
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth+1, ENTITY_TYPE.PLAYER)) { // s'il n'y a aucun block juste au dessous + dessous/droite 
          rect.y +=1; // on descend
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_DOWN_WALK); // on mets à jour l'animation mais comme le personnage descend on change l'animation ou il marche vers le bas
          return true;// action de déplacement réussi
        }
      } else if (yDiff > 0) { // si on est plus vers le haut
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth+1, ENTITY_TYPE.PLAYER)) { // s'il n'y a un block juste au dessus + dessus/droite
          rect.y -=1; // on monte
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);// on mets à jour l'animation mais comme le personnage monte on change l'animation ou il marche vers le haut
          return true;// action de déplacement réussi
        }
      }
    }
    
    updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_RIGHT_WALK);// on marche sur place...
    // verification de l'action KICK !
    
    tryKickingObject(DIRECTION.RIGHT, 1.5);
    return false; // aucun déplacement...
  }

  private void tryKickingObject(DIRECTION direction, float force) {
    if (kickingAbility && IsKicking) {
      int blockDecal;
      switch (direction) {
      case LEFT:
        blockDecal =  -1;
        break;
      case RIGHT:
        blockDecal =  1;
        break;
      case UP:
        blockDecal =  -gMapBlockWidth;
        break;
      case DOWN:
        blockDecal = gMapBlockWidth;
        break;
      default:
        return;
      }
      
      for (BASE_OBJECT object : controller.getMapBlockPositionObjectList(blockPosition + blockDecal)) {
        if (object.kickable) {
        //if (object.category == OBJECT_CATEGORY.BOMB){
          
          if(object.tryKicking(direction, force)) playSFX(SOUND_ID.ZOL,1);
          
        }
      }
    }
  }




  protected boolean tryLeftStep() {
    // voir la fonction tryLeftRight pour plus de description.. cette methode est relativement similaire
    Rect testRect = rect.move(DIRECTION.LEFT, walkSpeed); // position a tester : on avance vers la droite
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition-1, testRect, ENTITY_TYPE.PLAYER)) {
      rect = testRect; // TEST réussi on écrase
      float yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition-1 + gMapBlockWidth, ENTITY_TYPE.PLAYER)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, ENTITY_TYPE.PLAYER)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff); // +
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1 - gMapBlockWidth, ENTITY_TYPE.PLAYER)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition  - gMapBlockWidth, ENTITY_TYPE.PLAYER)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y += abs(yDiff);
          } else {
            rect.y += walkSpeed;
          }
        }
      }
      checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
      return true;
    } else {
      float yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) { // plus bas
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth-1, ENTITY_TYPE.PLAYER)) {
          rect.y +=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth-1, ENTITY_TYPE.PLAYER)) {
          rect.y -=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
    // verification de l'action KICK !
    tryKickingObject(DIRECTION.LEFT, 1.5);
    return false;
  }

  protected boolean tryUpStep() {
    // voir la fonction tryLeftRight pour plus de description.. cette methode est relativement similaire
    Rect testRect = rect.move(DIRECTION.UP, walkSpeed); // position a tester : on avance vers la droite
    if ( !controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition- gMapBlockWidth, testRect, ENTITY_TYPE.PLAYER)) {
      rect = testRect; // TEST réussi on écrase
      float xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1 - gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1, ENTITY_TYPE.PLAYER)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + 1 - gMapBlockWidth, ENTITY_TYPE.PLAYER)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, ENTITY_TYPE.PLAYER)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
      return true;
    } else {
      float xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth-1, ENTITY_TYPE.PLAYER)) {
          rect.x -=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth+1, ENTITY_TYPE.PLAYER)) {
          rect.x +=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_RIGHT_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_UP_WALK);
    // verification de l'action KICK !
    tryKickingObject(DIRECTION.UP, 1.5);
    return false;
  }

  protected boolean tryDownStep() {
    // voir la fonction tryLeftRight pour plus de description.. cette methode est relativement similaire
    Rect testRect = rect.move(DIRECTION.DOWN, walkSpeed); // position a tester : on avance vers la droite
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition +  gMapBlockWidth, testRect, ENTITY_TYPE.PLAYER)) {
      rect = testRect; // TEST réussi on écrase
      float xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1 + gMapBlockWidth, ENTITY_TYPE.PLAYER) 
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1, ENTITY_TYPE.PLAYER)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + 1 + gMapBlockWidth, ENTITY_TYPE.PLAYER)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, ENTITY_TYPE.PLAYER)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x -= abs(xDiff);
          } else {
            rect.x -= walkSpeed;
          }
        }
      }
      checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
      updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
      return true;
    } else {
      float xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth-1, ENTITY_TYPE.PLAYER)) {
          rect.x -=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, ENTITY_TYPE.PLAYER) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth+1, ENTITY_TYPE.PLAYER)) {
          rect.x +=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_RIGHT_WALK);
          return true;
        }
      }
    }
    updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
    // verification de l'action KICK !
    tryKickingObject(DIRECTION.DOWN, 1.5);
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