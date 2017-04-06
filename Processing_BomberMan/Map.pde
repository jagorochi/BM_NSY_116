 //<>//

class Map {
  private int mapWidth;
  private int mapHeight;
  private ArrayList<HardBlock> map = new ArrayList<HardBlock>();
  private ArrayList<PImage> lHardBlockTilesImages  = new ArrayList<PImage>();
  //private PGraphics pg ;
  //private PImage  pi = createImage(16, 16, ARGB);
  private int TileSize; // taille des tuiles en pixels (carré donc 16*16)



  // unique constructeur 
  public Map(String strTileMapPath, int TileSize, int MaxTile, String strMapPath) {
    this.TileSize = TileSize; 
    PImage tileMapImg = loadImage(strTileMapPath);
    int TilePerWidth = tileMapImg.width / TileSize; // nombre max de tuile par ligne en fonction de la largeur en pixel de l'image tileMap

    /*  on va remplir d'image miniature "tuile" : lHardBlockTilesImages
     la tileMap à systematiquement une largeur en pixel égale à un multiple de la taille d'une tuile
     */
    for (int incr1 = 0; incr1 < MaxTile; incr1++) {
      int xSource = (incr1 % TilePerWidth) * TileSize; // position x et y dans l'image source tileMap
      int ySource = floor(incr1 / TilePerWidth) * TileSize;
      PImage i = createImage(TileSize, TileSize, ARGB); // on crée une image a la volée avec un canal alpha
      i.copy(tileMapImg, xSource, ySource, TileSize, TileSize, 0, 0, TileSize, TileSize); // on copie le contenu
      lHardBlockTilesImages.add(i); // on stocke chaque miniature...
    }
    
    /*
      chargement de la map dans
     */
     
    String file[] = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    mapHeight = file.length;
    mapWidth = split(file[0], ';').length;

    for (int incr1 = 0; incr1 < mapHeight; incr1++) {
      String[] l = split(file[incr1], ";");
      for ( int incr2 = 0; incr2 < mapWidth; incr2++) {
        int t = Integer.parseInt(split(l[incr2], ",")[0]);
        map.add(GetHardBlock(t));
      }
    }
  }



  void UpdateDisplay() {
    int x, y;
    int s = map.size();
    pushMatrix();
    scale(gSketchScale);
    for (int incr1 = 0; incr1 < s; incr1++) {

      x = (incr1 % mapWidth) * TileSize;
      y = floor(incr1 / mapWidth) * TileSize;

      image(lHardBlockTilesImages.get(map.get(incr1).getTileToDraw()-1), x, y);
    }
    popMatrix();
  }



  /*
  ---------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------------------------------------------------------------------
   */
  private HardBlock GetHardBlock(int Id) {
    HardBlock hb;

    // comportement de block
    switch (Id) {
    case 1: 
    case 2: // type sol
      hb = new HardBlock(true, false, false, false);
      break;
    case 32 : // type escalier
      hb = new HardBlock(false, true, false, false);
      break;
    default: // mur simple
      hb = new HardBlock(false, true, true, true);
    }

    // texture du bloc 

    switch (Id) {
    case 21: // Mur Externe partie immergée (animée en 2 frames)
    case 22:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{21, 22};
      break;
    case 23: // Eau
    case 24: 
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{23, 24};
      break;
    case 26: // racines dans l'eau
    case 27:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{26, 27};
      break;
    case 48: // eau en bas de la tour (gauche)
    case 49:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{48, 49};
      break;
    case 54: // eau en bas de la tour (droite)
    case 55:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{54, 55};
      break;
    case 62: // coin superieur gauche de la fontaine
    case 63:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{62, 63};
      break;
    case 65: // coin superieur droit de la fontaine
    case 66:
      hb.TileFrame = new int[]{30, 30};
      hb.TilesID = new int[]{65, 66};
      break;
    case 67: // coté gauche de la fontaine
    case 68: 
    case 69:
      // hb.tiles.add(new Tile(67, 30));
      // hb.tiles.add(new Tile(68, 30));
      // hb.tiles.add(new Tile(69, 30));
      hb.TileFrame = new int[]{30, 30, 30};
      hb.TilesID = new int[]{69, 68, 67};
      break;
    case 70: // centre de la fontaine
    case 71: 
    case 72:
      hb.TileFrame = new int[]{30, 30, 30, 30};
      hb.TilesID = new int[]{72, 71, 70, 71};
      break;
    case 73: // coté droit de la fontaine
    case 74: 
    case 75: 
      hb.TileFrame = new int[]{30, 30, 30};
      hb.TilesID = new int[]{75, 74, 73};
      break;
    case 84: //Element de porte de sortie milieu gauche
    case 85: 
    case 86:  
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{84};
      break;
    case 87: //Element de porte de sortie bas gauche
    case 88: 
    case 89:
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{87};
      break;
    case 90: //Element de porte de sortie milieu centre
    case 91: 
    case 92:
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{90};
      break;
    case 93: //Element de porte de sortie milieu bas
    case 94: 
    case 95:
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{93};
      break;
    case 96: //Element de porte de sortie milieu droite
    case 97: 
    case 98: 
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{96};
      break;
    case 99: // Element de porte de sortie bas droite
    case 100: 
    case 101:
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{99};
      break;
    default:
      hb.TileFrame = new int[]{-1};
      hb.TilesID = new int[]{Id};
    }
    hb.populateTileFrame();
    return hb;
  }


  private class HardBlock {
    /* 
     Cette classe décrit les propriétés des block indestructible qui composent l'arrière plan de la map.
     */
    //public String description;
    public boolean bombDrop;
    public boolean stopFlame;
    public boolean stopEnemy;
    public boolean stopPlayer;
    public int[] TileFrame;
    public int[] TilesID;
    public int maxFrame;
    //public ArrayList<Tile> tiles = new ArrayList<Tile>();

    public HardBlock(boolean bombDrop, boolean stopFlame, boolean stopEnemy, boolean stopPlayer) {
      this.bombDrop = bombDrop;
      this.stopFlame = stopFlame;
      this.stopEnemy = stopEnemy;
      this.stopPlayer = stopPlayer;
    }

    private void populateTileFrame() {
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
  /*
  private class Tile {
   public int Id;
   public int duration;
   
   public Tile(int Id, int duration) {
   this.Id = Id;
   this.duration = duration;
   }
   */
}





/*
  void display() {
 
 int x, y;
 pg.beginDraw();
 for (int incr1 = 0; incr1 < map.size(); incr1++) {
 Tile t = map.get(incr1).tiles.get(0);
 x = (incr1 % mapWidth) * TileSize;
 y = floor(incr1 / mapWidth) * TileSize;
 pg.copy(pImg, t.x, t.y, TileSize, TileSize, x, y, TileSize, TileSize);
 }
 pg.endDraw();
 image(pg, 0, 0);
 }
 */



/* exemple de map...
 23;23;44;50;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
 23;23;45;60;23;23;23;23;23;23;23;23;23;23;23;23;23;23;23;78;79;80;23;23;23;23;23;23;23;23
 23;23;46;61;43;43;43;43;43;43;43;43;43;43;43;43;43;37;23;78;79;80;12;12;12;12;12;12;11;23
 23;23;47;28;2;2;2;2,105;2,105;2;2;3;2,105;3;2,105;3;2,105;35;12;81;82;83;2,104;2;2,105;2,105;2;2,103;5;25
 25;23;48;28;1;3;1;10;12;11;1;2;1,106;2,105;1,106;2,105;2;8;2,103;84;90;96;1;4;17;17;17;17;19;26
 26;23;23;28;1;2;1;8;2,103;5;1,105;3;1,105;3;1,105;3;2,105;8;1;87;93;99;1;5;18;18;18;18;20;23
 23;23;23;34;33;32;31;9;1,105;6;12;12;12;33;32;31;12;9;1,105;3;2;3;1;6;12;12;12;12;11;23
 23;25;23;8;2,105;2;2;2;1,106;2,105;2;2,105;2;2;2;2;2;2,105;2;2,105;1;2;1,104;2;2,105;2,105;2;2,103;5;23
 23;26;23;8;1;62;64;65;1,105;4;17;15;17;15;17;7;1;3;1;3;1,105;3;1;4;17;15;17;15;19;23
 23;23;25;8;1;67;70;73;1;5;18;16;18;16;18;8;1;2;1,106;2,105;1,104;2,109;1;5;18;18;18;16;20;23
 23;23;26;8;1;76;12;77;1,105;5;21;21;21;21;21;8;1,105;3;1,105;3;1,105;3;1;5;21;21;21;21;21;23
 25;23;44;59;1,103;2;2;2;1,103;56;50;23;23;25;44;59;1;2,105;1;2,105;1,104;2,107;1,104;56;50;23;23;23;23;25
 26;23;45;60;17;15;17;15;17;57;51;23;25;26;45;60;17;15;17;15;17;15;17;57;51;23;25;23;23;26
 23;23;46;52;18;16;18;16;18;46;52;23;26;23;46;52;18;16;18;16;18;16;18;46;52;23;26;23;23;23
 23;23;47;53;21;21;21;21;21;47;53;23;23;23;47;53;21;21;21;21;21;21;21;47;53;23;23;23;23;23
 23;23;48;54;23;23;23;23;23;48;54;23;23;23;48;54;23;23;23;23;23;23;23;48;54;23;23;23;23;23
 */