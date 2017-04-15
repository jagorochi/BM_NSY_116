//<>// //<>// //<>//

class Map {
  private int blocksWidth;
  private int blocksHeight;
  private ArrayList<HardBlock> map = new ArrayList<HardBlock>();
  private ArrayList<PImage> lHardBlockTilesImages  = new ArrayList<PImage>();
  private int pxTileSize; // taille des tuiles en pixels (carré donc 16*16)
  private String strLevelMapInit[]; // on enregistre le contenu du level initial au cas ou si l'on doit réinitialiser la map.
  private int maxScreenX, maxScreenY;
  private int playerScrollDecalX, playerScrollDecalY;
  private BomberMan bm;


  public Map(PImage tileMapImg, int pxTileSize, int MaxTile, String strMapPath) {
    this.pxTileSize = pxTileSize;
    int TilePerMapImage = tileMapImg.width / pxTileSize; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap

    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile    
     exemple de map...
     23;23;44;50;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
     23;23;45;60;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
     23;23;46;61;43;43;43;43;43;43;43;43;43;43;43;43;43;37;23;78;79;80;12;12;12;12;12;12;11;23
     .... */

    for (int incr1 = 0; incr1 < MaxTile; incr1++) {
      int xSource = (incr1 % TilePerMapImage) * pxTileSize; // position x et y dans l'image source tileMap
      int ySource = floor(incr1 / TilePerMapImage) * pxTileSize;
      PImage i = createImage(pxTileSize, pxTileSize, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, pxTileSize, pxTileSize, 0, 0, pxTileSize, pxTileSize); // on copie le contenu
      lHardBlockTilesImages.add(i); // on stocke chaque miniature...
    }

    /*
      construction matricielle de la map en fonction du fichier de niveau .csv fournit en argument.
     */

    strLevelMapInit = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    blocksHeight = strLevelMapInit.length;
    blocksWidth = split(strLevelMapInit[0], ';').length;

    for (int incr1 = 0; incr1 < blocksHeight; incr1++) {
      String[] strMapLineContent = split(strLevelMapInit[incr1], ";");
      for ( int incr2 = 0; incr2 < blocksWidth; incr2++) {
        int blockType = Integer.parseInt(split(strMapLineContent[incr2], ",")[0]);
        HardBlock hb = new HardBlock(blockType, incr2 * pxTileSize, incr1 * pxTileSize, pxTileSize);
        map.add(hb);
      }
    }
    /*
      Initialisation du player !
     */
    int PlayerSpawnPosition = 94; /// temporaire car doit être décidé en fonction du level.
    // BomberMan(PImage tileMapImg, Map map, int SpawnPosition, int pxTileSize)
    maxScreenX = (blocksWidth * pxTileSize) - ScreenRect.w;
    maxScreenY = (blocksHeight * pxTileSize) - ScreenRect.h;
    playerScrollDecalX = - ((ScreenRect.w / 2 )  + (pxTileSize/2));
    playerScrollDecalY = - ((ScreenRect.h / 2 )  + (pxTileSize/2));



    bm = new BomberMan(tileMapImg, this, PlayerSpawnPosition, pxTileSize);
  }




  /* fonction permettant de verifier si un block laisse passer ou pas le joueur. */
  boolean IsStopPlayerBlock(int nBlock) {
    if (gDebug) { // fonction de debug : affiche un rectangle orange à la position testée.
      HardBlock hb = map.get(nBlock);
      stroke(255, 153, 0);
      rect(hb.rect.x, hb.rect.y, hb.rect.h, hb.rect.w);
    }
    return map.get(nBlock).stopPlayer;
  }


  /* fonction permettant de verifier si un block spécifique est en collision avec un "rect" passé en argument */
  boolean checkHardBlockCollision(int nBlock, Rect playerRect) {
    HardBlock hb = map.get(nBlock);
    if (gDebug) {
      stroke(255, 0, 0);
      rect(hb.rect.x, hb.rect.y, hb.rect.h, hb.rect.w);
    }
    if (!hb.stopPlayer) {
      return true;
    } else { 
      return checkRectCollision(hb.rect, playerRect);
    }
  }

  // fonctions permettant de verifier si la position X ou Y a tester (du joueur) est plus ou moins décalé à la position x d'un bloc determiné...
  // utile pour verifier si l'on doit déplacer le player dans un couloir
  public int getXdifference(int nBlock, int x) {
    return map.get(nBlock).rect.x - x;
  }
  public int getYdifference(int nBlock, int y) {
    return map.get(nBlock).rect.y - y;
  }

  /* fonction permettant de vérifier la collision entre deux "Rect"
   ils sont ici libellés "hb" et "player" mais ça n'a aucune importance..
   on teste deux "rectangle"... */
  private boolean checkRectCollision(Rect hb, Rect player) {
    return ((player.x > hb.x + hb.w)      // trop à droite
      || (player.x + player.w < hb.x) // trop à gauche
      || (player.y > hb.y + hb.h) // trop en bas
      || (player.y + player.h < hb.y)) ;// trop en haut
  }


  public int getBlockPositionFromCoordinate(int x, int y, boolean bDecal) {
    /* Cette fonction permet de calculer le numéro de bloc de la map en fonction de coordonnées x et y.
     utile pour recalculer la position des objets qui "bougent" et ainsi limiter les futurs tests de collisions
     a l'environnement proche.. */
    if (bDecal) {
      return floor((x + ( pxTileSize / 2)) / pxTileSize) + (((y + (pxTileSize /2)) / pxTileSize)* blocksWidth);
    } else {
      return floor(x  / pxTileSize) + ((y  / pxTileSize)* blocksWidth);
    }
  }







  public void render() {
    /* Cette fonction permet de redessiner uniquement la zone de la map correspondant a la taille de l'ecran
    en fonctione de l'endroit ou se trouve le joueur...
    - on determine la position du cadre par rapport a la position du joueur dans la zone de jeu
    - on restraint la position du cadre au bordure de la zone de jeu
    - on recentre la position de l'écran à cette "zone de la map"
    - on calcule les blocs a afficher se trouvant dans ce cadre..
    - voilà :) */
    

    int xPos = bm.rect.x + playerScrollDecalX;
    if (xPos < 0) {
      xPos = 0;
    } else if (xPos > maxScreenX) {
      xPos = maxScreenX;
    }
    int yPos = bm.rect.y + playerScrollDecalY;
    if (yPos < 0) {
      yPos = 0;
    } else if (yPos > maxScreenY) {
      yPos = maxScreenY;
    }

    translate(-xPos, -yPos); // on replace la zone a dessiner par rapport a l'origine..
    
    int nStart = getBlockPositionFromCoordinate(xPos, yPos,false);
    int nEnd = getBlockPositionFromCoordinate(xPos + ScreenRect.w, yPos, false);
    int MapSize = map.size();
    int maxLoop = floor((getBlockPositionFromCoordinate(xPos, yPos + ScreenRect.h, false ) - nStart) / blocksWidth)+1;
    
    for (int loop = 0; loop<maxLoop; loop++) {
      for (int nBlock = nStart; nBlock <= nEnd; nBlock++) {
        int b = nBlock + (loop* blocksWidth);
        if (b >= MapSize){
          break;
        }
        HardBlock hb = map.get(b);
        image(lHardBlockTilesImages.get(hb.getTileToDraw()-1), hb.rect.x, hb.rect.y);
      }
    }
  }










  public void updatePlayerAction() {
    bm.updateAction();
  }

  public void PlayerRender() {
    bm.render();
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
    public int[] TileFrame;
    public int[] TilesID;
    public int maxFrame;
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