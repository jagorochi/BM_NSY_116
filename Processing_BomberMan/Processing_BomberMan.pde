import java.util.Arrays;
Controls gCtrl;
int gFrameCounter = 0;
Map gMap;

void setup() {

  frameRate(60);
  size(480, 240); // taille de la fenetre
  gCtrl = new Controls();
  PImage ImgTileMap = loadImage("bomber_man_tilemap.png");
  gMap = new Map(ImgTileMap, 16, 40, "BomberMan_Editeur_de_niveau.csv");
  // gMap.display();

  //test();
}



void draw() {
  gFrameCounter++;
  //gMap.UpdateDisplay();
  if ((gFrameCounter % 60) ==0) {
    println("Frame = " + gFrameCounter + ", Framerate = " + frameRate);
  }
  gMap.UpdateDisplay();
}





void test() {

  // initializing unsorted int array
  //int intArr[] = {5, 12, 20, 30, 55};
  int intArr[] = {5, 12};
  // sorting array
  //Arrays.sort(intArr);

  // let us print all the elements available in list
  println("The sorted int array is:");
  for (int number : intArr) {
    println("Number = " + number);
  }

  // entering the value to be searched
  for (int searchVal =0; searchVal < 13; searchVal++) {


    int retVal = Arrays.binarySearch(intArr, searchVal);

    println("The index of element " + searchVal + "  is : " + retVal);
  }
}