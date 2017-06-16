

class BEZIER_Animator {


  PVector v1, v2, v3, v4;
  int duration, wait;
  float  pAx, pAy, pAz, pBx, pBy, pBz, pCx, pCy, pCz; // point de calcul intermediaire
  BIAS_TYPE bias;
  float angle;

  float pfParam, pfStep;
  int totalDuration;
  public BEZIER_Animator(PVector v1, PVector v2, PVector v3, PVector v4, float angle, int duration, int wait, BIAS_TYPE bias) { //, float ElasticAmplitude, float ElasticAuxiliar, float ElasticPeriod) {
    this.angle = angle;
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.v4 = v4;
    this.duration = duration;
    totalDuration = duration;
    this.wait = wait;
    this.bias = bias;
    
    //  calcul des points auxiliaire a la courbe
    pCx = 3*(v2.x - v1.x);
    pCy = 3*(v2.y - v1.y);
    pCz = 3*(v2.z - v1.z);
    pBx = 3*(v3.x - v2.x) - pCx;
    pBy = 3*(v3.y - v2.y) - pCy;
    pBz = 3*(v3.z - v2.z) - pCz;
    pAx = v4.x - v1.x - pCx - pBx;
    pAy = v4.y - v1.y - pCy - pBy;
    pAz = v4.z - v1.z - pCz - pBz;
    pfParam = 0;
    pfStep = 1.0/duration;
  }

  /*
  //  obtention d'un point sur la courbe
   private PVector GetPathPoint(float fParam) { // valeur parametrique (0 --> 1)
   float p;
   switch (bias) {
   case IN : 
   p = pow(fParam, 3);
   break;
   case OUT :
   p = 1-abs(pow(fParam -1, 3));
   break;
   case BOTH:
   p = (1 - cos(fParam * PI)) / 2.0;
   break;
   case BOUNCE : 
   if (fParam < 0.3636) {
   p  = 7.562500 * fParam * fParam;
   } else if (fParam < 0.7272) {
   float t = fParam - 0.545455;
   p =  (7.562500 * t * t + 0.750000);
   } else if (fParam < 0.9090) {
   float t = ( fParam - 0.818182);
   p = (7.562500 * t * t + 0.937500);
   } else {
   float t = ( fParam - 0.954545);
   p = (7.562500 * t * t + 0.984375);
   }
   default :
   p = fParam;
   break;
   }
   
   if (p > 1) p = 1;
   float Vx = (pAx * (pow(p, 3))) + (pBx * (pow(p, 2))) + (pCx * p) + v1.x ;
   float Vy = (pAy * (pow(p, 3))) + (pBy * (pow(p, 2))) + (pCy * p) + v1.y ;
   float Vz = (pAz * (pow(p, 3))) + (pBz * (pow(p, 2))) + (pCz * p) + v1.z ; 
   return new PVector(Vx, Vy, Vz);
   }
   */

  public boolean updateAnimationStep(PImage img) {
    if (wait == 0) {
      pfParam += pfStep;
      if (pfParam > 1) pfParam = 1;
      float p;
      switch (bias) {
      case IN : 
        p = pow(pfParam, 3);
        break;
      case OUT : 
        p = 1-abs(pow(pfParam -1, 2));
        break;
      case BOTH:
        p = (1 - cos(pfParam * PI)) / 2.0;
        break;

      
      case BOUNCE : 
        if (pfParam < 0.3636) {
          p  = 7.562500 * pfParam * pfParam;
        } else if (pfParam < 0.7272) {
          float t = pfParam - 0.545455;
          p =  (7.562500 * t * t + 0.750000);
        } else if (pfParam < 0.9090) {
          float t = ( pfParam - 0.818182);
          p = (7.562500 * t * t + 0.937500);
        } else {
          float t = ( pfParam - 0.954545);
          p = (7.562500 * t * t + 0.984375);
        }
        break;
      default :
        p = pfParam;
        break;
      }

      if (p >= 1) {
        pushMatrix();
        scale(v4.z);
        image(img, v4.x, v4.y);
        popMatrix();
        return false;
      } else {
        float Vx = (pAx * (pow(p, 3))) + (pBx * (pow(p, 2))) + (pCx * p) + v1.x ;
        float Vy = (pAy * (pow(p, 3))) + (pBy * (pow(p, 2))) + (pCy * p) + v1.y ;
        float Vz = (pAz * (pow(p, 3))) + (pBz * (pow(p, 2))) + (pCz * p) + v1.z ; 
        float a = (1-p)*angle;
        // me.mUpdateTransform(vNew) // mise a jour de la transformation
        pushMatrix();
        translate(Vx,Vy);
        rotate(a);
        scale(Vz);
        image(img, 0, 0);
        popMatrix();
        if (pfParam == 1) {
          return false;
        }
      }
    } else {
      image(img,v1.x,v1.y);
      wait--;
    }
    return true;
  }
}