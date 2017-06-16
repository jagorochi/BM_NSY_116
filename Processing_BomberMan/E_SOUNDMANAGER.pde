import processing.sound.*;
EnumMap<SOUND_ID, SoundFile> soundBank = new EnumMap<SOUND_ID, SoundFile>(SOUND_ID.class);

//ArrayList<SoundFile> soundBank = new ArrayList<SoundFile>(); // Processing ne semble pas vouloir que l'on puisse créer des fichier son dans une classe....
public class SOUND_MANAGER {
  EnumMap<SOUND_ID, SoundFile> soundBank ;
  ArrayList<SOUND_ID> soundPlayedThisFrame = new ArrayList<SOUND_ID>(); 
  public SOUND_MANAGER() {
    soundBank = new EnumMap<SOUND_ID, SoundFile>(SOUND_ID.class);
    populateSoundBank(soundBank);
  }

  public void stepFrame() {

    soundPlayedThisFrame.clear();
  }

  public void playSFX(SOUND_ID id, float rate) {
    if (!soundPlayedThisFrame.contains(id)) {
      soundBank.get(id).play(rate);
      soundPlayedThisFrame.add(id);
    }
  }

  public void playMUSIC(SOUND_ID id, float rate) {
    if (!soundPlayedThisFrame.contains(id)) {
      //soundBank.get(id).play(rate);
      //soundBank.get(id).stop();
      soundBank.get(id).loop(rate);
      soundPlayedThisFrame.add(id);
    }
  }

  public void stopMUSIC(SOUND_ID id) {
    soundBank.get(id).stop();
  }
}

void populateSoundBank(EnumMap<SOUND_ID, SoundFile> bank) {
  String[] strSoundBank = new String[]{
    "BOMB_DROP1", 
    "BOMB_DROP2", 
    "BOMB_EXPLODE1", 
    "BOMB_EXPLODE2", 
    "BOMB_EXPLODE3", 
    "BOMB_EXPLODE4", 
    "BOMB_EXPLODE5", 
    "BOMB_EXPLODE6", 
    "BOMB_KICK", 
    "BOMBERMAN_DYING", 
    "BOUNCE1", 
    "BOUNCE2", 
    "BUTTON", 
    "CHEST_OPEN", 
    "COMMAND_CANCEL", 
    "COMMAND_SET", 
    "CONFIRM", 
    "CURSOR1", 
    "CURSOR2", 
    "DASH", 
    "ENEMY_DYING", 
    "FALL", 
    "FAIL_JINGLE", 
    "FIRE", 
    "GAME_OVER",
    "HAMMER", 
    "HEART", 
    "HOLD", 
    "HOOKSHOT", 
    "ITEM_GET", 
    "JUMP", 
    "JINGLE",
    "LAZER1", 
    "LAZER2", 
    "LEVEL_COMPLETE",
    "MAGNET1", 
    "MAGNET2", 
    "MAGNET3", 
    "MESSAGE1", 
    "MESSAGE2", 
    "METAL_HIT", 
    "MUSIC_LEVEL1", 
    "MUSIC_TITLE", 
    "ONE_UP", 
    "PAUSE", 
    "RESET", 
    "SECRET", 
    "SELECT", 
    "SLIP", 
    "STOMP", 
    "SWORD", 
    "TELEPORT", 
    "THE_END",
    "THROW", 
    "TIME_UP", 
    "TIMECOUNT", 
    "WALK", 
    "WALL_HIT", 
    "WARP1", 
    "WARP2", 
    "WARP3", 
    "WARP4", 
    "WARP5", 
    "ZOL"};
  int index = 0;

  for (SOUND_ID id : SOUND_ID.values()) {
    bank.put(id, new SoundFile(this, strSoundBank[index] + ".wav"));      
    index++;
  }
}




enum SOUND_ID {
  BOMB_DROP1, 
    BOMB_DROP2, 
    BOMB_EXPLODE1, 
    BOMB_EXPLODE2, 
    BOMB_EXPLODE3, 
    BOMB_EXPLODE4, 
    BOMB_EXPLODE5, 
    BOMB_EXPLODE6, 
    BOMB_KICK, 
    BOMBERMAN_DYING, 
    BOUNCE1, 
    BOUNCE2, 
    BUTTON, 
    CHEST_OPEN, 
    COMMAND_CANCEL, 
    COMMAND_SET, 
    CONFIRM, 
    CURSOR1, 
    CURSOR2, 
    DASH, 
    ENEMY_DYING, 
    FALL, 
    FAIL_JINGLE, 
    FIRE, 
    GAME_OVER,
    HAMMER, 
    HEART, 
    HOLD, 
    HOOKSHOT, 
    ITEM_GET, 
    JUMP, 
    JINGLE,
    LAZER1, 
    LAZER2, 
    LEVEL_COMPLETE,
    MAGNET1, 
    MAGNET2, 
    MAGNET3, 
    MESSAGE1, 
    MESSAGE2, 
    METAL_HIT, 
    MUSIC_LEVEL1, 
    MUSIC_TITLE,
    ONE_UP, 
    PAUSE, 
    RESET, 
    SECRET, 
    SELECT, 
    SLIP, 
    STOMP, 
    SWORD, 
    TELEPORT, 
    THE_END,
    THROW, 
    TIME_UP, 
    TIMECOUNT, 
    WALK, 
    WALL_HIT, 
    WARP1, 
    WARP2, 
    WARP3, 
    WARP4, 
    WARP5, 
    ZOL;
  public static int COUNT = CHARACTER_ACTION.values().length;
}