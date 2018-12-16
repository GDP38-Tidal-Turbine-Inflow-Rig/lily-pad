/*************************************
 Last updated: AM 16.12.18
 
 Extension of Body class to define the position, angle
 and motion of a Square and "Spoon" bodies. 
 
 the easiest way to include dynamics is to use follow()
 which follows the path variable (or mouse) or to use
 react() which integrates the rigid body equations.
 You can also translate() and rotate() directly.
 
Example code:
 
Body body;
void setup(){
  size(400,400);
  body = new SpoonBody(2,2,1,45,new Window(0,0,4,4));
  //body = new SquareBody(2,2,1,30,new Window(0,0,4,4));
  body.end();
  body.display();
}
void draw(){
  background(0);
  body.follow();
  body.display();
}
void mousePressed(){body.mousePressed();}
void mouseReleased(){body.mouseReleased();}
void mouseWheel(MouseEvent event){body.mouseWheel(event);}

**************************************/

/**************************************
AM 2/12/18
Square body class

**************************************/ 
class SquareBody extends Body {
  float h; // width of square
  int m = 4;  // four corners in a rectangle

  SquareBody( float x, float y, float _h, float Start_Degrees, Window window) {
    super(x, y, window);
    h = _h/cos(PI/4);  //correction for being square with corners inside circle // correction factor to change height from width to diagonal length of square h*h
    float dx = 0.5*h, dy = 0.5*h;
    for ( int i=0; i<m; i++ ) {
      float theta = -Start_Degrees*PI/180-TWO_PI*i/((float)m);
      add(xc.x+dx*cos(theta), xc.y+dy*sin(theta));
    }
    end(); // finalize shape
    //ma = //Not defined - only needed for oscillation due to the flow and not for forced oscillation
  }
}

/**************************************
AM 2/12/18
SPOON body class

simple spoon body extension
**************************************/ 
class SpoonBody extends Body {
  float h, a; // height and aspect ratio of ellipse
  int m = 80; //AM must be multiple of 8

  SpoonBody( float x, float y, float _h, float Start_Degrees, Window window) {
    super(x, y, window);
    h = _h; 
    float dx = 0.5*h, dy = 0.5*h;
    float dx2 = ((25+10.36)/25)*0.5*h, dy2 = ((25+10.36)/25)*0.5*h;
    float c2x = dx*cos(Start_Degrees*PI/180), c2y = dx*sin(Start_Degrees*PI/180); //defining origin of larger circle relative to smaller circle origin (0,0)
    for ( int i=0; i<m; i++ ) {
      if ( i<=m/4 ) {
        float theta = -TWO_PI*i/((float)m);
        add(xc.x+dx*cos(Start_Degrees*PI/180 + theta), xc.y+dy*sin(Start_Degrees*PI/180 + theta));
      }
      else if ( i>(3*m/8+1) && i<(5*m/8-1) ) {
        float theta = PI+TWO_PI*i/((float)m);
        add(xc.x-c2x+dx2*cos(Start_Degrees*PI/180 + theta), xc.y-c2y+dy2*sin(Start_Degrees*PI/180 + theta));
      }
      else if ( i>=3*m/4 ) { 
        float theta = -TWO_PI*i/((float)m);
        add(xc.x+dx*cos(Start_Degrees*PI/180 + theta), xc.y+dy*sin(Start_Degrees*PI/180 + theta));
      }
    }
    end(); // finalize shape
    //ma = //Not defined - only needed for oscillation due to the flow and not for forced oscillation
  }
}
