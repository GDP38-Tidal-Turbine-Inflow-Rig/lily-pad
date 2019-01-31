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
Body react;
PrintWriter output_body;
PrintWriter output_press;
AncientSwimmer plesiosaur;
Field quadratic;

// Environment constants *********************************
int timestep = 1;                                          // Current time step
int endstep = 4001;                                        // Number of iterations before simulation exits
int n=(int)pow(2,7);                                       // number of grid points
int nlines = 50;                                           // Number of streamlines

// Bodytype variables ************************************
// General
int BODYTYPE = 1;
float mu_kin = 0.0000011375;
float rho = 1000;
float Rotate_Degrees = 45;
// Circle - BODYTYPE 1
float L_circle = n/6;                                           // length-scale in grid units
float l_circle = 0.1;
float u_circle = 0.09916;                                            // inflow velocity
float Re_circle = rho*u_circle*l_circle/mu_kin;
float St_circle = 0.2;
// Foil - BODYTYPE 2
float l_foil = 0.2;
float u_foil = 0.09916;                                            // inflow velocity
float Re_foil = rho*u_foil*l_foil/mu_kin;
float x= n/3;
float y= n/2;
float c= n/3;
float t= 0.3;
float pivot =0;
// Square - BODYTYPE 3
float L_square = n/6;                                           // length-scale in grid units
float l_square = 0.1;
float u_square = 0.09916;                                            // inflow velocity
float Re_square = rho*u_square*l_square/mu_kin;
// Spoon - BODYTYPE 4
float L_spoon = n/3.6;                                           // length-scale in grid units
float l_spoon = 0.05;
float u_spoon = 0.09916;                                            // inflow velocity
float Re_spoon = rho*u_spoon*l_spoon/mu_kin;


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
    //float[] reaction = new float[3];
    //reaction = body.react(flow);
  }
    //body.rotate(Rotate_Degrees*PI/180);
  else if (BODYTYPE == 2) {
    // Foil - BODYTYPE 2
    body = new NACA(x,y,c,t,pivot,view);                   //define geom foil
    flow = new BDIM(2*n,n,0.,body,c/Re_foil,true);                 // solve for flow using BDIM
    //body.rotate(Rotate_Degrees*PI/180); BROKEN SOLITION NEEDS CODING
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
  output_body = createWriter("body/out.csv");        // open output file
  output_press = createWriter("pressure/pressure.csv");        // open output file
  
}


void draw(){
  body.follow();                                           // update the body
  flow.update(body); flow.update2();                       // 2-step fluid update
  body.display();                                          // display the body
  plot.update(flow);                                       // !NOTE!
  plot.display(flow.u.curl());
  body.display();
  //flow.p.display(-1,1); // display pressure
  //lift and drag body
  PVector force = body.pressForce(flow.p);  // pressure force on both bodies
  float ts = St_circle*t/(2.*L_circle);     // time coefficient
  float lift = force.y;
  float drag = force.x;
  float CD = 2.*force.x/L_circle;        // drag coefficient nondimentional
  float CL = 2.*force.y/L_circle;        // lift coefficient nondimentional
  Field press = new Field(2*n,n);
  float Pressure_interp = press.quadratic(2*n/3,n/2);
  output_body.println(""+ts+","+drag+","+CD+","+lift+","+CL+","+Pressure_interp+"");       // print to file
  // pressure on a certain point of the field
  //Field press = new Field(2*n,n,1,0.25);
  //float Pressure_interp = press.quadratic(n/6,n/2);
  output_press.println(""+ts+""); 
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
*/
