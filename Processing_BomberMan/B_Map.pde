//<>// //<>// //<>//
public int gMapBlockWidth, gMapBlockHeight, gpxMapTileSize;

class Map {
  int[] tableau= new int[]{1, 2, 2, 2, 2};
  //private int gMapBlockWidth;
  //private int gMapBlockHeight;
  private ArrayList<HardBlock> map = new ArrayList<HardBlock>();
  private ArrayList<PImage> lHardBlockTilesImages  = new ArrayList<PImage>();
  //private int gpxMapTileSize; // taille des tuiles en pixels (carré donc 16*16)
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private int maxScreenX, maxScreenY;
  private int playerScrollDecalX, playerScrollDecalY;

  private GLC oParent;
  public Map(GLC oParent, PImage tileMapImg, int pxMapTileSize, int MaxTile, String strMapPath) {
    this.oParent= oParent;
    gpxMapTileSize = pxMapTileSize;

    int TilePerMapImage = 40; // FIXED tileMapImg.width / gpxMapTileSize; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap
    //this.oParent = oParent;
    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile    
     exemple de map..
     23;23;44;50;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
     23;23;45;60;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
     23;23;46;61;43;43;43;43;43;43;43;43;43;43;43;43;43;37;23;78;79;80;12;12;12;12;12;12;11;23
     .... */

    for (int incr1 = 0; incr1 < MaxTile; incr1++) {
      int xSource = (incr1 % TilePerMapImage) * gpxMapTileSize; // position x et y dans l'image source tileMap
      int ySource = floor(incr1 / TilePerMapImage) * gpxMapTileSize;
      PImage i = createImage(gpxMapTileSize, gpxMapTileSize, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, gpxMapTileSize, gpxMapTileSize, 0, 0, gpxMapTileSize, gpxMapTileSize); // on copie le contenu
      lHardBlockTilesImages.add(i); // on stocke chaque miniature...
    }
    
    /*
      construction matricielle de la map en fonction du fichier de niveau .csv fournit en argument.
     */

    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    gMapBlockHeight = strLevelMapInit.length;
    gMapBlockWidth = split(strLevelMapInit[0], ';').length;

    for (int incr1 = 0; incr1 < gMapBlockHeight; incr1++) {
      String[] strMapLineContent = split(strLevelMapInit[incr1], ";");
      for ( int incr2 = 0; incr2 < gMapBlockWidth; incr2++) {
        int blockType = Integer.parseInt(split(strMapLineContent[incr2], "'")[0]);
        HardBlock hb = new HardBlock(blockType, incr2 * gpxMapTileSize, incr1 * gpxMapTileSize, gpxMapTileSize);
        map.add(hb);
      }
    }

    maxScreenX = (gMapBlockWidth * gpxMapTileSize) - ScreenRect.w;
    maxScreenY = (gMapBlockHeight * gpxMapTileSize) - ScreenRect.h;
    playerScrollDecalX = - ((ScreenRect.w / 2 )  + (gpxMapTileSize/2));
    playerScrollDecalY = - ((ScreenRect.h / 2 )  + (gpxMapTileSize/2));
  }




  /* fonction permettant de verifier si un block laisse passer ou pas le joueur. */
  boolean IsBlockStoppingCharacterAtPosition(int nBlock, CHARACTER_TYPE type) {
    switch (type) {
    case PLAYER :
      if (map.get(nBlock).stopPlayer) {
        if (gDebug) {
          stroke(255, 100, 255);
          Rect r = getCoordinateFromBlockPosition(nBlock);
          rect(r.x+2, r.y+2, r.h-4, r.w-4);
        }
        return true;
      }
      break;
    case ENEMY :
      if (map.get(nBlock).stopPlayer) {
        if (gDebug) {
          stroke(255, 100, 255);
          Rect r = getCoordinateFromBlockPosition(nBlock);
          rect(r.x+2, r.y+2, r.h-4, r.w-4);
        }
        return true;
      }
      break;
    }
    return false;
  }

  boolean IsStoppingFlameBlock(int nBlock) {
    return map.get(nBlock).stopFlame;
  }

  boolean IsStoppingEnemyBlock(int nBlock) {
    return map.get(nBlock).stopEnemy;
  }

  boolean IsBombDroppableOnBlock(int nBlock) {
    return map.get(nBlock).bombDrop;
  }


  /* fonction permettant de verifier si un block spécifique est en collision avec un "rect" passé en argument */
  boolean isStoppingHardBlockCollidingWithCharacterRect(int nBlock, Rect CharacterRect, CHARACTER_TYPE type) {
    HardBlock hb = map.get(nBlock);

    switch (type) {
    case PLAYER :
      if (!hb.stopPlayer) {
        if (gDebug) {
          stroke(255, 0, 255);
          rect(hb.rect.x-2, hb.rect.y-2, hb.rect.h+4, hb.rect.w+4);
        }
        return false;
      }
      break;
    case ENEMY :
      if (!hb.stopEnemy) {
        if (gDebug) {
          stroke(255, 0, 255);
          rect(hb.rect.x-2, hb.rect.y-2, hb.rect.h+4, hb.rect.w+4);
        }
        return false;
      }
      break;
    }
    if (gDebug) {
      stroke(255, 0, 255);
      rect(hb.rect.x-2, hb.rect.y-2, hb.rect.h+4, hb.rect.w+4);
    }
    return isRectCollision(hb.rect, CharacterRect);
  }

  // fonctions permettant de verifier si la position X ou Y a tester (du joueur) est plus ou moins décalé à la position x d'un bloc determiné...
  // utile pour verifier si l'on doit déplacer le player dans un couloir
  public int getXdifference(int nBlock, int x) {
    return map.get(nBlock).rect.x - x;
  }
  public int getYdifference(int nBlock, int y) {
    return map.get(nBlock).rect.y - y;
  }








  public void render(int x, int y) {
    /* Cette fonction permet de redessiner uniquement la zone de la map correspondant a la taille de l'ecran
     en fonctione de l'endroit ou se trouve le joueur...
     - on determine la position du cadre par rapport a la position du joueur dans la zone de jeu
     - on restraint la position du cadre au bordure de la zone de jeu
     - on recentre la position de l'écran à cette "zone de la map"
     - on calcule les blocs a afficher se trouvant dans ce cadre..
     - voilà :) */


    int xPos = x + playerScrollDecalX;
    if (xPos < 0) {
      xPos = 0;
    } else if (xPos > maxScreenX) {
      xPos = maxScreenX;
    }
    int yPos = y + playerScrollDecalY;
    if (yPos < 0) {
      yPos = 0;
    } else if (yPos > maxScreenY) {
      yPos = maxScreenY;
    }

    translate(-xPos, -yPos); // on replace la zone a dessiner par rapport a l'origine..

    int nStart = getBlockPositionFromCoordinate(xPos, yPos, false);
    int nEnd = getBlockPositionFromCoordinate(xPos + ScreenRect.w, yPos, false);
    int MapSize = map.size();
    int maxLoop = floor((getBlockPositionFromCoordinate(xPos, yPos + ScreenRect.h, false ) - nStart) / gMapBlockWidth)+1;

    for (int loop = 0; loop<maxLoop; loop++) {
      for (int nBlock = nStart; nBlock <= nEnd; nBlock++) {
        int b = nBlock + (loop* gMapBlockWidth);
        if (b >= MapSize) {
          break;
        }
        HardBlock hb = map.get(b);
        image(lHardBlockTilesImages.get(hb.getTileToDraw()-1), hb.rect.x, hb.rect.y);
      }
    }
  }











  /*
  ---------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------
   */

  private class HardBlock {
    //  Cette classe décrit les propriétés des block indestructible qui composent l'arrière plan de la map.
    public boolean bombDrop;
    public boolean stopFlame;
    public boolean stopEnemy;
    public boolean stopPlayer;
    private int[] TileFrame;
    private int[] TilesID;
    private int maxFrame;
    public Rect rect;// = new Rect();

    public HardBlock(int Id, int xPos, int yPos, int pxBlockSize) {
      rect = new Rect(xPos, yPos, pxBlockSize, pxBlockSize);

      /* on commence par déterminer les propriétés par défaut de chaque type de HardBlock
       il n'y a que 4 type de bloc : 
       1,2 : sont les blocs sur lequel on peut marcher..
       32 : les marches d'escalier permettent aux joueurs et monstre de marcher dessus mais pas de bombe ni flammes.
       le reste : mur de base : bloque toute interaction.. */
      switch (Id) {
      case 1:  // type sol
      case 2: // type sol avec ombrage
        //hb = new HardBlock(true, false, false, false);
        this.bombDrop = true;
        this.stopFlame = false;
        this.stopEnemy = false;
        this.stopPlayer = false;

        break;
      case 32 : // type escalier
        // hb = new HardBlock(false, true, false, false);
        this.bombDrop = false;
        this.stopFlame = true;
        this.stopEnemy = false;
        this.stopPlayer = false;

        break;
      default: // mur simple
        // hb = new HardBlock(false, true, true, true);
        this.bombDrop = false;
        this.stopFlame = true;
        this.stopEnemy = true;
        this.stopPlayer = true;
      }

      // textures du bloc, peuvent être multiples avec une durée d'affichage en nombre de frame 
      int defaultDuration = 30;
      switch (Id) {
      case 21: // Mur Externe partie immergée (animée en 2 frames)
      case 22:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{21, 22};
        break;
      case 23: // Eau
      case 24: 
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{23, 24};
        break;
      case 26: // racines dans l'eau
      case 27:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{26, 27};
        break;
      case 48: // eau en bas de la tour (gauche)
      case 49:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{48, 49};
        break;
      case 54: // eau en bas de la tour (droite)
      case 55:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{54, 55};
        break;
      case 62: // coin superieur gauche de la fontaine
      case 63:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{62, 63};
        break;
      case 65: // coin superieur droit de la fontaine
      case 66:
        this.TileFrame = new int[]{defaultDuration, defaultDuration};
        this.TilesID = new int[]{65, 66};
        break;
      case 67: // coté gauche de la fontaine
      case 68: 
      case 69:
        this.TileFrame = new int[]{defaultDuration, defaultDuration, defaultDuration};
        this.TilesID = new int[]{69, 68, 67};
        break;
      case 70: // centre de la fontaine
      case 71: 
      case 72:
        this.TileFrame = new int[]{defaultDuration, defaultDuration, defaultDuration, defaultDuration};
        this.TilesID = new int[]{72, 71, 70, 71};
        break;
      case 73: // coté droit de la fontaine
      case 74: 
      case 75: 
        this.TileFrame = new int[]{defaultDuration, defaultDuration, defaultDuration};
        this.TilesID = new int[]{75, 74, 73};
        break;
      case 84: //Element de porte de sortie milieu gauche
      case 85: 
      case 86:  
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{84};
        break;
      case 87: //Element de porte de sortie bas gauche
      case 88: 
      case 89:
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{87};
        break;
      case 90: //Element de porte de sortie milieu centre
      case 91: 
      case 92:
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{90};
        break;
      case 93: //Element de porte de sortie milieu bas
      case 94: 
      case 95:
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{93};
        break;
      case 96: //Element de porte de sortie milieu droite
      case 97: 
      case 98: 
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{96};
        break;
      case 99: // Element de porte de sortie bas droite
      case 100: 
      case 101:
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{99};
        break;
      default:
        this.TileFrame = new int[]{-1};
        this.TilesID = new int[]{Id};
      }

      // on recalcule les timings de frame afin que le moteur  
      int[] t = new int[TileFrame.length];
      for (int incr1 = 0; incr1 < TileFrame.length; incr1++) {
        if (incr1 == 0) {
          t[0] = TileFrame[incr1];
        } else {
          t[incr1] = t[incr1-1]  + TileFrame[incr1];
        }
        maxFrame = t[incr1];
      }
      TileFrame = t;
    }

    private int getTileToDraw() {
      if (TilesID.length == 1) { // s'il n'y a qu'une seule image donc pas d'animation..
        return TilesID[0];
      } else {
        int frame = (frameCount % maxFrame) +1; 
        int index = Arrays.binarySearch(TileFrame, frame);
        if (index >= 0) {
          return TilesID[index];
        } else { // negative value is the conditional new entry index 
          return TilesID[abs(index)-1];
        }
      }
    }
  }
}