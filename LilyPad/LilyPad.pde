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
Date last updated: jnbkndfnfn
*********************************************************/


/*********************************************************
DECLARATIONS 
*********************************************************/
BDIM flow;
//Body body;
BodyUnion body;
ParticlePlot plot;
Body react;
PrintWriter output_body;
PrintWriter output_press;
AncientSwimmer plesiosaur;
Field quadratic;
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
int BODYTYPE = 22;
float mu_kin = 0.0000011375;
float Rotate_Degrees = 45;
float width_flume_m = 0.18;
// Circle - BODYTYPE 1
float u_circle_m_s = 0.09916; 
float l_circle = 0.1;
float L_circle = n/(width_flume_m/l_circle);                                           // length-scale in grid units
float h_circle = l_circle/L_circle;
float Re_circle = u_circle_m_s/mu_kin;
float St_circle = 0.2;
// Foil - BODYTYPE 2
float l_foil = 0.2;
float u_foil = 0.09916;                                            // inflow velocity
float Re_foil = u_foil/mu_kin;
float x= n/3;
float y= n/2;
float c= n/3;
float t= 0.3;
float pivot =0;
// Square - BODYTYPE 3
float u_square_m_s = 0.09916;
float l_square = 0.1;
float L_square = n/(width_flume_m/l_square);                                           // length-scale in grid units
float Re_square = u_square_m_s/mu_kin;
// Spoon - BODYTYPE 4
float u_spoon_m_s = 0.09916;
float l_spoon = 0.05;
float L_spoon = n/(width_flume_m/l_spoon);                                           // length-scale in grid units
float Re_spoon = u_spoon_m_s/mu_kin;

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
  //  // Circle - BODYTYPE 1
  //  body = new CircleBody(n/3,n/2,L_circle,view);                 // define geom circle
  //  flow = new BDIM(2*n,n,0.,body,L_circle/Re_circle,true);                 // solve for flow using BDIM
  //  //float[] reaction = new float[3];
  //  //reaction = body.react(flow);
  //  //body.rotate(Rotate_Degrees*PI/180);
  }
  //else if (BODYTYPE == 2) {
  //  // Foil - BODYTYPE 2
  //  body = new NACA(x,y,c,t,pivot,view);                   //define geom foil
  //  flow = new BDIM(2*n,n,0.,body,c/Re_foil,true);                 // solve for flow using BDIM
  //  //body.rotate(Rotate_Degrees*PI/180); BROKEN SOLITION NEEDS CODING
  //}
  //else if (BODYTYPE == 3) {
  //  // Square - BODYTYPE 3
  //  body = new SquareBody(n/3,n/2,L_square,Rotate_Degrees,view);
  //  flow = new BDIM(2*n,n,0.,body,L_square/Re_square,true);                 // solve for flow using BDIM
  //  //body.rotate(Rotate_Degrees*PI/180);
  //}
  //else if (BODYTYPE == 4) {
  //  // Spoon - BODYTYPE 4
  //  body = new SpoonBody(n/3,n/2,L_spoon,Rotate_Degrees,view);
  //  flow = new BDIM(2*n,n,0.,body,L_spoon/Re_spoon,true);                 // solve for flow using BDIM
  //  //body.rotate(Rotate_Degrees*PI/180);
  //}
  else if (BODYTYPE == 22) {
    // Foil - BODYTYPE 2 NEED TO COMMENT OUT ALL ABOVE IF STATEMENTS TO AVOID Body/BodyUnion CONFLICT. ALSO COMMENT OUT PRESSURE etc. MEASUREMENT CODE UNTIL FIXED!!!
    body = new BodyUnion(new NACA(x,y+c/2,c,t,pivot,view), new NACA(x,y-c/2,c,t,pivot,view));                   //define geom foil
    flow = new BDIM(2*n,n,0.,body,c/Re_foil,true);                 // solve for flow using BDIM
    //body.rotate(Rotate_Degrees*PI/180); BROKEN SOLITION NEEDS CODING
  }
  
  plot = new ParticlePlot(view, 20000);
  plot.setColorMode(4);
  plot.setLegend("Vorticity",-0.5,0.5);
  output_body = createWriter("body/out3.csv");        // open output file
  output_press = createWriter("pressure/pressure.csv");        // open output file
  
}

void draw(){
  tstep = tstep + 0.1;
  println(n);
  body.follow(new PVector(x,y,sin(tstep*omegamod)*angrange),new PVector(0,0,0.001));
  body.follow();                                           // update the body
  flow.update(body); flow.update2();                       // 2-step fluid update
  body.display();                                          // display the body
  plot.update(flow);                                       // !NOTE!
  plot.display(flow.u.curl());
  body.display();
  ////lift and drag body
  //PVector force = body.pressForce(flow.p);  // pressure force on both bodies
  //float ts = St_circle*t/(2.*L_circle);     // time coefficient
  //float lift = force.y;
  //float drag = force.x;
  //float CD = 2.*force.x/L_circle;        // drag coefficient nondimentional
  //float CL = 2.*force.y/L_circle;        // lift coefficient nondimentional
  ////probe measurement
  //float position_x=  2*n/3;
  //float position_y=  n/2;
  //Field Pressure_interp = flow.p;
  //float measurement_pressure = Pressure_interp.quadratic(position_x, position_y);
  //VectorField velocity_interp = flow.u;
  //float measurement_speed_x = velocity_interp.x.quadratic(position_x, position_y);
  //float measurement_speed_y = velocity_interp.y.quadratic(position_x, position_y);
  //output_body.println(""+ts+","+drag+","+CD+","+lift+","+CL+","+measurement_pressure+","+measurement_speed_x+","+measurement_speed_y+"");       // print to file

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
//saveFrame("saved_testRe500000/frame-####.tif");
