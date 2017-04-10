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


  BomberMan bm;
  //int xBmPos, yBmPos;
  //int x2BmPos, y2BmPos;
  int nPlayerSpeed = 2;
  int nPlayerBlock;
  int tileSize;
  int playerWalkSpeed;
  Rect playerRect = new Rect();
  Action previousAction = Action.LOOK_FRONT_WAIT;
  Map map;
  public GLC(String strTileMapPath, String strLevelMapPath) {
    PImage tileMapImg = loadImage(strTileMapPath);
    tileSize= 16;
    playerWalkSpeed = 1;
    map = new Map(tileMapImg, tileSize, 101, strLevelMapPath);
    int PlayerSpawnPosition = 94; /// temporaire car doit être décidé en fonction du level.

    nPlayerBlock = PlayerSpawnPosition;
    playerRect.x = (PlayerSpawnPosition % map.mapWidth) * map.TileSize;
    playerRect.y = floor(PlayerSpawnPosition / map.mapWidth) * map.TileSize;
    playerRect.h = map.TileSize;
    playerRect.w = map.TileSize;
    bm = new BomberMan(tileMapImg, PlayerSpawnPosition);
  }


  void GameLogicFrameUpdate() {
    map.UpdateDisplay();
    // bm.animationUpdate(0, -16);

    Action b = Action.VOID;
    if (gCtrl.left) {
      b =  tryLeftStep();
    } else if (gCtrl.right) {
      b = tryRightStep();
    } else if (gCtrl.up) {
      b = tryUpStep(); 
      /*
      Action.LOOK_UP_WALK;
       if (checkUpMove()) {
       playerRect.y -=1;
       recalculateBlock();
       }*/
    } else if (gCtrl.down) {
      b = tryDownStep();
    } else if (gCtrl.a) {
      b = Action.DIE;
    } else if (gCtrl.b) {
      b = Action.VICTORY;
    } else {
      b = Action.VOID;
    }


    if (gDebug) {
      pushMatrix();
       scale(gSketchScale);
      int x = (nPlayerBlock % map.mapWidth) * map.TileSize;
      int y = floor(nPlayerBlock / map.mapWidth) * map.TileSize;
      stroke(0, 255, 0);
      rect(x+1, y+1, playerRect.h-2, playerRect.w-2);
      popMatrix();
    }
    bm.drawAnimation(b, playerRect.x, playerRect.y+1);
    if (gDebug) {

      pushMatrix();
      scale(gSketchScale);
      stroke(0, 0, 255);
      rect(playerRect.x, playerRect.y, playerRect.h, playerRect.w);
      
      popMatrix();
    }
  }

  private Action tryRightStep() {
    if ( map.checkHardBlockCollision(nPlayerBlock+1, playerRect)) {
      playerRect.x +=playerWalkSpeed; // on avance
      int yDiff = map.getYdifference(nPlayerBlock+1, playerRect.y);
      if (yDiff < 0) {
        if (map.IsStopPlayerBlock(nPlayerBlock+1 + map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth)) {
          if (abs(yDiff)< playerWalkSpeed) {
            playerRect.y -= abs(yDiff); // +
          } else {
            playerRect.y -= playerWalkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (map.IsStopPlayerBlock(nPlayerBlock+1 - map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth)) {
          if (abs(yDiff)< playerWalkSpeed) {
            playerRect.y += abs(yDiff);
          } else {
            playerRect.y += playerWalkSpeed;
          }
        }
      }
      nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
      return Action.LOOK_RIGHT_WALK;
    } else {
      int yDiff = map.getYdifference(nPlayerBlock+1, playerRect.y);
      if (yDiff < 0) { // plus bas
        //println("plus bas");
        if (!map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth) && !map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth+1)) {
          playerRect.y +=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_DOWN_WALK;
        }
      } else if (yDiff > 0) {
        //println("plus haut");
        if (!map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth) && !map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth+1)) {
          playerRect.y -=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_UP_WALK;
        }
      }
    }
    return Action.LOOK_RIGHT_WALK;
  }

  private Action tryLeftStep() {
    if ( map.checkHardBlockCollision(nPlayerBlock-1, playerRect)) {
      playerRect.x -=playerWalkSpeed; // on avance
      int yDiff = map.getYdifference(nPlayerBlock-1, playerRect.y);
      if (yDiff < 0) {
        if (map.IsStopPlayerBlock(nPlayerBlock-1 + map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth)) {
          if (abs(yDiff)< playerWalkSpeed) {
            playerRect.y -= abs(yDiff); // +
          } else {
            playerRect.y -= playerWalkSpeed;
          }
        }
      } else if (yDiff>0) {
        if (map.IsStopPlayerBlock(nPlayerBlock -1 - map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock  - map.mapWidth)) {
          if (abs(yDiff)< playerWalkSpeed) {
            playerRect.y += abs(yDiff);
          } else {
            playerRect.y += playerWalkSpeed;
          }
        }
      }
      nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
      return Action.LOOK_LEFT_WALK;
    } else {
      int yDiff = map.getYdifference(nPlayerBlock-1, playerRect.y);
      if (yDiff < 0) { // plus bas
        //println("plus bas");
        if (!map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth) && !map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth-1)) {
          playerRect.y +=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_DOWN_WALK;
        }
      } else if (yDiff > 0) {
        //println("plus haut");
        if (!map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth) && !map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth-1)) {
          playerRect.y -=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_UP_WALK;
        }
      }
    }
    return Action.LOOK_LEFT_WALK;
  }

  private Action tryUpStep() {
    if ( map.checkHardBlockCollision(nPlayerBlock- map.mapWidth, playerRect)) {
      playerRect.y -=playerWalkSpeed; // on avance
      int xDiff = map.getXdifference(nPlayerBlock- map.mapWidth, playerRect.x);
      if (xDiff > 0) {
        if (map.IsStopPlayerBlock(nPlayerBlock - 1 - map.mapWidth) || map.IsStopPlayerBlock(nPlayerBlock -1 )) {
          if (abs(xDiff)< playerWalkSpeed) {
            playerRect.x += abs(xDiff); // +
          } else {
            playerRect.x += playerWalkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (map.IsStopPlayerBlock(nPlayerBlock + 1 - map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock +1)) {
          if (abs(xDiff)< playerWalkSpeed) {
            playerRect.x -= abs(xDiff);
          } else {
            playerRect.x -= playerWalkSpeed;
          }
        }
      }
      nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
      return Action.LOOK_UP_WALK;
    } else {
      int xDiff = map.getXdifference(nPlayerBlock- map.mapWidth, playerRect.x);
      if (xDiff > 0) { // plus a gauche
        if (!map.IsStopPlayerBlock(nPlayerBlock - 1) && !map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth-1)) {
          playerRect.x -=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_LEFT_WALK;
        }
      } else if (xDiff < 0) {
        // plus à droite
        if (!map.IsStopPlayerBlock(nPlayerBlock +1 ) && !map.IsStopPlayerBlock(nPlayerBlock - map.mapWidth+1)) {
          playerRect.x +=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_RIGHT_WALK;
        }
      }
    }
    return Action.LOOK_UP_WALK;
  }

  private Action tryDownStep() {
    if (map.checkHardBlockCollision(nPlayerBlock+  map.mapWidth, playerRect)) {
      playerRect.y +=playerWalkSpeed; // on avance
      int xDiff = map.getXdifference(nPlayerBlock+ map.mapWidth, playerRect.x);
      if (xDiff > 0) {
        if (map.IsStopPlayerBlock(nPlayerBlock - 1 + map.mapWidth) || map.IsStopPlayerBlock(nPlayerBlock -1 )) {
          if (abs(xDiff)< playerWalkSpeed) {
            playerRect.x += abs(xDiff); // +
          } else {
            playerRect.x += playerWalkSpeed;
          }
        }
      } else if (xDiff<0) {
        if (map.IsStopPlayerBlock(nPlayerBlock + 1 + map.mapWidth)||map.IsStopPlayerBlock(nPlayerBlock +1)) {
          if (abs(xDiff)< playerWalkSpeed) {
            playerRect.x -= abs(xDiff);
          } else {
            playerRect.x -= playerWalkSpeed;
          }
        }
      }
      nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
      return Action.LOOK_DOWN_WALK;
    } else {
      int xDiff = map.getXdifference(nPlayerBlock+ map.mapWidth, playerRect.x);
      if (xDiff > 0) { // plus a droite
        if (!map.IsStopPlayerBlock(nPlayerBlock - 1) && !map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth-1)) {
          playerRect.x -=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_LEFT_WALK;
        }
      } else if (xDiff < 0) {
        // plus à droite
        if (!map.IsStopPlayerBlock(nPlayerBlock +1 ) && !map.IsStopPlayerBlock(nPlayerBlock + map.mapWidth+1)) {
          playerRect.x +=1;
          nPlayerBlock = map.getBlockPositionFromCoordinate(playerRect.x, playerRect.y);
          return Action.LOOK_RIGHT_WALK;
        }
      }
    }
    return Action.LOOK_DOWN_WALK;
  }

  boolean checkUpMove() {
    return  map.checkHardBlockCollision(nPlayerBlock-map.mapWidth, playerRect);
  }

  boolean checkDownMove() {
    return  map.checkHardBlockCollision(nPlayerBlock+map.mapWidth, playerRect);
  }

  void recalculateBlock() {
    // nPlayerBlock = getBlockPositionFromCoordinate(playerRect.x,playerRect.y);
  }
}