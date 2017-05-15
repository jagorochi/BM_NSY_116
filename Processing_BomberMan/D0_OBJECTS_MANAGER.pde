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
          String[] items = split(strMapLineContent[incr2], "'");
          for ( String item : items) {
            switch(item) {
            case "102": // light off // 103 = light up
            case "104": // bomb max
            case "105": // coffre
              int block = (incr1*gMapBlockWidth)+incr2;
            case "106": // TNT
            case "107": // magnet down
            case "108": // magnet right
            case "109": // magnet left 
            case "110": // magnet up
            }
          }
        }
      }
    }
  }


  public void MoveObject(int block, BASE_OBJECT c) {
    AppendObjectForRemoval(block, c); // l'ordre a son importance...
    AppendObjectForInclusion(block, c);
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
      ObjectMapMatrix.get(o.block).add(o.object);
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
    for (PENDING_BASE_OBJECT o : PendingObjectsForRemoval) {
      ObjectMapMatrix.get(o.block).remove(o.object);
    }
    PendingObjectsForRemoval.clear();
  }

  public ArrayList<BASE_OBJECT> getTouchingObjectList(int block, Rect rect) {
    ArrayList<BASE_OBJECT> lst = new ArrayList<BASE_OBJECT>();
    Rect rect1 = new Rect(rect.x+2, rect.y+2, rect.h-2, rect.w-2); 
    for (int yDecal = -1; yDecal <=1; yDecal++) {
      for (int xDecal = -1; xDecal <=1; xDecal++) {
        int nBlockDecal =  block + (yDecal * gMapBlockWidth) + xDecal;
        for (BASE_OBJECT o : ObjectMapMatrix.get(nBlockDecal)) {
          if (isRectCollision(rect1, o.HitBox)) {
            lst.add(o);
          }
        }
      }
    }
    return lst;
  }
  
   boolean IsMapStoppingFlameBlock(int nBlock) {
    return Glc.map.IsStoppingFlameBlock(nBlock);
  }

  public ArrayList<BASE_OBJECT>  getMapBlockPositionObjectList(int block) {
    return ObjectMapMatrix.get(block);
  }



  public void UpdateObjectsStepFrame() {
    for (ArrayList<BASE_OBJECT> mapMatrix : ObjectMapMatrix) {
      Iterator<BASE_OBJECT> iter = mapMatrix.iterator();
      while (iter.hasNext()) {
        iter.next().stepFrame();
      }
    }
    deletePendingObjects(); // on supprime tous les objets inutiles..
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

/*
public interface IOBJECT {
 // void InitState();
 // void spawn();
 public void flameHit();
 public void stepFrame();
 public void playerHit();
 public void EnemyHit();
 public Sprite GetrenderObject();
 }*/

public class BASE_OBJECT {
  public OBJECTS_MANAGER OM;

  public Rect rect;// position x,y sur la map
  public Rect HitBox; // hitbox de l'objet

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
    this.HitBox = new Rect(rect.x+2, rect.y+2, rect.w-2, rect.h-2);// le rectangle de collision est toujours plus petit..
  }
  
  public void setController(OBJECTS_MANAGER controller) {
    this.controller = controller;
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