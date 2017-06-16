 //<>//

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

  private ArrayList <PImage> iTransition;
  PImage titlescreen;
  PImage TransitionImage; // image utilisée lors de la transition.
  PImage GameOverImage;
  PImage TheEndImage;
  private int life;
  MAP map;
  OBJECTS_MANAGER OManager;
  CHARACTERS_MANAGER CManager;
  int waitFrame; // nombre de frames durant lequel on attend.
  LEVEL_END_EVENT lastEvent;
  ArrayList<BEZIER_Animator> BA = new ArrayList<BEZIER_Animator>();
  boolean bTransition;
  GLC_STATUS status = GLC_STATUS.TITLE_WAIT;
  int activeLevel;
  String[] LevelsMap;
  private boolean AllLevelSwitchOn; // permet d'indiquer si tous les switchs de la map sont allumées
  private boolean AllDeadMeat; // permet d'indiquer si tous les enemies de la map sont Red is dead.

  public GLC(String strTileMapPath, String[] strLevelMapPath) {
    PImage tileMapImg = loadImage(strTileMapPath);
    titlescreen = loadImage("TITLE_SCREEN.png");
    GameOverImage = loadImage("GAME_OVER.png");
    TheEndImage = loadImage("THE_END.png");
    LevelsMap = strLevelMapPath;
    int pxTileSize= 16;
    waitFrame = -1;
    int nbMaxMapTileType = 101; // a supprimer car on utilisera qu'un seul type de map...
    map = new MAP(this, tileMapImg, pxTileSize, nbMaxMapTileType); // a instancier en premier afin que les variable de taille de la map puissent être définis..
    OManager = new OBJECTS_MANAGER(this, tileMapImg);
    CManager = new CHARACTERS_MANAGER(this, tileMapImg);

    // création du quadrillage de la scene
    iTransition = new ArrayList <PImage>();
    bTransition = true;
    for (int incr = 0; incr < 13*17; incr++) {
      iTransition.add(createImage(16, 16, ARGB));
    }
    gSound.playMUSIC(SOUND_ID.MUSIC_TITLE, 1);
  }

  void stepFrame() {
    switch (status) { //   TITLE_WAIT, TITLE_LEVEL, LEVEL_PLAY, PLAY_STOP, GOODPLAY_LEVEL, BADPLAY_LEVEL, PLAY,

    case PLAY : 
      pushMatrix();
      scale(gSketchScale);
      GameLogicFrameUpdate();
      popMatrix();
      break;
    case TITLE_WAIT :
      if (gCtrl.aKP) { // si le joueur appuie sur le bouton A
        //TransitionImage1 = titlescreen; // copie de la scene directement dans l'image de transition..
        background(100, 100, 100); // fond gris
        activeLevel = 0;
        life = 3;
        displayTextLevel("Niveau " + activeLevel+1); // affichage d'un texte de transition

        TransitionImage = get(0, 0, ScreenRect.w, ScreenRect.w); // récupération de cette image qui sera utilisée ensuite..
        updateTransitionImageBuffer(); // on capture cette image car on va devoir l'afficher
        //image(titlescreen, 0, 0);//,ScreenRect.w * gSketchScale,ScreenRect.h * gSketchScale);
        status = GLC_STATUS.TITLE_LEVEL;
        initTransitionAnimationOut(100, false);
        waitFrame = 100;
        gSound.stopMUSIC(SOUND_ID.MUSIC_TITLE);
        //TransitionImage = titlescreen;
      }
      pushMatrix();
      scale(gSketchScale);
      image(titlescreen, 0, 0); // on affiche l'image de l'écran titre
      popMatrix();
      break;
    case TITLE_LEVEL : 
      waitFrame--;
      if (waitFrame == 60) {

        gSound.playSFX(SOUND_ID.JINGLE, 1);
      }

      pushMatrix();
      scale(gSketchScale);
      image(titlescreen, 0, 0);
      if (!updateTransitionAnimation()) {
        BA.clear();
        // image(TransitionImage, 0, 0);
        // TransitionImage = get(0, 0, ScreenRect.w, ScreenRect.w);
        // copie de la scene directement dans l'image de transition..
        status = GLC_STATUS.LEVEL_PLAY;
        map.initSession(LevelsMap[activeLevel]);
        CManager.initSession(LevelsMap[activeLevel], true);
        OManager.initSession(LevelsMap[activeLevel]);
        InitTransitionAnimationIn(100, true);
        AllLevelSwitchOn = false;
        AllDeadMeat = false;
        waitFrame = 120; // attente de l'affichage du niveau...
      }
      popMatrix();

      break;
    case LEVEL_PLAY:
      if ( waitFrame== 0 ) {
        GameLogicFrameUpdate();
        updateTransitionImageBuffer();
        pushMatrix();
        scale(gSketchScale);
        image(TransitionImage, 0, 0);
        if (!updateTransitionAnimation()) {
          status = GLC_STATUS.PLAY;
          BA.clear();
        }
        popMatrix();
      } else {

        waitFrame--;
        if (waitFrame == 1) {
          gSound.playMUSIC(SOUND_ID.MUSIC_LEVEL1, 1);
        }
      }
      break;
    case PLAY_LEVEL :
      if (waitFrame == 160 && lastEvent == LEVEL_END_EVENT.DOOR_EXITED) {
        gSound.playSFX(SOUND_ID.LEVEL_COMPLETE, 0.5);
      }
      if (waitFrame == 120 && lastEvent == LEVEL_END_EVENT.PLAYER_DIE) {

        gSound.playSFX(SOUND_ID.FAIL_JINGLE, 1);
      }

      if (waitFrame == 1) {
        background(100, 100, 100); // fond gris
        displayTextLevel("Niveau " + (activeLevel+1)); // affichage d'un texte de transition
        TransitionImage = get(0, 0, ScreenRect.w, ScreenRect.w);
        BA.clear();
        InitTransitionAnimationIn(100, false);
        gSound.playSFX(SOUND_ID.JINGLE, 1);
      } 
      if ( waitFrame > 0) {
        pushMatrix();
        scale(gSketchScale);
        GameLogicFrameUpdate();
        popMatrix();
      }
      if ( waitFrame== 0 ) {
        GameLogicFrameUpdate();
        updateTransitionImageBuffer();
        pushMatrix();
        scale(gSketchScale);
        image(TransitionImage, 0, 0);

        if (!updateTransitionAnimation()) {
          status = GLC_STATUS.LEVEL_PLAY;
          BA.clear();
          InitTransitionAnimationIn(100, true);
          waitFrame = 121; // attente de l'affichage du niveau...
          map.clearSession();
          map.initSession(LevelsMap[activeLevel]);
          CManager.ClearSession();
          if (lastEvent == LEVEL_END_EVENT.PLAYER_DIE) {
            CManager.initSession(LevelsMap[activeLevel], true); /// reset les stats du perso
          } else {
            CManager.initSession(LevelsMap[activeLevel], false);
          }
          OManager.ClearSession();
          OManager.initSession(LevelsMap[activeLevel]);
          AllLevelSwitchOn = false;
          AllDeadMeat = false;
        }
        popMatrix();
      } 
      if (waitFrame > 0) {
        waitFrame--;
      }
      break;
    case PLAY_END :
      /*
      if (waitFrame == 120 && lastEvent == LEVEL_END_EVENT.DOOR_EXITED) {
       gSound.playSFX(SOUND_ID.THE_END, 0.5);
       }
       if (waitFrame == 120 && lastEvent == LEVEL_END_EVENT.PLAYER_DIE) {
       
       gSound.playSFX(SOUND_ID.GAME_OVER, 0.5);
       }*/

      if (waitFrame == 1) {
        //background(100, 100, 100); // fond gris
        if (lastEvent == LEVEL_END_EVENT.DOOR_EXITED) {
          image( TheEndImage, 0, 0);
          TransitionImage = TheEndImage;
        } else {
          image( GameOverImage, 0, 0);
          TransitionImage = GameOverImage;
        }
        updateTransitionImageBuffer();
        BA.clear();
        initTransitionAnimationOut(100, false);
        // gSound.playSFX(SOUND_ID.JINGLE, 1);
        if (lastEvent == LEVEL_END_EVENT.PLAYER_DIE) {
          gSound.playSFX(SOUND_ID.GAME_OVER, 0.5);
        }
      } 
      if ( waitFrame >= 0) {
        pushMatrix();
        scale(gSketchScale);
        GameLogicFrameUpdate();
        popMatrix();
      }
      if ( waitFrame== 0 ) {

        // updateTransitionImageBuffer();
        pushMatrix();
        scale(gSketchScale);
        // image(TransitionImage, 0, 0);

        if (!updateTransitionAnimation()) {
          status = GLC_STATUS.THE_END;
          BA.clear();
          InitTransitionAnimationIn(100, true);
          waitFrame = 121; // attente de l'affichage du niveau...
          map.clearSession();
          CManager.ClearSession();
          OManager.ClearSession();
          AllLevelSwitchOn = false;
          AllDeadMeat = false;
        }
        popMatrix();
      }
      if (waitFrame > 0) {
        waitFrame--;
      }
      break;
    case THE_END :
      if (gCtrl.aKP) { // si le joueur appuie sur le bouton A

        image(titlescreen, 0, 0); // on affiche l'image de l'écran titre
        updateTransitionImageBuffer(); // on capture cette image car on va devoir l'afficher


        pushMatrix();
        scale(gSketchScale);
        image(TransitionImage, 0, 0);
        popMatrix();

        //image(titlescreen, 0, 0);//,ScreenRect.w * gSketchScale,ScreenRect.h * gSketchScale);
        status = GLC_STATUS.END_TITLE;
        initTransitionAnimationOut(100, false);
        waitFrame = 100;

        //TransitionImage = titlescreen;
      }
      break;
    case END_TITLE :
      waitFrame--;
      if (waitFrame == 60) {
        gSound.playMUSIC(SOUND_ID.MUSIC_TITLE, 1);
      }

      pushMatrix();
      scale(gSketchScale);
      image(TransitionImage, 0, 0);
      if (!updateTransitionAnimation()) {
        BA.clear();
        // image(TransitionImage, 0, 0);
        // TransitionImage = get(0, 0, ScreenRect.w, ScreenRect.w);
        // copie de la scene directement dans l'image de transition..
        status = GLC_STATUS.TITLE_WAIT;
      }
      popMatrix();

      break;
    default :
    }
  }

  public void LevelEndingEvent(LEVEL_END_EVENT endEvent) {
    lastEvent = endEvent;
    switch (endEvent) {
    case PLAYER_DIE :
      life--;
      if (life == 0) {
        // GAME OVER
        status = GLC_STATUS.PLAY_END;
      } else {
        status = GLC_STATUS.PLAY_LEVEL;
        println("LevelEndingEvent :  PLAYER_DIE");
      }
      waitFrame = 200;
      gSound.stopMUSIC(SOUND_ID.MUSIC_LEVEL1);
      break;
    case  DOOR_EXITED:
      activeLevel++;
      if (activeLevel >= LevelsMap.length) {
        println("LevelEndingEvent :  THE END");
        status = GLC_STATUS.PLAY_END;

        gSound.playSFX(SOUND_ID.THE_END, 0.5);
      } else {
        println("LevelEndingEvent :  NExt LEVEL");
        status = GLC_STATUS.PLAY_LEVEL;
      }

      waitFrame = 200;
      gSound.stopMUSIC(SOUND_ID.MUSIC_LEVEL1);

      break;

    case TIME_OUT:
      break;

    default:
      waitFrame = -1;
    }
  }

  public void confirmAllSwitchOn() {
    AllLevelSwitchOn = true;
    if  (AllLevelSwitchOn && AllDeadMeat) {
      OManager.OpenDoor();
    }
  }

  public void confirmAllDeadMeat(boolean b) {
    AllDeadMeat = b; /// les enemies peuvent respawner...
    if  (AllLevelSwitchOn && AllDeadMeat) {
      OManager.OpenDoor();
    }
  }


  private void displayTextLevel(String txt1) {
    textAlign(CENTER);
    textFont(fontMM);
    for (int incr = 0; incr<50; incr++) {
      fill((int)random(0, 150), (int)random(0, 150), (int)random(0, 150));
      // fill(150,incr*2,incr*2);
      pushMatrix();
      int xDecal = (int)random(0, 200) - 100;
      int yDecal = (int)random(0, 250) - 115;
      translate((ScreenRect.w )/2+xDecal, (ScreenRect.h )/2+yDecal);
      scale(0.75);
      rotate(radians(random(0, 45)-25));
      text(txt1, 0, 0); // ombre du texte (noir)
      popMatrix();
    }

    fill(0);
    text(txt1, (ScreenRect.w )/2+3, (ScreenRect.h )/2+3);
    fill(255);
    text(txt1, (ScreenRect.w )/2, (ScreenRect.h )/2);

    textFont(HeartFont); // fonte spéciale pour afficher des coeurs
    String strLife = "";
    if (life == 1) {
      strLife = "r";
    } else {
      for (int incr = 0; incr < life; incr++) {
        strLife += "f";
      }
    }

    fill(255, 0, 0);
    text(strLife, (ScreenRect.w )/2, ((ScreenRect.h )/4)*3);
    noFill();
  }


  private void InitTransitionAnimationIn(int duration, boolean bInverted) {
    // requiert une image a "recouvrir" par la zone de jeu

    float centerX = (ScreenRect.w / 2  + (gpxMapTileSize / 2)) ;
    float centerY = (ScreenRect.h /2 + (gpxMapTileSize / 2)) ;

    for (int y = 0; y < 13; y ++) {
      for (int x = 0; x < 17; x ++) {
        int xPos = x*gpxMapTileSize;
        int yPos = y*gpxMapTileSize;
        float angle = atan2(centerY - yPos, centerX - xPos);
        float yUnit = -sin(angle+(PI*1.8));
        float xUnit = -cos(angle+(PI*1.8));
        PVector v1 = new PVector(centerX+ 16 * gpxMapTileSize* xUnit, centerY + 16 * gpxMapTileSize * yUnit, 2); // start
        yUnit = -sin(angle);
        xUnit = -cos(angle);
        PVector v2 = new PVector(centerX- (16*gpxMapTileSize*xUnit), centerY - (16*gpxMapTileSize * yUnit), 3);
        yUnit = -sin(angle+(PI/2));
        xUnit = -cos(angle+(PI/2));
        PVector v3 = new PVector(centerX+ (16*gpxMapTileSize*xUnit), centerY + (16*gpxMapTileSize * yUnit), 0.5);
        PVector v4 = new PVector(xPos, yPos, 1); // end

        int wait  = abs(x-8)*5 + abs(y-6)*4;
        if (bInverted) {
          BA.add(new BEZIER_Animator(v1, v2, v3, v4, PI*2, duration, wait, BIAS_TYPE.OUT));
        } else {
          BA.add(new BEZIER_Animator(v4, v3, v2, v1, PI*2, duration, wait, BIAS_TYPE.IN));
        }
      }
    }
  }

  private void initTransitionAnimationOut(int duration, boolean bInverted) {
    for (int y = 0; y < 13; y ++) {
      for (int x = 0; x < 17; x ++) {
        int xPos = x*gpxMapTileSize;
        int yPos = y*gpxMapTileSize;
        PVector v4 = new PVector(xPos, yPos, 1); // end
        PVector v3 = new PVector( xPos + (3*gpxMapTileSize), yPos + (3*gpxMapTileSize), 2);
        PVector v2 = new PVector(-(10*gpxMapTileSize), -(10*gpxMapTileSize), 3);
        PVector v1 = new PVector(xPos+ 208 * 2, yPos+ 208*2, 4); // start
        int wait  = x * 3 + y*2;
        if (bInverted) {
          BA.add(new BEZIER_Animator(v4, v3, v2, v1, PI*2, duration, wait, BIAS_TYPE.OUT));
        } else {
          BA.add(new BEZIER_Animator(v1, v2, v3, v4, PI*2, duration, wait, BIAS_TYPE.IN));
        }
      }
    }
  }


  private void updateTransitionImageBuffer() {
    // copie ce qui est affiché sur sur la scène avec un scale à 1.
    for (int y = 0; y < 13; y ++) {
      for (int x = 0; x < 17; x ++) {
        iTransition.set(y*17 + x, get(x * gpxMapTileSize, y * gpxMapTileSize, gpxMapTileSize, gpxMapTileSize));
      }
    }
  }

  private boolean updateTransitionAnimation() {
    // mise a jour de l'animation de toutes les tuiles composants la "transistion"..
    boolean b = false;
    for (int incr = 0; incr < 13*17; incr++) {
      if (BA.get(incr).updateAnimationStep(iTransition.get(incr))) {
        b = true;
      }
    }
    return b;
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
  }
}