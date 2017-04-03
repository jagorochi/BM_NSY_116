 //<>// //<>// //<>//
class Map extends Map_Data {
  private int mapWidth;
  private int mapHeight;
  private ArrayList<HardBlock> map = new ArrayList<HardBlock>();
  private PImage pImg;
  private PGraphics pg ;
  private PImage  pi = createImage(16,16,ARGB);
  
  public Map(PImage pImg, int TileSize, int MaxHorizontalTile, String strMapPath) {
    this.TileSize = TileSize;
    this.MaxHorizontalTile = MaxHorizontalTile;
    this.pImg = pImg;


    String file[] = loadStrings(strMapPath); // chaque valeur dans la liste est une ligne de texte..
    mapHeight = file.length;
    mapWidth = split(file[0], ';').length;
    pg = createGraphics(mapWidth * TileSize, mapHeight * TileSize);
    pi.copy(pImg,0,0,16,16,0,0,16,16);
    
    for (int incr1 = 0; incr1 < mapHeight; incr1++) {
      String[] l = split(file[incr1], ";");
      for ( int incr2 = 0; incr2 < mapWidth; incr2++) {
        int t = Integer.parseInt(split(l[incr2], ",")[0]);
        map.add(GetHardBlock(t));
      }
    }
    println("done");
  }



  void UpdateDisplay2(){
    int x,y;
    int s = map.size();
    for (int incr1 = 0; incr1 < s; incr1++) {
      
      x = (incr1 % mapWidth) * TileSize;
      y = floor(incr1 / mapWidth) * TileSize;
      
      image(pi,x,y);
    }
    
  }
  
  void UpdateDisplay() {
    int t1 = millis();
    int x, y;
    pg.beginDraw();
    int s = map.size();
    for (int incr1 = 0; incr1 < s; incr1++) {
      //Tile t = map.get(incr1).getTileToDraw();//
      Tile t = map.get(incr1).tiles.get(0);
      x = (incr1 % mapWidth) * TileSize;
      y = floor(incr1 / mapWidth) * TileSize;
      pg.copy(pImg, t.x, t.y, TileSize, TileSize, x, y, TileSize, TileSize);
    }
    
    pg.endDraw();
    int t2 = millis() - t1;
    image(pg, 0, 0); 
    int t3 = (millis() - t1) - t2;
    println("Frame " + gFrameCounter + " : pg = " + t2 + ", image = " + t3);
    
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
}


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