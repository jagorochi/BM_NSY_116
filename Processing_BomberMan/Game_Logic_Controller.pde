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
   rect 
   */

  
 // BomberMan bm;
  //int xBmPos, yBmPos;
  //int x2BmPos, y2BmPos;
  //int nPlayerSpeed = 2;
  //int nPlayerBlock;
  //int tileSize;
  //int playerWalkSpeed;
  //Rect playerRect = new Rect();
  Action previousAction = Action.LOOK_FRONT_WAIT;
  Map map;
  public GLC(String strTileMapPath, String strLevelMapPath) {
    PImage tileMapImg = loadImage(strTileMapPath);
    int pxTileSize= 16;
    int nbMaxMapTileType = 101;
    map = new Map(tileMapImg, pxTileSize, nbMaxMapTileType, strLevelMapPath);
    
    /*
    int PlayerSpawnPosition = 94; /// temporaire car doit être décidé en fonction du level.
    nPlayerBlock = PlayerSpawnPosition;
    playerRect.x = (PlayerSpawnPosition % map.mapWidth) * map.TileSize;
    playerRect.y = floor(PlayerSpawnPosition / map.mapWidth) * map.TileSize;
    playerRect.h = map.TileSize;
    playerRect.w = map.TileSize;*/
    
    
    
  }


  void GameLogicFrameUpdate() {
    
    
    map.updatePlayerAction();
    map.render();
    map.PlayerRender();
    
    /*
    Action b = Action.VOID;
    if (gCtrl.left) {
      b =  tryLeftStep();
    } else if (gCtrl.right) {
      b = tryRightStep();
    } else if (gCtrl.up) {
      b = tryUpStep(); 
    } else if (gCtrl.down) {
      b = tryDownStep();
    } else if (gCtrl.a) {
      b = Action.DIE;
    } else if (gCtrl.b) {
      b = Action.VICTORY;
    } else {
      b = Action.VOID;
    }
    */

    if (gDebug) {
    
    /*
      int x = (nPlayerBlock % map.mapWidth) * map.TileSize;
      int y = floor(nPlayerBlock / map.mapWidth) * map.TileSize;
      stroke(0, 255, 0);
      rect(x+1, y+1, playerRect.h-2, playerRect.w-2);*/
    
    }
    
    
    if (gDebug) {
    /*
    
      stroke(0, 0, 255);
      rect(playerRect.x, playerRect.y, playerRect.h, playerRect.w);*/
      
    
    }
  }



}