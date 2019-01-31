/*********************************************************
                  Main Window!

Click the "Run" button to Run the simulation.

Change the geometry, flow conditions, numerical parameters
visualizations and measurements from this window.

This screen has an example. Other examples are found at 
the top of each tab. Copy/paste them here to run, but you 
can only have one setup & run at a time.

Modified Lilypad script for GDP 38
Modified by JS, FF, AM
Date started: 1/12/18
Date last updated: 
*********************************************************/


/*********************************************************
DECLARATIONS 
*********************************************************/
BDIM flow;
Body body;
ParticlePlot plot;
float tstep = 0;

// Environment constants *********************************
int timestep = 1;                                          // Current time step
int endstep = 4001;                                        // Number of iterations before simulation exits
int n=(int)pow(2,7);                                       // number of grid points
int nlines = 50;                                           // Number of streamlines
float h = 1/n;                                               // Width of one grid cell (in non-dimensionalised units)
float dt = 0.5;

// Bodytype variables ************************************
// General
int BODYTYPE = 2;
float mu = 0.0011375;
float rho = 1000;
float Rotate_Degrees = 45;
// Circle - BODYTYPE 1
float L_circle = n/6;                                           // length-scale in grid units
float l_circle = 0.1;
float u_circle = 0.09916;                                            // inflow velocity
float Re_circle = rho*u_circle*l_circle/mu;
// Foil - BODYTYPE 2
float l_foil = 0.2;
float u_foil = 0.09916;                                            // inflow velocity
float Re_foil = rho*u_foil*l_foil/mu;
float x= n/3;
float y= n/2;
float c= n/3;
float t= 0.3;
float pivot = 1/4.0;
// Square - BODYTYPE 3
float L_square = n/6;                                           // length-scale in grid units
float l_square = 0.1;
float u_square = 0.09916;                                            // inflow velocity
float Re_square = rho*u_square*l_square/mu;
// Spoon - BODYTYPE 4
float L_spoon = n/3.6;                                           // length-scale in grid units
float l_spoon = 0.05;
float u_spoon = 0.09916;                                            // inflow velocity
float Re_spoon = rho*u_spoon*l_spoon/mu;

// Setting up for moving objects *************************
float omega = PI/12.;                                          // angular frequency of object in rad/s
float omegamod = omega*dt;
float angmax = PI/12.;                                     // maximum 'flap' in positive direction
float angmin = -angmax;                                   // maximum 'flap' in negative direction
float angrange = PI/6.;//abs(angmin) + abs(angmax);


/*********************************************************
MAIN
*********************************************************/
void setup(){
  size(1600,800);                                          // display window size
  Window view = new Window(2*n,n);
  
  if (BODYTYPE == 1) {
    // Circle - BODYTYPE 1
    body = new CircleBody(n/3,n/2,L_circle,view);                 // define geom circle
    flow = new BDIM(2*n,n,0.,body,L_circle/Re_circle,true);                 // solve for flow using BDIM
    //body.rotate(Rotate_Degrees*PI/180);
  }
  else if (BODYTYPE == 2) {
    // Foil - BODYTYPE 2
    body = new NACA(x,y,c,t,pivot,view);                   //define geom foil
    //body.rotate(Rotate_Degrees*PI/180);
    //body.dphi=0.01;
    flow = new BDIM(2*n,n,dt,body,c/Re_foil,true);                 // solve for flow using BDIM
  }
  else if (BODYTYPE == 3) {
    // Square - BODYTYPE 3
    body = new SquareBody(n/3,n/2,L_square,Rotate_Degrees,view);
    flow = new BDIM(2*n,n,0.,body,L_square/Re_square,true);                 // solve for flow using BDIM
    //body.rotate(Rotate_Degrees*PI/180);
  }
  else if (BODYTYPE == 4) {
    // Spoon - BODYTYPE 4
    body = new SpoonBody(n/3,n/2,L_spoon,Rotate_Degrees,view);
    flow = new BDIM(2*n,n,0.,body,L_spoon/Re_spoon,true);                 // solve for flow using BDIM
    //body.rotate(Rotate_Degrees*PI/180);
  }
  
  plot = new ParticlePlot(view, 20000);
  plot.setColorMode(4);
  plot.setLegend("Vorticity",-0.5,0.5);
  
}

void draw(){
  tstep = tstep + 0.1;
  println(n);
  //body.follow(new PVector(x,y,Rotate_Degrees*PI/180+0.01),new PVector(0,0,0));
  body.follow(new PVector(x,y,sin(tstep*omegamod)*angrange),new PVector(0,0,0.001));
  body.follow();                                           // update the body
  flow.update(body); flow.update2();                       // 2-step fluid update
  body.display();                                          // display the body
  plot.update(flow);                                       // !NOTE!
  plot.display(flow.u.curl());
  body.display();
  //saveFrame("saved_testRe500000/frame-####.tif");
  timestep = timestep + 1;
  if(timestep >= endstep) {                                // finish after endstep cycles
    exit();
  }
}


/*********************************************************
SCRAP CODE
*********************************************************/
/*
//void mousePressed(){body.mousePressed();}    // user mouse...
//void mouseReleased(){body.mouseReleased();}  // interaction methods
//void mouseWheel(MouseEvent event){body.mouseWheel(event);}

Minor change added
*/
