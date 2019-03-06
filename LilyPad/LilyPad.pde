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
PrintWriter output_probes;
AncientSwimmer plesiosaur;
Field quadratic;
float time = 0;
float time_s = 200;

// Environment constants *********************************
int timestep = 1;                                          // Current time step
int endstep = 4001;                                        // Number of iterations before simulation exits
int n=(int)pow(2,7);                                       // number of grid points
int nlines = 50;                                           // Number of streamlines
float dt;
float h = 1.0/n;

// Bodytype variables ************************************
// General
int BODYTYPE = 2;
float mu_kin = 0.0000011375;
float Rotate_Degrees = 20;
float width_flume_m = 0.6;
// Circle - BODYTYPE 1
float u_circle_m_s = 0.34; 
float l_circle = 0.09;
float L_circle = n/(width_flume_m/l_circle);                                           // length-scale in grid units
float h_circle = l_circle/L_circle;
float Re_circle = u_circle_m_s/mu_kin;
float St_circle = 0.2;
// Foil - BODYTYPE 2
float l_foil =0.195;
float u_foil = 0.34;                                            // inflow velocity
float Re_foil = u_foil/mu_kin;
float x= n/3;
float y= n/2;
float c= n/(width_flume_m/l_foil);
float t= 0.3;
float pivot = 0.25;
float St_foil = 0.2;
// Square - BODYTYPE 3
float u_square_m_s = 0.34;
float l_square = 0.09;
float L_square = n/(width_flume_m/l_square);                                           // length-scale in grid units
float Re_square = u_square_m_s/mu_kin;
float St_square = 0.2;
// Spoon - BODYTYPE 4
float u_spoon_m_s = 0.34;
float l_spoon = 0.1;
float L_spoon = n/(width_flume_m/l_spoon);                                           // length-scale in grid units
float Re_spoon = u_spoon_m_s/mu_kin;
float St_spoon = 0.2;

// Setting up for moving objects *************************
//float omega = 15*PI/180.;
float omega = (St_foil*u_foil)/(2*PI*l_foil)*2*PI;                                          // angular frequency of object in rad/s
//float omega = (St_foil*1)/(2*PI*c);  
//float omegamod = omega*dt;
//float angmax = PI/12.;                                     // maximum 'flap' in positive direction
//float angmin = -angmax;                                   // maximum 'flap' in negative direction
float angrange = 30*PI/180.; //abs(angmin) + abs(angmax);
float tstep = 0;


  
/*********************************************************
MAIN
*********************************************************/
void setup(){
  if (BODYTYPE == 22) {
  BodyUnion body;
  }
  
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
  else if (BODYTYPE == 22) {
    // Foil - BODYTYPE 2 NEED TO COMMENT OUT ALL ABOVE IF STATEMENTS TO AVOID Body/BodyUnion CONFLICT. ALSO COMMENT OUT PRESSURE etc. MEASUREMENT CODE UNTIL FIXED!!!
    //body = new BodyUnion(new NACA(x,y+c/2,c,t,pivot,view), new NACA(x,y-c/2,c,t,pivot,view));                   //define geom foil
    flow = new BDIM(2*n,n,0.,body,c/Re_foil,true);                 // solve for flow using BDIM
    //bod
  }
  
  plot = new ParticlePlot(view, 20000);
  plot.setColorMode(4);
  plot.setLegend("Vorticity",-0.5,0.5);
  output_body = createWriter("body/test.csv");        // open output file
  output_probes = createWriter("probes/test.csv");        // open output file
  //output_body.println(""ts","drag","CD","lift","CL"");
  //output_probes.println(""measurement_pressure1","measurement_speed_x1","measurement_speed_y1","measurement_pressure2","measurement_speed_x2","measurement_speed_y2","measurement_pressure3","measurement_speed_x3","measurement_speed_y3"");
  

  
}

  //float[] position_x = new float[3];
  //float[] position_y = new float[3];
  
  //float[][] vel_x = new float[3][endstep];
  //float[][] vel_y = new float[3][endstep];
  
  //position_x[0] = (n/3 + 3*c/4)+c;
  //position_x[1] = (n/3 + 3*c/4)+2*c;
  //position_x[2] = (n/3 + 3*c/4)+3*c;
  
  //position_y[0] = n/2;
  //position_y[1] = n/2;
  //position_y[2] = n/2;


void draw(){
  dt = flow.dt;
  tstep = tstep + dt;
  float omegamod = omega*h/u_foil;
  body.follow(new PVector(x,y,sin(omegamod*tstep)*angrange),new PVector(0,0,omegamod*cos(omegamod*tstep)*angrange));
  //body.follow(new PVector(x,y,Rotate_Degrees*PI/180.),new PVector(0,0,0.0000001));
  //body.follow();                                           // update the body
  flow.update(body); flow.update2();                       // 2-step fluid update
  body.display();                                          // display the body
  plot.update(flow);                                       // !NOTE!
  plot.display(flow.u.curl());
  body.display();
  float deltatime = flow.dt*h/u_foil;
  println(deltatime);
  //lift and drag body
  if (BODYTYPE == 1) {
    PVector force = body.pressForce(flow.p);  // pressure force on both bodies
    float lift = force.y;
    float drag = force.x;
    //float deltatime = flow.dt;     // time coefficient circle
    float CD = 2.*force.x/L_circle;        // drag coefficient nondimentional circle
    float CL = 2.*force.y/L_circle;        // lift coefficient nondimentional circle
    output_body.println(""+deltatime+","+drag+","+CD+","+lift+","+CL+"");       // print to file
  }
  else if (BODYTYPE == 2) {
    PVector force = body.pressForce(flow.p);  // pressure force on both bodies
    float lift = force.y;
    float drag = force.x;
    //float deltatime = flow.dt;     // time coefficient floil
    float CD = 2.*force.x/c;        // drag coefficient nondimentional foil
    float CL = 2.*force.y/c;        // lift coefficient nondimentional foil
    output_body.println(""+deltatime+","+drag+","+CD+","+lift+","+CL+"");       // print to file
  }
  else if (BODYTYPE == 3) {
    PVector force = body.pressForce(flow.p);  // pressure force on both bodies
    float lift = force.y;
    float drag = force.x;
    //float deltatime = flow.dt;     // time coefficient floil
    float CD = 2.*force.x/L_square;        // drag coefficient nondimentional foil
    float CL = 2.*force.y/L_square;        // lift coefficient nondimentional foil
    output_body.println(""+deltatime+","+drag+","+CD+","+lift+","+CL+"");       // print to file
  }
  else if (BODYTYPE == 3) {
    PVector force = body.pressForce(flow.p);  // pressure force on both bodies
    float lift = force.y;
    float drag = force.x;
    //float deltatime = flow.dt;     // time coefficient floil
    float CD = 2.*force.x/L_spoon;        // drag coefficient nondimentional foil
    float CL = 2.*force.y/L_spoon;        // lift coefficient nondimentional foil
    output_body.println(""+deltatime+","+drag+","+CD+","+lift+","+CL+"");       // print to file
  }
  else if (BODYTYPE == 22) {
    //PVector force = bodyList.get(0).pressForce(flow.p);  // pressure force on both bodies
    //float lift = force.y;
    //float drag = force.x;
    //float deltatime = flow.dt;     // time coefficient floil
    //float CD = 2.*force.x/c;        // drag coefficient nondimentional foil
    //float CL = 2.*force.y/c;        // lift coefficient nondimentional foil
    //output_body.println(""+deltatime+","+drag+","+CD+","+lift+","+CL+"");       // print to file
  }
  Field Pressure_interp = flow.p;      //probe measurement
  VectorField velocity_interp = flow.u;
  // trailing edge of foil is at (n/3 + 3*c/4)
  //probe1
  float position_x1=  (n/3 + 3*c/4)+c;
  float position_y1=  n/2;
  //probe 2
  float position_x2=  (n/3 + 3*c/4)+2*c;
  float position_y2=  n/2;
  //probe 3
  float position_x3=  (n/3 + 3*c/4)+3*c;
  float position_y3=  n/2;
  //probe1 measurement
  float measurement_pressure1 = Pressure_interp.quadratic(position_x1, position_y1);
  float measurement_speed_x1 = velocity_interp.x.quadratic(position_x1, position_y1);
  float measurement_speed_y1 = velocity_interp.y.quadratic(position_x1, position_y1);
  //probe2 measurement
  float measurement_pressure2 = Pressure_interp.quadratic(position_x2, position_y2);
  float measurement_speed_x2 = velocity_interp.x.quadratic(position_x2, position_y2);
  float measurement_speed_y2 = velocity_interp.y.quadratic(position_x2, position_y2);
  //probe3 measurement
  float measurement_pressure3 = Pressure_interp.quadratic(position_x3, position_y3);
  float measurement_speed_x3 = velocity_interp.x.quadratic(position_x3, position_y3);
  float measurement_speed_y3 = velocity_interp.y.quadratic(position_x3, position_y3);
  output_probes.println(""+deltatime+","+measurement_pressure1+","+measurement_speed_x1+","+measurement_speed_y1+","+measurement_pressure2+","+measurement_speed_x2+","+measurement_speed_y2+","+measurement_pressure3+","+measurement_speed_x3+","+measurement_speed_y3+"");
  
  //float[] position_x = new float[3];
  //float[] position_y = new float[3];
  
  //float[][] vel_x = new float[3][endstep];
  //float[][] vel_y = new float[3][endstep];
  
  //position_x[0] = (n/3 + 3*c/4)+c;
  //position_x[1] = (n/3 + 3*c/4)+2*c;
  //position_x[2] = (n/3 + 3*c/4)+3*c;
  
  //position_y[0] = n/2;
  //position_y[1] = n/2;
  //position_y[2] = n/2;
  
  //vel_x[0][timestep] = velocity_interp.x.quadratic(position_x[0], position_y[0]);
  //vel_y[0][timestep] = velocity_interp.y.quadratic(position_x[0], position_y[0]);
  ////probe2 measurement
  //vel_x[1][timestep] = velocity_interp.x.quadratic(position_x[1], position_y[1]);
  //vel_y[1][timestep] = velocity_interp.y.quadratic(position_x[1], position_y[1]);
  ////probe3 measurement
  //vel_x[2][timestep] = velocity_interp.x.quadratic(position_x[2], position_y[2]);
  //vel_y[2][timestep] = velocity_interp.y.quadratic(position_x[2], position_y[2]);
  
  
  
  
  //saveFrame("saved2/frame-####.tif");
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
