//public int gMapBlockWidth,gMapBlockHeight, gpxMapTileSize;

public class CHARACTERS_MANAGER {
  private ArrayList<PImage> lCharactersImages  = new ArrayList<PImage>();
  private int spriteWidth = 16;
  private int SpriteHeight = 32;
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private BOMBERMAN BM;
  private ArrayList<Integer> charactersReadyForRespawnPositions = new ArrayList<Integer>(); //
  private ArrayList<String> charactersReadyForRespawnID = new ArrayList<String>();
  private ArrayList<ArrayList<BASE_CHARACTER>> CharacterMapMatrix = new ArrayList<ArrayList<BASE_CHARACTER>>();
  private ArrayList<PENDING_BASE_CHARACTER> PendingCharactersForRemoval= new ArrayList<PENDING_BASE_CHARACTER>();
  private ArrayList<PENDING_BASE_CHARACTER> PendingCharactersForInclusion= new ArrayList<PENDING_BASE_CHARACTER>();
  private int ActiveEnemiesCount;
  private GLC oParent;

  public CHARACTERS_MANAGER(GLC oParent, PImage tileMapImg) {
    this.oParent = oParent;
    // recuperation des sprites de taille 16*32 ------------------------------------------------------------------------------------------------------------
    int totalSprite = 200; // nombre total de sprite "character" (bomberman + monstres)
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
  }

  public void ClearSession() {
    CharacterMapMatrix.clear();
    charactersReadyForRespawnPositions.clear();
    charactersReadyForRespawnID.clear();
  }


  public void initSession(String strMapPath, boolean bResetPlayer) {
    // spawn des characters du niveau------------------------------------------------------------------------------------------------------------
    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    //int gMapBlockHeight = strLevelMapInit.length;
    ///int gMapBlockWidth = split(strLevelMapInit[0], ';').length;
    ActiveEnemiesCount = 0;
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
            int block = (incr1*gMapBlockWidth)+incr2;
            switch(item) {
            case "111": // bomberman
              if (bResetPlayer || BM == null) {
                BM = new BOMBERMAN( block, item); // personnage initialisé avec propriétés de bases.
              } else { // on conserve les propriétés bonus accumulés
                BM.blockPosition = block; // on repositionne le joueur sur le bloc prévu pour cette map
                BM.rect = getCoordinateFromBlockPosition(block); // on recalcul son "rect"
                BM.previousAction = CHARACTER_ACTION.LOOK_DOWN_WALK; // il regarde vers le bas
                BM.bControl = true; // on redonne le controle au joueur.
              }
              AppendCharacterForInclusion(block, BM); // on l'ajoute dans la liste des positions..
              break;
            case "112": // BUDDY // Sprite disponible mais personnage non implémenté
              break;
            case "113": // BOMBAS // Sprite disponible mais personnage non implémenté
              break;
            case "114": // BEAR // Sprite disponible mais personnage non implémenté
              break;
            case "115": // PACMAN
              ActiveEnemiesCount++;
              AppendCharacterForInclusion(block, new PACMAN(block, item));
              break;
            case "116": // CHICKEN
              ActiveEnemiesCount++;
              AppendCharacterForInclusion(block, new CHICKEN(block, item));
              break;
            }
          }
        }
      }
    }
  }

  public void AddDeadCharacterReadyForRespawn(int block, String ID) {
    charactersReadyForRespawnPositions.add(block);
    charactersReadyForRespawnID.add(ID);
    ActiveEnemiesCount--;
    if (ActiveEnemiesCount == 0) Glc.confirmAllDeadMeat(true); // si tous les enemies sont morts alors on prévient le controlleur de la partie.
  }

  public void RespawnAllDeadCharacters() {
    for (int incr= 0; incr < charactersReadyForRespawnPositions.size(); incr++) {
      int block = charactersReadyForRespawnPositions.get(incr);
      String ID = charactersReadyForRespawnID.get(incr);
      ActiveEnemiesCount++;
      switch (ID) {
      case "112": // BUDDY // Sprite disponible mais personnage non implémenté
        break;
      case "113": // BOMBAS // Sprite disponible mais personnage non implémenté
        break;
      case "114": // BEAR // Sprite disponible mais personnage non implémenté
        break;
      case "115": // PACMAN // identique au CHICKEN mange les bombes lorsqu'il passe dessus :-/
        PACMAN p = new PACMAN(block, ID);
        AppendCharacterForInclusion(block, p);
        p.SetInvulnerability(120);
        break;
      case "116": // CHICKEN // enemie de base : se déplace bettement.
        CHICKEN c = new CHICKEN(block, ID);
        AppendCharacterForInclusion(block, c);
        c.SetInvulnerability(120);
        break;
      }
    }
    Glc.confirmAllDeadMeat(false);
    charactersReadyForRespawnPositions.clear();
    charactersReadyForRespawnID.clear();
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
        if (!o.isSpriteTinted) {
          image(lCharactersImages.get(s.TileID), s.xDecal, s.yDecal);
        } else {
          PImage processedImg = lCharactersImages.get(s.TileID).get(); // on obtient une copie du sprite a traiter...
          switch(o.spriteTint) {
          case WHITE:
            processedImg.blend( 0, 0, processedImg.width, processedImg.height, 0, 0, processedImg.width, processedImg.height, ADD);
            processedImg.blend( 0, 0, processedImg.width, processedImg.height, 0, 0, processedImg.width, processedImg.height, ADD);
            break;
          case RED:
            tint(255, 0, 0);
            break;
          case GREEN : 
            tint(0, 255, 0);
            break;
          case BLUE:
            tint(0, 0, 255);
            break;
          }
          image(processedImg, s.xDecal, s.yDecal);
          noTint();
        }

        if (gDebug) {
          stroke(100, 100, 100);
          rect(o.rect.x, o.rect.y, o.rect.h, o.rect.h);
          stroke(0, 0, 255);
          Rect r = getCoordinateFromBlockPosition(o.blockPosition);
          rect(r.x+1, r.y+1, r.w-2, r.h-2);

          /*stroke(255,0,0);
           rect(o.hitBox.x, o.hitBox.y, o.hitBox.h, o.hitBox.h);*/
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

  public boolean isStoppingBlockOrObjectCollidingWithEntityRect(int CharacterBlock, int nBlock, Rect EntityRect, ENTITY_TYPE entity, boolean excludeBomb) {
    // cette fonction est différente de "IsBlockOrObjectStoppingCharacterAtPosition" car elle permet de verifier plus finement si le rectangle d'un bloc est en collision avec celui du joueur.
    return (Glc.map.isStoppingHardBlockCollidingWithEntityRect(nBlock, EntityRect, entity) || Glc.OManager.isStoppingObjectsCollidingWithEntityRect(CharacterBlock, EntityRect, entity, null, excludeBomb));
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

  public void levelEndingEvent(LEVEL_END_EVENT event) {
    Glc.LevelEndingEvent(event);
  }
}

public class BASE_CHARACTER {
  protected EnumMap<CHARACTER_ACTION, SpriteAnimation> lAnimation = new EnumMap<CHARACTER_ACTION, SpriteAnimation>(CHARACTER_ACTION.class);
  protected CHARACTER_ACTION previousAction = CHARACTER_ACTION.LOOK_FRONT_WAIT; // par défaut
  protected int spawnBlockPosition;
  public boolean isSpriteTinted;
  protected SPRITE_TINT spriteTint = SPRITE_TINT.WHITE;
  protected int frameCounter = 0;
  protected ENTITY_TYPE entityType;
  public int  blockPosition;
  protected boolean bControl = true;
  protected Rect rect; //,hitBox ;
  protected float walkSpeed;
  protected Sprite spriteToRender;
  protected boolean kickingAbility;
  protected boolean IsKicking; // variable utilisée pour vérifier si l'utilisateur est en train de "kicker"..
  public CHARACTERS_MANAGER controller;
  protected  ArrayList<BASE_OBJECT> ActiveDroppedBombs;// liste des bombes droppées
  protected int flamePower;
  protected boolean walkOverBomb;
  protected int DropBombCapacity;
  private int destructCountDown = -1;
  protected int IA_IdleCount = 60; // variable utilisée pour la gestion de l'IA
  protected DIRECTION IA_direction = DIRECTION.NEUTRAL;
  protected int invulnerabilityDuration = 0;
  private int RedDyingFlash = 0;
  private String ID;

  public BASE_CHARACTER(int blockPosition, String ID) {
    // on construit les animations
    this.ID = ID;
    this.blockPosition = blockPosition;
    spawnBlockPosition = blockPosition;
    ActiveDroppedBombs = new ArrayList<BASE_OBJECT>();
    rect = new Rect((blockPosition % gMapBlockWidth) * gpxMapTileSize, floor(blockPosition / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
    // this.hitBox = new Rect(rect.x+6, rect.y+6, rect.w-12, rect.h-12);// le rectangle de collision est toujours plus petit..
    walkSpeed = 1.0;
    bControl = true;
    IsKicking = false;
    kickingAbility = false;
    walkOverBomb = false;
    isSpriteTinted = false;
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
    if (destructCountDown>-1) {
      destructCountDown--;
      if (destructCountDown == 0) {
        destruct();
      }
    }

    if (invulnerabilityDuration>0) {
      invulnerabilityDuration--;
      if (invulnerabilityDuration % 15 > 7) { /// clignotement du sprite...
        isSpriteTinted = true;
      } else {
        isSpriteTinted = false;
      }
    }

    if (RedDyingFlash>0) {
      RedDyingFlash--;
      if (RedDyingFlash % 15 > 7) { /// clignotement du sprite...
        isSpriteTinted = true;
      } else {
        isSpriteTinted = false;
      }
    }
  }

  public void SetDectructCountDown(int destructCountDown) {
    this.destructCountDown = destructCountDown;
    RedDyingFlash = 120;
    spriteTint = SPRITE_TINT.RED;
  }

  public void destruct() {
    controller.AddDeadCharacterReadyForRespawn(spawnBlockPosition, ID);
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

  void DeleteBombRef(BASE_OBJECT o) { // appelé par l'objet bomb lorsqu'une bombe droppée est supprimé de la map.
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

    int duration = 160;
    BASE_OBJECT bomb = new BOMB(blockPosition, this, flamePower, duration);
    ActiveDroppedBombs.add(bomb); // on retient la référence de cette bombe..
    controller.addObject(blockPosition, bomb);
    gSound.playSFX(SOUND_ID.BOMB_DROP1, 0.5);
  }

  //
  protected void SetInvulnerability(int duration) {
    invulnerabilityDuration = duration;
    spriteTint = SPRITE_TINT.WHITE; // les sprites sont tintés en blanc lorsqu'invincible
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
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition+1, testRect, entityType, walkOverBomb)) { // si pas de block qui bloque dans la direction voulue (droite)
      rect = testRect; // on ecrase vu que le test a reussi//rect.x +=walkSpeed; // on avance vers la droite
      float yDiff = controller.getYdifference(blockPosition+1, rect.y); // est ce qu'on est tout de même bien dans l'axe du couloir ?
      if (yDiff < 0) { // si on est trop vers le bas
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition+1 + gMapBlockWidth, entityType)
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, entityType)) { // s'il y a un bloc juste en bas ou bas/droite
          if (abs(yDiff)< walkSpeed) { // si la distance est inférieure a la vitesse de marche
            rect.y -= abs(yDiff); // on se recale pile dans l'axe du couloir
          } else {
            rect.y -= walkSpeed; // on se recale progressivement à la vitesse de deplacement (vers le haut) -> le personnage de déplace vers la diagonale haut/droite
          }
        }
      } else if (yDiff>0) { // si on est trop vers le haut
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition+1 - gMapBlockWidth, entityType) ||
          controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, entityType)) { // s'il y a un block juste en haut ou haut/droite
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
      float xDiff =  getCoordinateFromBlockPosition(blockPosition).x - rect.x;
      if (xDiff < walkSpeed) {
        rect.x += xDiff;
      }
      float yDiff = controller.getYdifference(blockPosition+1, rect.y); // est ce que l'on est plus vers le haut ou le bas du bloc
      if (yDiff < 0) { // on est plus vers le bas
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth+1, entityType)) { // s'il n'y a aucun block juste au dessous + dessous/droite 
          rect.y +=1; // on descend
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame(CHARACTER_ACTION.LOOK_DOWN_WALK); // on mets à jour l'animation mais comme le personnage descend on change l'animation ou il marche vers le bas
          return true;// action de déplacement réussi
        }
      } else if (yDiff > 0) { // si on est plus vers le haut
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth+1, entityType)) { // s'il n'y a un block juste au dessus + dessus/droite
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

          if (object.tryKicking(direction, force)) gSound.playSFX(SOUND_ID.ZOL, 1);
        }
      }
    }
  }




  protected boolean tryLeftStep() {
    // voir la fonction tryLeftRight pour plus de description.. cette methode est relativement similaire
    Rect testRect = rect.move(DIRECTION.LEFT, walkSpeed); // position a tester : on avance vers la droite
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition-1, testRect, entityType, walkOverBomb)) {
      rect = testRect; // TEST réussi on écrase
      float yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition-1 + gMapBlockWidth, entityType)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, entityType)) {
          if (abs(yDiff)< walkSpeed) {
            rect.y -= abs(yDiff); // +
          } else {
            rect.y -= walkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1 - gMapBlockWidth, entityType)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition  - gMapBlockWidth, entityType)) {
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
      float xDiff =  rect.x -  getCoordinateFromBlockPosition(blockPosition).x;
      if (xDiff < walkSpeed) {
        rect.x -= xDiff;
      }

      float yDiff = controller.getYdifference(blockPosition-1, rect.y);
      if (yDiff < 0) { // plus bas
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth-1, entityType)) {
          rect.y +=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_DOWN_WALK);
          return true;
        }
      } else if (yDiff > 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth-1, entityType)) {
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
    if ( !controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition- gMapBlockWidth, testRect, entityType, walkOverBomb)) {
      rect = testRect; // TEST réussi on écrase
      float xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1 - gMapBlockWidth, entityType) 
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1, entityType)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + 1 - gMapBlockWidth, entityType)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, entityType)) {
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
      float yDiff =  rect.y -  getCoordinateFromBlockPosition(blockPosition).y;
      if (yDiff < walkSpeed) {
        rect.y -= yDiff;
      }

      float xDiff = controller.getXdifference(blockPosition- gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth-1, entityType)) {
          rect.x -=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - gMapBlockWidth+1, entityType)) {
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
    if (!controller.isStoppingBlockOrObjectCollidingWithEntityRect(blockPosition, blockPosition +  gMapBlockWidth, testRect, entityType, walkOverBomb)) {
      rect = testRect; // TEST réussi on écrase
      float xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1 + gMapBlockWidth, entityType) 
          || controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition -1, entityType)) {
          if (abs(xDiff)< walkSpeed) {
            rect.x += abs(xDiff); // +
          } else {
            rect.x += walkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + 1 + gMapBlockWidth, entityType)
          ||controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, entityType)) {
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
      float yDiff =  getCoordinateFromBlockPosition(blockPosition).y - rect.y  ; //
      if (yDiff < walkSpeed) {
        rect.y += yDiff;
      }


      float xDiff = controller.getXdifference(blockPosition+ gMapBlockWidth, rect.x);
      if (xDiff > 0) { 
        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition - 1, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth-1, entityType)) {
          rect.x -=1;
          checkMapMatrixPermutation(); // comme l'action de déplacement à réussi et que le Rect du Character a été modifié il est possible qu'il est changé de block sur la matrice de la map
          updateSpriteAnimationFrame( CHARACTER_ACTION.LOOK_LEFT_WALK);
          return true;
        }
      } else if (xDiff < 0) {

        if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition +1, entityType) 
          && !controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + gMapBlockWidth+1, entityType)) {
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

  protected boolean isTouchingDeadlyObjects() {
    for (BASE_OBJECT o : controller.getTouchingObjectsWithCharacterRect(blockPosition, rect)) {
      switch (o.category) {
      case DEADLY :
        return true;
      case EXIT_DOOR:
        if (entityType == ENTITY_TYPE.PLAYER) {
          updateSpriteAnimationFrame(CHARACTER_ACTION.VICTORY);
          bControl = false;
          controller.levelEndingEvent(LEVEL_END_EVENT.DOOR_EXITED);
        }
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
          gSound.playSFX(SOUND_ID.ONE_UP, 1);
          break;
        case "KICK":
          kickingAbility = true;
          break;
        case "REMOTE":

          break;
        }

        gSound.playSFX(SOUND_ID.ITEM_GET, 1);
        controller.RemoveObject(o.block, o);

        break;
      default:
        break;
      }
    }
    return false;
  }
  protected boolean isTouchingDeadlyEnemy() {
    Rect hitBox = new Rect(rect.x+6, rect.y+6, rect.w-12, rect.h-12);
    for (BASE_CHARACTER ch : controller.getCollidingCharactersFromRect(blockPosition, hitBox)) {
      if (ch.entityType == ENTITY_TYPE.ENEMY) {
        return true;
      }
    }
    return false;
  }


  protected DIRECTION IA_getNewRandomAvailableDirection() {

    DIRECTION newDir = DIRECTION.valueOf((int) random(4)); // nouvelle direction aléatoire
    for (int incr = 0; incr < 4; incr++) {
      if (!controller.IsBlockOrObjectStoppingCharacterAtPosition(blockPosition + getDirectionMapDecalage(newDir), entityType)) { // si cette nouvelle direction a la voie libre
        return newDir; //on y go
      } else {
        newDir = IA_nextDirection(newDir);
      }
    }
    return DIRECTION.NEUTRAL;
  }

  protected DIRECTION IA_nextDirection(DIRECTION d) {
    switch (d) {
    case UP :
      return DIRECTION.LEFT;
    case LEFT : 
      return DIRECTION.RIGHT;
    case RIGHT :
      return DIRECTION.DOWN;
    case DOWN :
      return DIRECTION.UP;
    default:
      return DIRECTION.NEUTRAL;
    }
  }

  protected boolean IA_tryDirectionStep() {
    boolean bool;
    switch (IA_direction) {
    case UP :
      bool = tryUpStep();
      break;
    case LEFT : 
      bool =  tryLeftStep();
      break;
    case RIGHT :
      bool = tryRightStep();
      break;
    case DOWN :
      bool = tryDownStep();
      break;
    default:
      bool = false;
    }
    return bool;
  }

  protected SpriteAnimation DefineSpriteAnimationFromAction(CHARACTER_ACTION a) {
    SpriteAnimation  sa = new SpriteAnimation();
    sa.addSprite(new Sprite(110));
    return sa;
  }

  public Sprite GetSpriteToRender() {
    if (isSpriteTinted) {
    }
    return spriteToRender;
  }
}