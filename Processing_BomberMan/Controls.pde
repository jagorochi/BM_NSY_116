// variable d'état des controles (fleches du pavé numérique)

public class Controls {
  public  boolean left = false;
  public  boolean right = false;
  public  boolean up = false;
  public  boolean down = false;
  public  boolean a = false;
  public  boolean b = false;
  public  boolean c = false;

  public void keyPressed() {
    if (keyCode == DOWN) {
      down = true;
    }
    if (keyCode == UP) {
      up = true;
    }
    if (keyCode == LEFT) {
      left = true;
    }
    if (keyCode == RIGHT) {
      right = true;
    }
  }

  public void keyReleased() {
    if (keyCode == DOWN) {
      down = false;
    }
    if (keyCode == UP) {
      up = false;
    }
    if (keyCode == LEFT) {
      left = false;
    }
    if (keyCode == RIGHT) {
      right = false;
    }
  }
}

// fonction de verification d'état lorsque les touches "fleches" sont pressées
void keyPressed() {
  gCtrl.keyPressed();
}

// fonction de verification d'état lorsque les touches "fleches" sont relachées
void keyReleased() {
  gCtrl.keyReleased();
}