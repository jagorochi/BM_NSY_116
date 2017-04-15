//<>// //<>// //<>//

/*
  Game Logic Controller
 
 
 */
class GLC {
  /* 
   1. initialisation de la map HardBlock (couche 0)
   2. Initialisation des objets semi statique(couche 1)
   3. initialisation des objets semi statique(couche 2)
   4. Spawn des enemies (couche 3)
   5. Spawn du joueur (couche 4)
   6. 
   7. Soft / Overlay
   */

  Action previousAction = Action.LOOK_FRONT_WAIT;
  Map map;
  
  public GLC(String strTileMapPath, String strLevelMapPath) {
    PImage tileMapImg = loadImage(strTileMapPath);
    int pxTileSize= 16;
    int nbMaxMapTileType = 101;
    map = new Map(tileMapImg, pxTileSize, nbMaxMapTileType, strLevelMapPath);
  }


  void GameLogicFrameUpdate() {
    
    
    map.updatePlayerAction();
    // map.checkPlayerDeathCollision()
    map.render(); // render only a portion of the map depending of the player's position..
    map.PlayerRender();
    

  }



}