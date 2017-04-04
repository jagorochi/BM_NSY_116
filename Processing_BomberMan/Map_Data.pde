

public class Map_Data {
  protected int TileSize;
  protected int MaxHorizontalTile;
  


  protected HardBlock GetHardBlock(int Id) {
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
      hb.tiles.add(new Tile(21, 30));
      hb.tiles.add(new Tile(22, 30));
      break;
    case 23: // Eau
    case 24: 
      hb.tiles.add(new Tile(23, 30));
      hb.tiles.add(new Tile(24, 30));
      break;
    case 26: // racines dans l'eau
    case 27:
      hb.tiles.add(new Tile(26, 30));
      hb.tiles.add(new Tile(27, 30));
      break;
    case 48: // eau en bas de la tour (gauche)
    case 49:
      hb.tiles.add(new Tile(48, 30));
      hb.tiles.add(new Tile(49, 30));
      break;
    case 54: // eau en bas de la tour (droite)
    case 55:
      hb.tiles.add(new Tile(54, 30));
      hb.tiles.add(new Tile(55, 30));
      break;
    case 62: // coin superieur gauche de la fontaine
    case 63:
      hb.tiles.add(new Tile(62, 30));
      hb.tiles.add(new Tile(63, 30));
      break;
    case 65: // coin superieur droit de la fontaine
    case 66:
      hb.tiles.add(new Tile(65, 30));
      hb.tiles.add(new Tile(66, 30));
      break;
    case 67: // coté gauche de la fontaine
    case 68: 
    case 69:
      hb.tiles.add(new Tile(67, 30));
      hb.tiles.add(new Tile(68, 30));
      hb.tiles.add(new Tile(69, 30));
      break;
    case 70: // centre de la fontaine
    case 71: 
    case 72:
      hb.tiles.add(new Tile(70, 30));
      hb.tiles.add(new Tile(71, 30));
      hb.tiles.add(new Tile(72, 30));
      break;
    case 73: // coté droit de la fontaine
    case 74: 
    case 75: 
      hb.tiles.add(new Tile(73, 30));
      hb.tiles.add(new Tile(74, 30));
      hb.tiles.add(new Tile(75, 30));
      break;
    case 84: //Element de porte de sortie milieu gauche
    case 85: 
    case 86:  
      hb.tiles.add(new Tile(84, -1));
      break;
    case 87: //Element de porte de sortie bas gauche
    case 88: 
    case 89:
      hb.tiles.add(new Tile(87, -1));
      break;
    case 90: //Element de porte de sortie milieu centre
    case 91: 
    case 92:
      hb.tiles.add(new Tile(90, -1));
      break;
    case 93: //Element de porte de sortie milieu bas
    case 94: 
    case 95:
      hb.tiles.add(new Tile(93, -1));
      break;
    case 96: //Element de porte de sortie milieu droite
    case 97: 
    case 98: 
      hb.tiles.add(new Tile(96, -1));
      break;
    case 99: // Element de porte de sortie bas droite
    case 100: 
    case 101:
      hb.tiles.add(new Tile(99, -1));
      break;
    default:
      hb.tiles.add(new Tile(Id, -1));
    }
    hb.populateTileFrame();
    return hb;
  }


  protected class HardBlock {
    /* 
     Cette classe décrit les propriétés des block indestructible qui composent l'arrière plan de la map.
     */
    //public String description;
    public boolean bombDrop;
    public boolean stopFlame;
    public boolean stopEnemy;
    public boolean stopPlayer;
    private boolean bAnimated;
    private int[] TileFrame;
    private int maxFrame;
    public ArrayList<Tile> tiles = new ArrayList<Tile>();
    
    public HardBlock(boolean bombDrop, boolean stopFlame, boolean stopEnemy, boolean stopPlayer) {
      this.bombDrop = bombDrop;
      this.stopFlame = stopFlame;
      this.stopEnemy = stopEnemy;
      this.stopPlayer = stopPlayer;
    }
    
    private void populateTileFrame(){
      TileFrame = new int[tiles.size()];
      if (TileFrame.length > 1 ){
        bAnimated = true;
      }else{
        bAnimated = false;
      }
      for (int incr1 = 0; incr1 < TileFrame.length;incr1++){
        if (incr1 == 0){
          TileFrame[0] = tiles.get(0).duration;
        }else{
          TileFrame[incr1] = TileFrame[incr1-1]  + tiles.get(incr1).duration;
        }
        maxFrame = TileFrame[incr1];
      }
    }
    
    public Tile getTileToDraw(){
       if (!bAnimated){ //<>// //<>//
         return tiles.get(0);
       }else{
         int frame = (gFrameCounter % maxFrame) +1; 
         int index = Arrays.binarySearch(TileFrame, frame);
         if (index >= 0){
           return tiles.get(index);
         }else{ // negative value is the conditional new entry index 
           return tiles.get(abs(index)-1);
         }
       }
    }
  }
  
  protected class Tile {
    public int x; // coordonnée x sur la tile_map
    public int y; // coordonnée y sur la tile_map
    public int duration;

    public Tile(int Id, int duration) {
      this.x = ((Id-1) % MaxHorizontalTile) * TileSize;
      this.y = floor((Id-1) / MaxHorizontalTile) * TileSize;
      this.duration = duration;
    }
  }
}