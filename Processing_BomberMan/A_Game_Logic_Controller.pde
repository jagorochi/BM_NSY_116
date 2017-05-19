//<>// //<>// //<>// //<>//

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


  Map map;
  OBJECTS_MANAGER OManager;
  CHARACTERS_MANAGER CManager;
  
  public GLC(String strTileMapPath, String strLevelMapPath) {
    PImage tileMapImg = loadImage(strTileMapPath);
    int pxTileSize= 16;
    int nbMaxMapTileType = 101; // a supprimer car on utilisera qu'un seul type de map...

    map = new Map(this, tileMapImg, pxTileSize, nbMaxMapTileType, strLevelMapPath); // a instancier en premier afin que les variable de taille de la map puissent être définis..
    OManager = new OBJECTS_MANAGER(this, tileMapImg, strLevelMapPath);
    CManager = new CHARACTERS_MANAGER(this, tileMapImg, strLevelMapPath);
  }


  void GameLogicFrameUpdate() {
    //map.updatePlayerAction();
    if (!gDebug) {
      OManager.UpdateObjectsStepFrame();
      CManager.UpdateCharactersStepFrame();
    }
    Rect playerRect = CManager.getPlayerRect(); // récupération de la position du joueur 
    map.render((int)playerRect.x, (int)playerRect.y); // Rendu de la map en fonction de la position mise a jour du joueur ! ATTENTION Cette fonction de rendu est a appelé en premier car une translation de la matrice est effectué sur le joueur..
    OManager.RenderObjects();
    CManager.RenderCharacters();
    
    if (gDebug) {
      OManager.UpdateObjectsStepFrame();
      CManager.UpdateCharactersStepFrame();
    }
    // map.checkPlayerDeathCollision()


    //map.PlayerRender();
  }

  /*
  // -------------------------------------------------------------------------
   // interface publique
   
   public int getMapBlockPositionFromCoordinate(int x, int y, boolean bDecal) {
   return map.getBlockPositionFromCoordinate( x, y, bDecal);
   }
   
   private boolean checkMapRectCollision(Rect hb, Rect player) {
   return map.checkRectCollision( hb, player);
   }
   
   public int getXdifference(int nBlock, int x) {
   return map.getXdifference(nBlock, x);
   }
   public int getYdifference(int nBlock, int y) {
   return map.get(nBlock).rect.y - y;
   }
   // fonction permettant de verifier si un block spécifique est en collision avec un "rect" passé en argument 
   boolean checkHardBlockCollision(int nBlock, Rect playerRect) {
   return map.checkHardBlockCollision( nBlock, playerRect) ;
   }
   // fonction permettant de verifier si un block laisse passer ou pas le joueur. 
   boolean IsStopPlayerBlock(int nBlock) {
   return map.IsStopPlayerBlock( nBlock);
   }*/
}