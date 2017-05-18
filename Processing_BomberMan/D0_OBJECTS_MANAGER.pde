//public int gMapBlockWidth,gMapBlockHeight, gpxMapTileSize;


public class OBJECTS_MANAGER {
  private ArrayList<PImage> lObjectTilesImages  = new ArrayList<PImage>();
  //private int gpxMapTileSize; // taille des tuiles en pixels (carré donc 16*16)
  //private HashMap<Integer,MAP_OBJECT> OBJECTS  = new HashMap<Integer,MAP_OBJECT>();
  ///private ArrayList<BASE_OBJECT> OBJECTS  = new ArrayList<BASE_OBJECT>();
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private ArrayList<ArrayList<BASE_OBJECT>> ObjectMapMatrix = new ArrayList<ArrayList<BASE_OBJECT>>();

  private ArrayList<PENDING_BASE_OBJECT> PendingObjectsForRemoval = new ArrayList<PENDING_BASE_OBJECT>();
  private ArrayList<PENDING_BASE_OBJECT> PendingObjectsForInclusion = new ArrayList<PENDING_BASE_OBJECT>();

  private GLC oParent;
  //private int gMapBlockWidth, gMapBlockHeight;
  private int TilePerMapImage;
  public OBJECTS_MANAGER(GLC oParent, PImage tileMapImg, String strMapPath) {
    this.oParent = oParent;

    TilePerMapImage = 40; // FIXED tileMapImg.width / gpxMapTileSize; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    int totalSprite = 79;// codé en dur
    int pxObjectDecal = 5 * gpxMapTileSize; // a partir du 6ème bloc

    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerMapImage) * gpxMapTileSize; // position x et y dans l'image source tileMap
      int ySource = floor(incr1 / TilePerMapImage) * gpxMapTileSize + pxObjectDecal;
      PImage i = createImage(gpxMapTileSize, gpxMapTileSize, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, gpxMapTileSize, gpxMapTileSize, 0, 0, gpxMapTileSize, gpxMapTileSize); // on copie le contenu
      lObjectTilesImages.add(i); // on stocke chaque miniature...
    }
    
    // spawn des objets du niveau------------------------------------------------------------------------------------------------------------
    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    //gMapBlockHeight = strLevelMapInit.length;
    //gMapBlockWidth = split(strLevelMapInit[0], ';').length;

    int maxMapBlock = gMapBlockHeight * gMapBlockWidth;
    for (int incr = 0; incr < maxMapBlock; incr++) {
      ObjectMapMatrix.add(new ArrayList<BASE_OBJECT>());
    }

    for (int incr1 = 0; incr1 < gMapBlockHeight; incr1++) {
      String[] strMapLineContent = split(strLevelMapInit[incr1], ";");
      for ( int incr2 = 0; incr2 < gMapBlockWidth; incr2++) {
        if (strMapLineContent[incr2].contains("'")) {
          //Iterable<String> items = split(strMapLineContent[incr2], "'").iterator();
          String[] items =split(strMapLineContent[incr2], "'");
          int block = (incr1*gMapBlockWidth)+incr2;

          for (int incr3 = 0; incr3 < items.length; incr3++) {
            switch(items[incr3]) {
            case "102": // light off // 103 = light up
            case "103":
              AppendObjectForInclusion(block, new SWITCH(block));
              break;
            case "104": // bomb explosion maximizer
              int[] powerDir = convertStringArrayToIntArray(split(items[incr3+1], ","));
              AppendObjectForInclusion(block, new EXPLOSION_MAXIMIZER(block, powerDir));
              break;
            case "105": // coffre
              String strItem = "";
              if (items.length>incr3+1){
                strItem = items[incr3+1];
              }
              AppendObjectForInclusion(block, new CHEST(block, strItem));
              break;
            case "106": // TNT
              AppendObjectForInclusion(block, new DYNAMITE(block));
              break;
            case "107": // magnet down
            case "108": // magnet right
            case "109": // magnet left
            case "110": // magnet up
            }
          }
        }
      }
    }
    IncludePendingObjects();
  }


  public void PermuteObjectMapMatrixPosition(int FromBlock, int ToBlock, BASE_OBJECT c) {
    AppendObjectForRemoval(FromBlock, c);
    AppendObjectForInclusion(ToBlock, c);
  }
  /*
  public void addObject(int block, BASE_OBJECT c) {
   c.setController(this);
   ObjectMapMatrix.get(block).add(c);
   //ID++;
   //return ID;
   }
   */
  void AppendObjectForInclusion(int block, BASE_OBJECT o) {
    /* les objets ne peuvent être ajoutés dans la liste ObjectMapMatrix lorsque la boucle 
     stepFrame() s'execute sous peine de générer une exception..
     on enregistre alors les reference de ces objets pour être ajouté pour la "frame suivante".. 
     */
    o.setController(this);
    PendingObjectsForInclusion.add(new PENDING_BASE_OBJECT(block, o));
  }

  void IncludePendingObjects() {
    // boucle appelé a la fin de stepFrame();
    for (PENDING_BASE_OBJECT o : PendingObjectsForInclusion) {
      ObjectMapMatrix.get(o.block).add(o.ref);
    }
    PendingObjectsForInclusion.clear();
  }


  void AppendObjectForRemoval(int block, BASE_OBJECT o) {
    /* les objets ne peuvent être supprimé de la liste ObjectMapMatrix lorsque la boucle 
     stepFrame() s'execute sous peine de générer une exception..
     on enregistre alors les reference de ces objets pour être supprimés.. 
     */
    PendingObjectsForRemoval.add(new PENDING_BASE_OBJECT(block, o));
  }

  void deletePendingObjects() {
    // boucle appelé a la fin de stepFrame();
    for (PENDING_BASE_OBJECT Pending_Object : PendingObjectsForRemoval) {
      ObjectMapMatrix.get(Pending_Object.block).remove(Pending_Object.ref);
      Pending_Object.ref.setController(null);
    }
    PendingObjectsForRemoval.clear();
  }

  public ArrayList<BASE_OBJECT> getTouchingObjectsFromRect(int block, Rect rect) {
    ArrayList<BASE_OBJECT> lst = new ArrayList<BASE_OBJECT>();
    for (int yDecal = -1; yDecal <=1; yDecal++) {
      for (int xDecal = -1; xDecal <=1; xDecal++) {
        int nBlockDecal =  block + (yDecal * gMapBlockWidth) + xDecal;
        for (BASE_OBJECT o : ObjectMapMatrix.get(nBlockDecal)) {
          if (isRectCollision(rect, o.HitBox)) {
            lst.add(o);
          }
        }
      }
    }
    return lst;
  }
  
  public ArrayList<BASE_CHARACTER> getCollidingCharactersFromRect(int block, Rect rect){
    return Glc.CManager.getCollidingCharactersFromRect(block,rect);
  }
  
  public boolean isStoppingObjectsCollidingWithCharacterRect(int block, Rect CharacterRect, CHARACTER_TYPE type) {
    for (int yDecal = -1; yDecal <=1; yDecal++) {
      for (int xDecal = -1; xDecal <=1; xDecal++) {
        int nBlockDecal =  block + (yDecal * gMapBlockWidth) + xDecal;
        for (BASE_OBJECT o : ObjectMapMatrix.get(nBlockDecal)) {
          switch (type) {
          case PLAYER :
            //if ((nBlockDecal != block) || !(o instanceof BOMB)) {
            if (o.stopPlayer && isRectCollision(CharacterRect, o.rect)) {
              if (gDebug) {
                stroke(255, 153, 0);
                Rect r = getCoordinateFromBlockPosition(o.block);
                rect(r.x-1, r.y-1, r.h+2, r.w+2);
                println("touche un objet");
                //println("PlayerRect = " + CharacterRect.x +", " + CharacterRect.y + ", " + CharacterRect.w +", " + CharacterRect.h );
                //println("ObjectRect = " + o.rect.x +", " + o.rect.y + ", " + o.rect.w +", " + o.rect.h );
              }
              return true;
            }
            //}
            break;
          case ENEMY :
            if (o.stopEnemy && isRectCollision(CharacterRect, o.rect)) {
              if (gDebug) {
                stroke(255, 153, 0);
                Rect r = getCoordinateFromBlockPosition(nBlockDecal);
                rect(r.x-1, r.y-1, r.h+2, r.w+2);
                println("EnemyRect = " + CharacterRect.x +", " + CharacterRect.y );
              }
              return true;
            }


            break;
          }
        }
      }
    }
    return false;
  }



  boolean IsMapStoppingFlameBlock(int nBlock) {
    return Glc.map.IsStoppingFlameBlock(nBlock);
  }

  public ArrayList<BASE_OBJECT>  getMapBlockPositionObjectList(int block) {
    return ObjectMapMatrix.get(block);
  }

  public boolean IsObjectStoppingCharacterAtPosition(int block, CHARACTER_TYPE type) {

    for (BASE_OBJECT o : ObjectMapMatrix.get(block)) {
      switch (type) {
      case PLAYER :
        if (o.stopPlayer) {
          if (gDebug) {
            stroke(255, 153, 0);
            Rect r = getCoordinateFromBlockPosition(block);
            rect(r.x, r.y, r.h, r.w);
          }
          return true;
        }
      case ENEMY :
        if (o.stopEnemy) {
          if (gDebug) {
            stroke(255, 153, 0);
            Rect r = getCoordinateFromBlockPosition(block);
            rect(r.x, r.y, r.h, r.w);
          }

          return true;
        }
      }
    }
    return false;
  }

  public ArrayList<BASE_CHARACTER> getMapBlockPositionCharacterList(int block) {
    return Glc.CManager.getMapBlockPositionCharacterList(block);
  }

  public void UpdateObjectsStepFrame() {
    for (ArrayList<BASE_OBJECT> mapMatrix : ObjectMapMatrix) {
      Iterator<BASE_OBJECT> iter = mapMatrix.iterator();
      while (iter.hasNext()) {
        iter.next().stepFrame();
      }
    }
    deletePendingObjects(); // on supprime tous les objets inutiles.. // l'ordre a son importance
    IncludePendingObjects(); // on ajoute tous les objets qui étaient en attente
  }

  public void RenderObjects() {
    for (ArrayList<BASE_OBJECT> mapMatrix : ObjectMapMatrix) {
      for (BASE_OBJECT o : mapMatrix) {
        Sprite s = o.GetSpriteToRender();
        image(lObjectTilesImages.get(s.TileID), s.xDecal, s.yDecal);
      }
    }
  }
}


// --------------------------------------------------------------------------------------------------------------------------------------------------------



public class BASE_OBJECT {
  public OBJECTS_MANAGER OM;
  
  public Rect rect;// position x,y sur la map
  public Rect HitBox; // hitbox de l'objet
  
  public OBJECT_CATEGORY category;
  public int block; // block sur lequel l'objet se trouve
  public int stepFrame = 0;//

  public int[] Sprites; // liste des sprites a utiliser dans l'animation de l'objet
  public int[] FrameTimings; // duration des animations
  public int maxStepFrame;

  public boolean bombDrop; // est ce qu'on peut déposer une bombe sur cet objet
  public boolean stopFlame; // est ce que cet objet arrete les flammes
  public boolean stopEnemy; // est ce que cet objet arrete les enemies
  public boolean stopPlayer; // est ce que cet objet arrete le joueur...
  public boolean movable; // est ce que l'objet est déplacable..


  public OBJECTS_MANAGER controller;
  public BASE_OBJECT( int block) {
    this.block = block;
    this.rect = new Rect((block % gMapBlockWidth) * gpxMapTileSize, floor(block / gMapBlockWidth) * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize);
    this.HitBox = new Rect(rect.x+6, rect.y+6, rect.w-12, rect.h-12);// le rectangle de collision est toujours plus petit..
    this.category = OBJECT_CATEGORY.DEFAULT;
  }

  public void setController(OBJECTS_MANAGER controller) {
    this.controller = controller;
  }

  protected void checkMapMatrixPermutation() {
    int newBlockPosition = getBlockPositionFromCoordinate(rect.x, rect.y, true);  
    if (block !=  newBlockPosition) {
      controller.PermuteObjectMapMatrixPosition(block, newBlockPosition, this);
      block = newBlockPosition;
    }
  }


  public void flameHit() {
  }
  public void playerHit() {
  }
  public void enemyHit() {
  }

  public void destruct() {
    controller.AppendObjectForRemoval(block, this);
    controller = null;
  }


  public void stepFrame() {
    stepFrame++;
    if (stepFrame > maxStepFrame) {
      stepFrame = 0;
    }
  }
  /*
  public boolean tryMoveRight(){
   
   }
   */
  public Sprite GetSpriteToRender() {
    int nSprite;
    int index = Arrays.binarySearch(FrameTimings, stepFrame);
    if (index >= 0) {
      nSprite = Sprites[index];
    } else { // negative value is the conditional new entry index 
      nSprite = Sprites[abs(index)-1];
    }
    return new Sprite(nSprite, rect.x, rect.y, 0);
  }
}



// --------------------------------------------------------------------------------------------------------------------------------------------------------
// object BOMB !oh putain 
//