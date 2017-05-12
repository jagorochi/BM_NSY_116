public class OBJECTS_MANAGER {
  private ArrayList<PImage> lObjectTilesImages  = new ArrayList<PImage>();
  private int pxTileSize; // taille des tuiles en pixels (carré donc 16*16)
  //private HashMap<Integer,MAP_OBJECT> OBJECTS  = new HashMap<Integer,MAP_OBJECT>();
  private ArrayList<BASE_OBJECT> OBJECTS  = new ArrayList<BASE_OBJECT>();
  //private GLC oParent;


  public OBJECTS_MANAGER( PImage tileMapImg, int pxTileSize, String strMapPath) {

    this.pxTileSize = pxTileSize;
    int TilePerMapImage = 40; // FIXED tileMapImg.width / pxTileSize; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    int totalSprite = 79;// codé en dur
    int pxObjectDecal = 5 * pxTileSize; // a partir du 6ème bloc
    
    for (int incr1 = 0; incr1 < totalSprite; incr1++) {
      int xSource = (incr1 % TilePerMapImage) * pxTileSize; // position x et y dans l'image source tileMap
      int ySource = floor(incr1 / TilePerMapImage) * pxTileSize + pxObjectDecal;
      PImage i = createImage(pxTileSize, pxTileSize, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, pxTileSize, pxTileSize, 0, 0, pxTileSize, pxTileSize); // on copie le contenu

      lObjectTilesImages.add(i); // on stocke chaque miniature...
    }

  }


  public void addObject(BASE_OBJECT o) {

    OBJECTS.add(o);
    //ID++;
    //return ID;
  }

  void removeObject(BASE_OBJECT o) {
    OBJECTS.remove(o);
  }

  public void UpdateObjectsStepFrame() {
    for (BASE_OBJECT o : OBJECTS) {
      o.stepFrame();
    }
  }

  public void RenderObjects() {
    for (BASE_OBJECT o : OBJECTS) {
      Sprite s = o.GetSpriteToRender();
      image(lObjectTilesImages.get(s.TileID), s.xDecal, s.yDecal);
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
  public int[] Frametimings; // duration des animations
  public int maxStepFrame;

  public boolean bombDrop; // est ce qu'on peut déposer une bombe sur cet objet
  public boolean stopFlame; // est ce que cet objet arrete les flammes
  public boolean stopEnemy; // est ce que cet objet arrete les enemies
  public boolean stopPlayer; // est ce que cet objet arret le joueur...

  public BASE_OBJECT(int block, Rect rect) {
    this.block = block;
    this.rect = rect;
  }

  public void flameHit() {
  }
  public void playerHit() {
  }
  public void EnemyHit() {
  }

  public void stepFrame() {
    stepFrame++;
    if (stepFrame > maxStepFrame) {
      stepFrame = 0;
    }
  }

  public Sprite GetSpriteToRender() {
    int nSprite;
    int index = Arrays.binarySearch(Frametimings, stepFrame);
    if (index >= 0) {
      nSprite = Sprites[index];
    } else { // negative value is the conditional new entry index 
      nSprite = Sprites[abs(index)-1];
    }
    return new Sprite(nSprite, rect.x, rect.y, 0);
  }
} 



// --------------------------------------------------------------------------------------------------------------------------------------------------------
// object BOMB !
//

public class BOMB extends BASE_OBJECT {

  public int power;
  public int duration;

  public BOMB(int block, Rect rect, int[] args) {
    super(block, rect); // appel vers le constructeur parent

    this.duration = args[0]; // frame duration
    this.power = args[1];
    // definition de l'animation
    Sprites = new int[]{53, 52, 51, 52}; // liste des sprites a utiliser dans l'animation de l'objet
    Frametimings = new int[]{20, 40, 60, 80}; // duration des animations
  }

  public void flameHit() {
  }
  public void playerHit() {
  }
  public void EnemyHit() {
  }
}