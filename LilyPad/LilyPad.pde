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
int endstep = 24001;                                        // Number of iterations before simulation exits
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
float u_circle_m_s = 0.7; 
float l_circle = 0.09;
float L_circle = n/(width_flume_m/l_circle);                                           // length-scale in grid units
float h_circle = l_circle/L_circle;
float Re_circle = u_circle_m_s/mu_kin;
float St_circle = 0.2;
// Foil - BODYTYPE 2
float l_foil = 0.2;
float u_foil = 0.34;                                            // inflow velocity
float Re_foil = u_foil/mu_kin;
float x= n/3;
float y= n/2;
float c= n/(width_flume_m/l_foil);
float t= 0.3;
float pivot = 0.25;
float St_foil = 0.3;
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
float omega = 16.5*PI/180.;
//float omega = (St_foil*u_foil)/(2*PI*l_foil)*2*PI;                                          // angular frequency of object in rad/s
//float omega = St_foil*u_foil/(2*l_foil*sin(Rotate_Degrees*PI/180));  //new frequency Jamesk
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
    float spacing = 2*c/2;
    body = new BodyUnion(new NACA(x,y+2*spacing/2,c,t,pivot,view), new NACA(x,y-2*spacing/2,c,t,pivot,view));                   //define geom foil
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
  ////float omegamod = omega*2*h/u_foil; 
  //float freq = (l_foil*omega)/(c*u_foil)*2*PI;
  //body.follow(new PVector(x,y,sin(freq*tstep)*angrange),new PVector(0,0,freq*cos(freq*tstep)*angrange));
  body.follow(new PVector(x,y,Rotate_Degrees*PI/180.),new PVector(0,0,0.0000001));
  body.follow();                                           // update the body
  flow.update(body); flow.update2();                       // 2-step fluid update
  body.display();                                          // display the body
  plot.update(flow);                                       // !NOTE!
  plot.display(flow.u.curl());
  body.display();
  float deltatime = (flow.dt*l_foil)/(u_foil*c);
  println(timestep);
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
  ////probe1
  //float position_x1=  (n/3 + 3*c/4)+c;
  //float position_y1=  n/2;
  ////probe 2
  //float position_x2=  (n/3 + 3*c/4)+2*c;
  //float position_y2=  n/2;
  ////probe 3
  //float position_x3=  (n/3 + 3*c/4)+3*c;
  //float position_y3=  n/2;
  ////probe1 measurement
  //float measurement_pressure1 = Pressure_interp.quadratic(position_x1, position_y1);
  //float measurement_speed_x1 = velocity_interp.x.quadratic(position_x1, position_y1);
  //float measurement_speed_y1 = velocity_interp.y.quadratic(position_x1, position_y1);
  ////probe2 measurement
  //float measurement_pressure2 = Pressure_interp.quadratic(position_x2, position_y2);
  //float measurement_speed_x2 = velocity_interp.x.quadratic(position_x2, position_y2);
  //float measurement_speed_y2 = velocity_interp.y.quadratic(position_x2, position_y2);
  ////probe3 measurement
  //float measurement_pressure3 = Pressure_interp.quadratic(position_x3, position_y3);
  //float measurement_speed_x3 = velocity_interp.x.quadratic(position_x3, position_y3);
  //float measurement_speed_y3 = velocity_interp.y.quadratic(position_x3, position_y3);
  //output_probes.println(""+deltatime+","+measurement_pressure1+","+measurement_speed_x1+","+measurement_speed_y1+","+measurement_pressure2+","+measurement_speed_x2+","+measurement_speed_y2+","+measurement_pressure3+","+measurement_speed_x3+","+measurement_speed_y3+"");
  
//probe 1
float position_x1 = (n/3 + 3*c/4) + 2.08333333333333*c;
float position_y1 = (n/2) + 0.615384615384615*c;

//probe 2
float position_x2 = (n/3 + 3*c/4) + 2.08333333333333*c;
float position_y2 = (n/2) + 0.307692307692307*c;

//probe 3
float position_x3 = (n/3 + 3*c/4) + 2.08333333333333*c;
float position_y3 = (n/2) + 0*c;

//probe 4
float position_x4 = (n/3 + 3*c/4) + 2.08333333333333*c;
float position_y4 = (n/2) + -0.307692307692307*c;

//probe 5
float position_x5 = (n/3 + 3*c/4) + 2.08333333333333*c;
float position_y5 = (n/2) + -0.615384615384615*c;

//probe 6
float position_x6 = (n/3 + 3*c/4) + 2.39102564102564*c;
float position_y6 = (n/2) + 0.615384615384615*c;

//probe 7
float position_x7 = (n/3 + 3*c/4) + 2.39102564102564*c;
float position_y7 = (n/2) + 0.307692307692307*c;

//probe 8
float position_x8 = (n/3 + 3*c/4) + 2.39102564102564*c;
float position_y8 = (n/2) + 0*c;

//probe 9
float position_x9 = (n/3 + 3*c/4) + 2.39102564102564*c;
float position_y9 = (n/2) + -0.307692307692307*c;

//probe 10
float position_x10 = (n/3 + 3*c/4) + 2.39102564102564*c;
float position_y10 = (n/2) + -0.615384615384615*c;

//probe 11
float position_x11 = (n/3 + 3*c/4) + 3.00641025641025*c;
float position_y11 = (n/2) + 0.340335302930437*c;

//probe 12
float position_x12 = (n/3 + 3*c/4) + 3.00641025641025*c;
float position_y12 = (n/2) + 0*c;

//probe 13
float position_x13 = (n/3 + 3*c/4) + 3.00641025641025*c;
float position_y13 = (n/2) + -0.340335302930437*c;

//probe 14
float position_x14 = (n/3 + 3*c/4) + 3.62179487179487*c;
float position_y14 = (n/2) + 0.409998819095303*c;

//probe 15
float position_x15 = (n/3 + 3*c/4) + 3.62179487179487*c;
float position_y15 = (n/2) + 0*c;

//probe 16
float position_x16 = (n/3 + 3*c/4) + 3.62179487179487*c;
float position_y16 = (n/2) + -0.409998819095303*c;

//probe 17
float position_x17 = (n/3 + 3*c/4) + 4.23717948717948*c;
float position_y17 = (n/2) + 0.479662335260168*c;

//probe 18
float position_x18 = (n/3 + 3*c/4) + 4.23717948717948*c;
float position_y18 = (n/2) + 0*c;

//probe 19
float position_x19 = (n/3 + 3*c/4) + 4.23717948717948*c;
float position_y19 = (n/2) + -0.479662335260168*c;

//probe 20
float position_x20 = (n/3 + 3*c/4) + 4.8525641025641*c;
float position_y20 = (n/2) + 0*c;

//probe 21
float position_x21 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y21 = (n/2) + -1.28205128205128*c;

//probe 22
float position_x22 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y22 = (n/2) + -1.02564102564102*c;

//probe 23
float position_x23 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y23 = (n/2) + -0.769230769230769*c;

//probe 24
float position_x24 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y24 = (n/2) + -0.512820512820512*c;

//probe 25
float position_x25 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y25 = (n/2) + -0.256410256410256*c;

//probe 26
float position_x26 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y26 = (n/2) + 0*c;

//probe 27
float position_x27 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y27 = (n/2) + 0.256410256410256*c;

//probe 28
float position_x28 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y28 = (n/2) + 0.512820512820512*c;

//probe 29
float position_x29 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y29 = (n/2) + 0.769230769230769*c;

//probe 30
float position_x30 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y30 = (n/2) + 1.02564102564102*c;

//probe 31
float position_x31 = (n/3 + 3*c/4) + 1.26282051282051*c;
float position_y31 = (n/2) + 1.28205128205128*c;

//probe 32
float position_x32 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y32 = (n/2) + -1.28205128205128*c;

//probe 33
float position_x33 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y33 = (n/2) + -1.02564102564102*c;

//probe 34
float position_x34 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y34 = (n/2) + -0.769230769230769*c;

//probe 35
float position_x35 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y35 = (n/2) + -0.512820512820512*c;

//probe 36
float position_x36 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y36 = (n/2) + -0.256410256410256*c;

//probe 37
float position_x37 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y37 = (n/2) + 0*c;

//probe 38
float position_x38 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y38 = (n/2) + 0.256410256410256*c;

//probe 39
float position_x39 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y39 = (n/2) + 0.512820512820512*c;

//probe 40
float position_x40 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y40 = (n/2) + 0.769230769230769*c;

//probe 41
float position_x41 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y41 = (n/2) + 1.02564102564102*c;

//probe 42
float position_x42 = (n/3 + 3*c/4) + 1.66987179487179*c;
float position_y42 = (n/2) + 1.28205128205128*c;

//probe 43
float position_x43 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y43 = (n/2) + -1.28205128205128*c;

//probe 44
float position_x44 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y44 = (n/2) + -1.02564102564102*c;

//probe 45
float position_x45 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y45 = (n/2) + -0.769230769230769*c;

//probe 46
float position_x46 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y46 = (n/2) + -0.512820512820512*c;

//probe 47
float position_x47 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y47 = (n/2) + -0.256410256410256*c;

//probe 48
float position_x48 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y48 = (n/2) + 0*c;

//probe 49
float position_x49 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y49 = (n/2) + 0.256410256410256*c;

//probe 50
float position_x50 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y50 = (n/2) + 0.512820512820512*c;

//probe 51
float position_x51 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y51 = (n/2) + 0.769230769230769*c;

//probe 52
float position_x52 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y52 = (n/2) + 1.02564102564102*c;

//probe 53
float position_x53 = (n/3 + 3*c/4) + 2.07692307692307*c;
float position_y53 = (n/2) + 1.28205128205128*c;

//probe 54
float position_x54 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y54 = (n/2) + -1.28205128205128*c;

//probe 55
float position_x55 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y55 = (n/2) + -1.02564102564102*c;

//probe 56
float position_x56 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y56 = (n/2) + -0.769230769230769*c;

//probe 57
float position_x57 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y57 = (n/2) + -0.512820512820512*c;

//probe 58
float position_x58 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y58 = (n/2) + -0.256410256410256*c;

//probe 59
float position_x59 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y59 = (n/2) + 0*c;

//probe 60
float position_x60 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y60 = (n/2) + 0.256410256410256*c;

//probe 61
float position_x61 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y61 = (n/2) + 0.512820512820512*c;

//probe 62
float position_x62 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y62 = (n/2) + 0.769230769230769*c;

//probe 63
float position_x63 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y63 = (n/2) + 1.02564102564102*c;

//probe 64
float position_x64 = (n/3 + 3*c/4) + 2.48397435897435*c;
float position_y64 = (n/2) + 1.28205128205128*c;

//probe 65
float position_x65 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y65 = (n/2) + -1.28205128205128*c;

//probe 66
float position_x66 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y66 = (n/2) + -1.02564102564102*c;

//probe 67
float position_x67 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y67 = (n/2) + -0.769230769230769*c;

//probe 68
float position_x68 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y68 = (n/2) + -0.512820512820512*c;

//probe 69
float position_x69 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y69 = (n/2) + -0.256410256410256*c;

//probe 70
float position_x70 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y70 = (n/2) + 0*c;

//probe 71
float position_x71 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y71 = (n/2) + 0.256410256410256*c;

//probe 72
float position_x72 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y72 = (n/2) + 0.512820512820512*c;

//probe 73
float position_x73 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y73 = (n/2) + 0.769230769230769*c;

//probe 74
float position_x74 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y74 = (n/2) + 1.02564102564102*c;

//probe 75
float position_x75 = (n/3 + 3*c/4) + 2.89102564102564*c;
float position_y75 = (n/2) + 1.28205128205128*c;

//probe 76
float position_x76 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y76 = (n/2) + -1.28205128205128*c;

//probe 77
float position_x77 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y77 = (n/2) + -1.02564102564102*c;

//probe 78
float position_x78 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y78 = (n/2) + -0.769230769230769*c;

//probe 79
float position_x79 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y79 = (n/2) + -0.512820512820512*c;

//probe 80
float position_x80 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y80 = (n/2) + -0.256410256410256*c;

//probe 81
float position_x81 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y81 = (n/2) + 0*c;

//probe 82
float position_x82 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y82 = (n/2) + 0.256410256410256*c;

//probe 83
float position_x83 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y83 = (n/2) + 0.512820512820512*c;

//probe 84
float position_x84 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y84 = (n/2) + 0.769230769230769*c;

//probe 85
float position_x85 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y85 = (n/2) + 1.02564102564102*c;

//probe 86
float position_x86 = (n/3 + 3*c/4) + 3.29807692307692*c;
float position_y86 = (n/2) + 1.28205128205128*c;

//probe 87
float position_x87 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y87 = (n/2) + -1.28205128205128*c;

//probe 88
float position_x88 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y88 = (n/2) + -1.02564102564102*c;

//probe 89
float position_x89 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y89 = (n/2) + -0.769230769230769*c;

//probe 90
float position_x90 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y90 = (n/2) + -0.512820512820512*c;

//probe 91
float position_x91 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y91 = (n/2) + -0.256410256410256*c;

//probe 92
float position_x92 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y92 = (n/2) + 0*c;

//probe 93
float position_x93 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y93 = (n/2) + 0.256410256410256*c;

//probe 94
float position_x94 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y94 = (n/2) + 0.512820512820512*c;

//probe 95
float position_x95 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y95 = (n/2) + 0.769230769230769*c;

//probe 96
float position_x96 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y96 = (n/2) + 1.02564102564102*c;

//probe 97
float position_x97 = (n/3 + 3*c/4) + 3.7051282051282*c;
float position_y97 = (n/2) + 1.28205128205128*c;

//probe 98
float position_x98 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y98 = (n/2) + -1.28205128205128*c;

//probe 99
float position_x99 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y99 = (n/2) + -1.02564102564102*c;

//probe 100
float position_x100 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y100 = (n/2) + -0.769230769230769*c;

//probe 101
float position_x101 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y101 = (n/2) + -0.512820512820512*c;

//probe 102
float position_x102 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y102 = (n/2) + -0.256410256410256*c;

//probe 103
float position_x103 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y103 = (n/2) + 0*c;

//probe 104
float position_x104 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y104 = (n/2) + 0.256410256410256*c;

//probe 105
float position_x105 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y105 = (n/2) + 0.512820512820512*c;

//probe 106
float position_x106 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y106 = (n/2) + 0.769230769230769*c;

//probe 107
float position_x107 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y107 = (n/2) + 1.02564102564102*c;

//probe 108
float position_x108 = (n/3 + 3*c/4) + 4.11217948717948*c;
float position_y108 = (n/2) + 1.28205128205128*c;

//probe 109
float position_x109 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y109 = (n/2) + -1.28205128205128*c;

//probe 110
float position_x110 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y110 = (n/2) + -1.02564102564102*c;

//probe 111
float position_x111 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y111 = (n/2) + -0.769230769230769*c;

//probe 112
float position_x112 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y112 = (n/2) + -0.512820512820512*c;

//probe 113
float position_x113 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y113 = (n/2) + -0.256410256410256*c;

//probe 114
float position_x114 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y114 = (n/2) + 0*c;

//probe 115
float position_x115 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y115 = (n/2) + 0.256410256410256*c;

//probe 116
float position_x116 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y116 = (n/2) + 0.512820512820512*c;

//probe 117
float position_x117 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y117 = (n/2) + 0.769230769230769*c;

//probe 118
float position_x118 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y118 = (n/2) + 1.02564102564102*c;

//probe 119
float position_x119 = (n/3 + 3*c/4) + 4.51923076923076*c;
float position_y119 = (n/2) + 1.28205128205128*c;

//probe 120
float position_x120 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y120 = (n/2) + -1.28205128205128*c;

//probe 121
float position_x121 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y121 = (n/2) + -1.02564102564102*c;

//probe 122
float position_x122 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y122 = (n/2) + -0.769230769230769*c;

//probe 123
float position_x123 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y123 = (n/2) + -0.512820512820512*c;

//probe 124
float position_x124 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y124 = (n/2) + -0.256410256410256*c;

//probe 125
float position_x125 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y125 = (n/2) + 0*c;

//probe 126
float position_x126 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y126 = (n/2) + 0.256410256410256*c;

//probe 127
float position_x127 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y127 = (n/2) + 0.512820512820512*c;

//probe 128
float position_x128 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y128 = (n/2) + 0.769230769230769*c;

//probe 129
float position_x129 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y129 = (n/2) + 1.02564102564102*c;

//probe 130
float position_x130 = (n/3 + 3*c/4) + 4.92628205128205*c;
float position_y130 = (n/2) + 1.28205128205128*c;

//probe 131
float position_x131 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y131 = (n/2) + -1.28205128205128*c;

//probe 132
float position_x132 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y132 = (n/2) + -1.02564102564102*c;

//probe 133
float position_x133 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y133 = (n/2) + -0.769230769230769*c;

//probe 134
float position_x134 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y134 = (n/2) + -0.512820512820512*c;

//probe 135
float position_x135 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y135 = (n/2) + -0.256410256410256*c;

//probe 136
float position_x136 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y136 = (n/2) + 0*c;

//probe 137
float position_x137 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y137 = (n/2) + 0.256410256410256*c;

//probe 138
float position_x138 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y138 = (n/2) + 0.512820512820512*c;

//probe 139
float position_x139 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y139 = (n/2) + 0.769230769230769*c;

//probe 140
float position_x140 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y140 = (n/2) + 1.02564102564102*c;

//probe 141
float position_x141 = (n/3 + 3*c/4) + 5.33333333333333*c;
float position_y141 = (n/2) + 1.28205128205128*c;


//probe 1 measurement
float measurement_pressure1 = Pressure_interp.quadratic(position_x1, position_y1);
float measurement_speed_x1 = velocity_interp.x.quadratic(position_x1, position_y1);
float measurement_speed_y1 = velocity_interp.y.quadratic(position_x1, position_y1);
//probe 2 measurement
float measurement_pressure2 = Pressure_interp.quadratic(position_x2, position_y2);
float measurement_speed_x2 = velocity_interp.x.quadratic(position_x2, position_y2);
float measurement_speed_y2 = velocity_interp.y.quadratic(position_x2, position_y2);
//probe 3 measurement
float measurement_pressure3 = Pressure_interp.quadratic(position_x3, position_y3);
float measurement_speed_x3 = velocity_interp.x.quadratic(position_x3, position_y3);
float measurement_speed_y3 = velocity_interp.y.quadratic(position_x3, position_y3);
//probe 4 measurement
float measurement_pressure4 = Pressure_interp.quadratic(position_x4, position_y4);
float measurement_speed_x4 = velocity_interp.x.quadratic(position_x4, position_y4);
float measurement_speed_y4 = velocity_interp.y.quadratic(position_x4, position_y4);
//probe 5 measurement
float measurement_pressure5 = Pressure_interp.quadratic(position_x5, position_y5);
float measurement_speed_x5 = velocity_interp.x.quadratic(position_x5, position_y5);
float measurement_speed_y5 = velocity_interp.y.quadratic(position_x5, position_y5);
//probe 6 measurement
float measurement_pressure6 = Pressure_interp.quadratic(position_x6, position_y6);
float measurement_speed_x6 = velocity_interp.x.quadratic(position_x6, position_y6);
float measurement_speed_y6 = velocity_interp.y.quadratic(position_x6, position_y6);
//probe 7 measurement
float measurement_pressure7 = Pressure_interp.quadratic(position_x7, position_y7);
float measurement_speed_x7 = velocity_interp.x.quadratic(position_x7, position_y7);
float measurement_speed_y7 = velocity_interp.y.quadratic(position_x7, position_y7);
//probe 8 measurement
float measurement_pressure8 = Pressure_interp.quadratic(position_x8, position_y8);
float measurement_speed_x8 = velocity_interp.x.quadratic(position_x8, position_y8);
float measurement_speed_y8 = velocity_interp.y.quadratic(position_x8, position_y8);
//probe 9 measurement
float measurement_pressure9 = Pressure_interp.quadratic(position_x9, position_y9);
float measurement_speed_x9 = velocity_interp.x.quadratic(position_x9, position_y9);
float measurement_speed_y9 = velocity_interp.y.quadratic(position_x9, position_y9);
//probe 10 measurement
float measurement_pressure10 = Pressure_interp.quadratic(position_x10, position_y10);
float measurement_speed_x10 = velocity_interp.x.quadratic(position_x10, position_y10);
float measurement_speed_y10 = velocity_interp.y.quadratic(position_x10, position_y10);
//probe 11 measurement
float measurement_pressure11 = Pressure_interp.quadratic(position_x11, position_y11);
float measurement_speed_x11 = velocity_interp.x.quadratic(position_x11, position_y11);
float measurement_speed_y11 = velocity_interp.y.quadratic(position_x11, position_y11);
//probe 12 measurement
float measurement_pressure12 = Pressure_interp.quadratic(position_x12, position_y12);
float measurement_speed_x12 = velocity_interp.x.quadratic(position_x12, position_y12);
float measurement_speed_y12 = velocity_interp.y.quadratic(position_x12, position_y12);
//probe 13 measurement
float measurement_pressure13 = Pressure_interp.quadratic(position_x13, position_y13);
float measurement_speed_x13 = velocity_interp.x.quadratic(position_x13, position_y13);
float measurement_speed_y13 = velocity_interp.y.quadratic(position_x13, position_y13);
//probe 14 measurement
float measurement_pressure14 = Pressure_interp.quadratic(position_x14, position_y14);
float measurement_speed_x14 = velocity_interp.x.quadratic(position_x14, position_y14);
float measurement_speed_y14 = velocity_interp.y.quadratic(position_x14, position_y14);
//probe 15 measurement
float measurement_pressure15 = Pressure_interp.quadratic(position_x15, position_y15);
float measurement_speed_x15 = velocity_interp.x.quadratic(position_x15, position_y15);
float measurement_speed_y15 = velocity_interp.y.quadratic(position_x15, position_y15);
//probe 16 measurement
float measurement_pressure16 = Pressure_interp.quadratic(position_x16, position_y16);
float measurement_speed_x16 = velocity_interp.x.quadratic(position_x16, position_y16);
float measurement_speed_y16 = velocity_interp.y.quadratic(position_x16, position_y16);
//probe 17 measurement
float measurement_pressure17 = Pressure_interp.quadratic(position_x17, position_y17);
float measurement_speed_x17 = velocity_interp.x.quadratic(position_x17, position_y17);
float measurement_speed_y17 = velocity_interp.y.quadratic(position_x17, position_y17);
//probe 18 measurement
float measurement_pressure18 = Pressure_interp.quadratic(position_x18, position_y18);
float measurement_speed_x18 = velocity_interp.x.quadratic(position_x18, position_y18);
float measurement_speed_y18 = velocity_interp.y.quadratic(position_x18, position_y18);
//probe 19 measurement
float measurement_pressure19 = Pressure_interp.quadratic(position_x19, position_y19);
float measurement_speed_x19 = velocity_interp.x.quadratic(position_x19, position_y19);
float measurement_speed_y19 = velocity_interp.y.quadratic(position_x19, position_y19);
//probe 20 measurement
float measurement_pressure20 = Pressure_interp.quadratic(position_x20, position_y20);
float measurement_speed_x20 = velocity_interp.x.quadratic(position_x20, position_y20);
float measurement_speed_y20 = velocity_interp.y.quadratic(position_x20, position_y20);
//probe 21 measurement
float measurement_pressure21 = Pressure_interp.quadratic(position_x21, position_y21);
float measurement_speed_x21 = velocity_interp.x.quadratic(position_x21, position_y21);
float measurement_speed_y21 = velocity_interp.y.quadratic(position_x21, position_y21);
//probe 22 measurement
float measurement_pressure22 = Pressure_interp.quadratic(position_x22, position_y22);
float measurement_speed_x22 = velocity_interp.x.quadratic(position_x22, position_y22);
float measurement_speed_y22 = velocity_interp.y.quadratic(position_x22, position_y22);
//probe 23 measurement
float measurement_pressure23 = Pressure_interp.quadratic(position_x23, position_y23);
float measurement_speed_x23 = velocity_interp.x.quadratic(position_x23, position_y23);
float measurement_speed_y23 = velocity_interp.y.quadratic(position_x23, position_y23);
//probe 24 measurement
float measurement_pressure24 = Pressure_interp.quadratic(position_x24, position_y24);
float measurement_speed_x24 = velocity_interp.x.quadratic(position_x24, position_y24);
float measurement_speed_y24 = velocity_interp.y.quadratic(position_x24, position_y24);
//probe 25 measurement
float measurement_pressure25 = Pressure_interp.quadratic(position_x25, position_y25);
float measurement_speed_x25 = velocity_interp.x.quadratic(position_x25, position_y25);
float measurement_speed_y25 = velocity_interp.y.quadratic(position_x25, position_y25);
//probe 26 measurement
float measurement_pressure26 = Pressure_interp.quadratic(position_x26, position_y26);
float measurement_speed_x26 = velocity_interp.x.quadratic(position_x26, position_y26);
float measurement_speed_y26 = velocity_interp.y.quadratic(position_x26, position_y26);
//probe 27 measurement
float measurement_pressure27 = Pressure_interp.quadratic(position_x27, position_y27);
float measurement_speed_x27 = velocity_interp.x.quadratic(position_x27, position_y27);
float measurement_speed_y27 = velocity_interp.y.quadratic(position_x27, position_y27);
//probe 28 measurement
float measurement_pressure28 = Pressure_interp.quadratic(position_x28, position_y28);
float measurement_speed_x28 = velocity_interp.x.quadratic(position_x28, position_y28);
float measurement_speed_y28 = velocity_interp.y.quadratic(position_x28, position_y28);
//probe 29 measurement
float measurement_pressure29 = Pressure_interp.quadratic(position_x29, position_y29);
float measurement_speed_x29 = velocity_interp.x.quadratic(position_x29, position_y29);
float measurement_speed_y29 = velocity_interp.y.quadratic(position_x29, position_y29);
//probe 30 measurement
float measurement_pressure30 = Pressure_interp.quadratic(position_x30, position_y30);
float measurement_speed_x30 = velocity_interp.x.quadratic(position_x30, position_y30);
float measurement_speed_y30 = velocity_interp.y.quadratic(position_x30, position_y30);
//probe 31 measurement
float measurement_pressure31 = Pressure_interp.quadratic(position_x31, position_y31);
float measurement_speed_x31 = velocity_interp.x.quadratic(position_x31, position_y31);
float measurement_speed_y31 = velocity_interp.y.quadratic(position_x31, position_y31);
//probe 32 measurement
float measurement_pressure32 = Pressure_interp.quadratic(position_x32, position_y32);
float measurement_speed_x32 = velocity_interp.x.quadratic(position_x32, position_y32);
float measurement_speed_y32 = velocity_interp.y.quadratic(position_x32, position_y32);
//probe 33 measurement
float measurement_pressure33 = Pressure_interp.quadratic(position_x33, position_y33);
float measurement_speed_x33 = velocity_interp.x.quadratic(position_x33, position_y33);
float measurement_speed_y33 = velocity_interp.y.quadratic(position_x33, position_y33);
//probe 34 measurement
float measurement_pressure34 = Pressure_interp.quadratic(position_x34, position_y34);
float measurement_speed_x34 = velocity_interp.x.quadratic(position_x34, position_y34);
float measurement_speed_y34 = velocity_interp.y.quadratic(position_x34, position_y34);
//probe 35 measurement
float measurement_pressure35 = Pressure_interp.quadratic(position_x35, position_y35);
float measurement_speed_x35 = velocity_interp.x.quadratic(position_x35, position_y35);
float measurement_speed_y35 = velocity_interp.y.quadratic(position_x35, position_y35);
//probe 36 measurement
float measurement_pressure36 = Pressure_interp.quadratic(position_x36, position_y36);
float measurement_speed_x36 = velocity_interp.x.quadratic(position_x36, position_y36);
float measurement_speed_y36 = velocity_interp.y.quadratic(position_x36, position_y36);
//probe 37 measurement
float measurement_pressure37 = Pressure_interp.quadratic(position_x37, position_y37);
float measurement_speed_x37 = velocity_interp.x.quadratic(position_x37, position_y37);
float measurement_speed_y37 = velocity_interp.y.quadratic(position_x37, position_y37);
//probe 38 measurement
float measurement_pressure38 = Pressure_interp.quadratic(position_x38, position_y38);
float measurement_speed_x38 = velocity_interp.x.quadratic(position_x38, position_y38);
float measurement_speed_y38 = velocity_interp.y.quadratic(position_x38, position_y38);
//probe 39 measurement
float measurement_pressure39 = Pressure_interp.quadratic(position_x39, position_y39);
float measurement_speed_x39 = velocity_interp.x.quadratic(position_x39, position_y39);
float measurement_speed_y39 = velocity_interp.y.quadratic(position_x39, position_y39);
//probe 40 measurement
float measurement_pressure40 = Pressure_interp.quadratic(position_x40, position_y40);
float measurement_speed_x40 = velocity_interp.x.quadratic(position_x40, position_y40);
float measurement_speed_y40 = velocity_interp.y.quadratic(position_x40, position_y40);
//probe 41 measurement
float measurement_pressure41 = Pressure_interp.quadratic(position_x41, position_y41);
float measurement_speed_x41 = velocity_interp.x.quadratic(position_x41, position_y41);
float measurement_speed_y41 = velocity_interp.y.quadratic(position_x41, position_y41);
//probe 42 measurement
float measurement_pressure42 = Pressure_interp.quadratic(position_x42, position_y42);
float measurement_speed_x42 = velocity_interp.x.quadratic(position_x42, position_y42);
float measurement_speed_y42 = velocity_interp.y.quadratic(position_x42, position_y42);
//probe 43 measurement
float measurement_pressure43 = Pressure_interp.quadratic(position_x43, position_y43);
float measurement_speed_x43 = velocity_interp.x.quadratic(position_x43, position_y43);
float measurement_speed_y43 = velocity_interp.y.quadratic(position_x43, position_y43);
//probe 44 measurement
float measurement_pressure44 = Pressure_interp.quadratic(position_x44, position_y44);
float measurement_speed_x44 = velocity_interp.x.quadratic(position_x44, position_y44);
float measurement_speed_y44 = velocity_interp.y.quadratic(position_x44, position_y44);
//probe 45 measurement
float measurement_pressure45 = Pressure_interp.quadratic(position_x45, position_y45);
float measurement_speed_x45 = velocity_interp.x.quadratic(position_x45, position_y45);
float measurement_speed_y45 = velocity_interp.y.quadratic(position_x45, position_y45);
//probe 46 measurement
float measurement_pressure46 = Pressure_interp.quadratic(position_x46, position_y46);
float measurement_speed_x46 = velocity_interp.x.quadratic(position_x46, position_y46);
float measurement_speed_y46 = velocity_interp.y.quadratic(position_x46, position_y46);
//probe 47 measurement
float measurement_pressure47 = Pressure_interp.quadratic(position_x47, position_y47);
float measurement_speed_x47 = velocity_interp.x.quadratic(position_x47, position_y47);
float measurement_speed_y47 = velocity_interp.y.quadratic(position_x47, position_y47);
//probe 48 measurement
float measurement_pressure48 = Pressure_interp.quadratic(position_x48, position_y48);
float measurement_speed_x48 = velocity_interp.x.quadratic(position_x48, position_y48);
float measurement_speed_y48 = velocity_interp.y.quadratic(position_x48, position_y48);
//probe 49 measurement
float measurement_pressure49 = Pressure_interp.quadratic(position_x49, position_y49);
float measurement_speed_x49 = velocity_interp.x.quadratic(position_x49, position_y49);
float measurement_speed_y49 = velocity_interp.y.quadratic(position_x49, position_y49);
//probe 50 measurement
float measurement_pressure50 = Pressure_interp.quadratic(position_x50, position_y50);
float measurement_speed_x50 = velocity_interp.x.quadratic(position_x50, position_y50);
float measurement_speed_y50 = velocity_interp.y.quadratic(position_x50, position_y50);
//probe 51 measurement
float measurement_pressure51 = Pressure_interp.quadratic(position_x51, position_y51);
float measurement_speed_x51 = velocity_interp.x.quadratic(position_x51, position_y51);
float measurement_speed_y51 = velocity_interp.y.quadratic(position_x51, position_y51);
//probe 52 measurement
float measurement_pressure52 = Pressure_interp.quadratic(position_x52, position_y52);
float measurement_speed_x52 = velocity_interp.x.quadratic(position_x52, position_y52);
float measurement_speed_y52 = velocity_interp.y.quadratic(position_x52, position_y52);
//probe 53 measurement
float measurement_pressure53 = Pressure_interp.quadratic(position_x53, position_y53);
float measurement_speed_x53 = velocity_interp.x.quadratic(position_x53, position_y53);
float measurement_speed_y53 = velocity_interp.y.quadratic(position_x53, position_y53);
//probe 54 measurement
float measurement_pressure54 = Pressure_interp.quadratic(position_x54, position_y54);
float measurement_speed_x54 = velocity_interp.x.quadratic(position_x54, position_y54);
float measurement_speed_y54 = velocity_interp.y.quadratic(position_x54, position_y54);
//probe 55 measurement
float measurement_pressure55 = Pressure_interp.quadratic(position_x55, position_y55);
float measurement_speed_x55 = velocity_interp.x.quadratic(position_x55, position_y55);
float measurement_speed_y55 = velocity_interp.y.quadratic(position_x55, position_y55);
//probe 56 measurement
float measurement_pressure56 = Pressure_interp.quadratic(position_x56, position_y56);
float measurement_speed_x56 = velocity_interp.x.quadratic(position_x56, position_y56);
float measurement_speed_y56 = velocity_interp.y.quadratic(position_x56, position_y56);
//probe 57 measurement
float measurement_pressure57 = Pressure_interp.quadratic(position_x57, position_y57);
float measurement_speed_x57 = velocity_interp.x.quadratic(position_x57, position_y57);
float measurement_speed_y57 = velocity_interp.y.quadratic(position_x57, position_y57);
//probe 58 measurement
float measurement_pressure58 = Pressure_interp.quadratic(position_x58, position_y58);
float measurement_speed_x58 = velocity_interp.x.quadratic(position_x58, position_y58);
float measurement_speed_y58 = velocity_interp.y.quadratic(position_x58, position_y58);
//probe 59 measurement
float measurement_pressure59 = Pressure_interp.quadratic(position_x59, position_y59);
float measurement_speed_x59 = velocity_interp.x.quadratic(position_x59, position_y59);
float measurement_speed_y59 = velocity_interp.y.quadratic(position_x59, position_y59);
//probe 60 measurement
float measurement_pressure60 = Pressure_interp.quadratic(position_x60, position_y60);
float measurement_speed_x60 = velocity_interp.x.quadratic(position_x60, position_y60);
float measurement_speed_y60 = velocity_interp.y.quadratic(position_x60, position_y60);
//probe 61 measurement
float measurement_pressure61 = Pressure_interp.quadratic(position_x61, position_y61);
float measurement_speed_x61 = velocity_interp.x.quadratic(position_x61, position_y61);
float measurement_speed_y61 = velocity_interp.y.quadratic(position_x61, position_y61);
//probe 62 measurement
float measurement_pressure62 = Pressure_interp.quadratic(position_x62, position_y62);
float measurement_speed_x62 = velocity_interp.x.quadratic(position_x62, position_y62);
float measurement_speed_y62 = velocity_interp.y.quadratic(position_x62, position_y62);
//probe 63 measurement
float measurement_pressure63 = Pressure_interp.quadratic(position_x63, position_y63);
float measurement_speed_x63 = velocity_interp.x.quadratic(position_x63, position_y63);
float measurement_speed_y63 = velocity_interp.y.quadratic(position_x63, position_y63);
//probe 64 measurement
float measurement_pressure64 = Pressure_interp.quadratic(position_x64, position_y64);
float measurement_speed_x64 = velocity_interp.x.quadratic(position_x64, position_y64);
float measurement_speed_y64 = velocity_interp.y.quadratic(position_x64, position_y64);
//probe 65 measurement
float measurement_pressure65 = Pressure_interp.quadratic(position_x65, position_y65);
float measurement_speed_x65 = velocity_interp.x.quadratic(position_x65, position_y65);
float measurement_speed_y65 = velocity_interp.y.quadratic(position_x65, position_y65);
//probe 66 measurement
float measurement_pressure66 = Pressure_interp.quadratic(position_x66, position_y66);
float measurement_speed_x66 = velocity_interp.x.quadratic(position_x66, position_y66);
float measurement_speed_y66 = velocity_interp.y.quadratic(position_x66, position_y66);
//probe 67 measurement
float measurement_pressure67 = Pressure_interp.quadratic(position_x67, position_y67);
float measurement_speed_x67 = velocity_interp.x.quadratic(position_x67, position_y67);
float measurement_speed_y67 = velocity_interp.y.quadratic(position_x67, position_y67);
//probe 68 measurement
float measurement_pressure68 = Pressure_interp.quadratic(position_x68, position_y68);
float measurement_speed_x68 = velocity_interp.x.quadratic(position_x68, position_y68);
float measurement_speed_y68 = velocity_interp.y.quadratic(position_x68, position_y68);
//probe 69 measurement
float measurement_pressure69 = Pressure_interp.quadratic(position_x69, position_y69);
float measurement_speed_x69 = velocity_interp.x.quadratic(position_x69, position_y69);
float measurement_speed_y69 = velocity_interp.y.quadratic(position_x69, position_y69);
//probe 70 measurement
float measurement_pressure70 = Pressure_interp.quadratic(position_x70, position_y70);
float measurement_speed_x70 = velocity_interp.x.quadratic(position_x70, position_y70);
float measurement_speed_y70 = velocity_interp.y.quadratic(position_x70, position_y70);
//probe 71 measurement
float measurement_pressure71 = Pressure_interp.quadratic(position_x71, position_y71);
float measurement_speed_x71 = velocity_interp.x.quadratic(position_x71, position_y71);
float measurement_speed_y71 = velocity_interp.y.quadratic(position_x71, position_y71);
//probe 72 measurement
float measurement_pressure72 = Pressure_interp.quadratic(position_x72, position_y72);
float measurement_speed_x72 = velocity_interp.x.quadratic(position_x72, position_y72);
float measurement_speed_y72 = velocity_interp.y.quadratic(position_x72, position_y72);
//probe 73 measurement
float measurement_pressure73 = Pressure_interp.quadratic(position_x73, position_y73);
float measurement_speed_x73 = velocity_interp.x.quadratic(position_x73, position_y73);
float measurement_speed_y73 = velocity_interp.y.quadratic(position_x73, position_y73);
//probe 74 measurement
float measurement_pressure74 = Pressure_interp.quadratic(position_x74, position_y74);
float measurement_speed_x74 = velocity_interp.x.quadratic(position_x74, position_y74);
float measurement_speed_y74 = velocity_interp.y.quadratic(position_x74, position_y74);
//probe 75 measurement
float measurement_pressure75 = Pressure_interp.quadratic(position_x75, position_y75);
float measurement_speed_x75 = velocity_interp.x.quadratic(position_x75, position_y75);
float measurement_speed_y75 = velocity_interp.y.quadratic(position_x75, position_y75);
//probe 76 measurement
float measurement_pressure76 = Pressure_interp.quadratic(position_x76, position_y76);
float measurement_speed_x76 = velocity_interp.x.quadratic(position_x76, position_y76);
float measurement_speed_y76 = velocity_interp.y.quadratic(position_x76, position_y76);
//probe 77 measurement
float measurement_pressure77 = Pressure_interp.quadratic(position_x77, position_y77);
float measurement_speed_x77 = velocity_interp.x.quadratic(position_x77, position_y77);
float measurement_speed_y77 = velocity_interp.y.quadratic(position_x77, position_y77);
//probe 78 measurement
float measurement_pressure78 = Pressure_interp.quadratic(position_x78, position_y78);
float measurement_speed_x78 = velocity_interp.x.quadratic(position_x78, position_y78);
float measurement_speed_y78 = velocity_interp.y.quadratic(position_x78, position_y78);
//probe 79 measurement
float measurement_pressure79 = Pressure_interp.quadratic(position_x79, position_y79);
float measurement_speed_x79 = velocity_interp.x.quadratic(position_x79, position_y79);
float measurement_speed_y79 = velocity_interp.y.quadratic(position_x79, position_y79);
//probe 80 measurement
float measurement_pressure80 = Pressure_interp.quadratic(position_x80, position_y80);
float measurement_speed_x80 = velocity_interp.x.quadratic(position_x80, position_y80);
float measurement_speed_y80 = velocity_interp.y.quadratic(position_x80, position_y80);
//probe 81 measurement
float measurement_pressure81 = Pressure_interp.quadratic(position_x81, position_y81);
float measurement_speed_x81 = velocity_interp.x.quadratic(position_x81, position_y81);
float measurement_speed_y81 = velocity_interp.y.quadratic(position_x81, position_y81);
//probe 82 measurement
float measurement_pressure82 = Pressure_interp.quadratic(position_x82, position_y82);
float measurement_speed_x82 = velocity_interp.x.quadratic(position_x82, position_y82);
float measurement_speed_y82 = velocity_interp.y.quadratic(position_x82, position_y82);
//probe 83 measurement
float measurement_pressure83 = Pressure_interp.quadratic(position_x83, position_y83);
float measurement_speed_x83 = velocity_interp.x.quadratic(position_x83, position_y83);
float measurement_speed_y83 = velocity_interp.y.quadratic(position_x83, position_y83);
//probe 84 measurement
float measurement_pressure84 = Pressure_interp.quadratic(position_x84, position_y84);
float measurement_speed_x84 = velocity_interp.x.quadratic(position_x84, position_y84);
float measurement_speed_y84 = velocity_interp.y.quadratic(position_x84, position_y84);
//probe 85 measurement
float measurement_pressure85 = Pressure_interp.quadratic(position_x85, position_y85);
float measurement_speed_x85 = velocity_interp.x.quadratic(position_x85, position_y85);
float measurement_speed_y85 = velocity_interp.y.quadratic(position_x85, position_y85);
//probe 86 measurement
float measurement_pressure86 = Pressure_interp.quadratic(position_x86, position_y86);
float measurement_speed_x86 = velocity_interp.x.quadratic(position_x86, position_y86);
float measurement_speed_y86 = velocity_interp.y.quadratic(position_x86, position_y86);
//probe 87 measurement
float measurement_pressure87 = Pressure_interp.quadratic(position_x87, position_y87);
float measurement_speed_x87 = velocity_interp.x.quadratic(position_x87, position_y87);
float measurement_speed_y87 = velocity_interp.y.quadratic(position_x87, position_y87);
//probe 88 measurement
float measurement_pressure88 = Pressure_interp.quadratic(position_x88, position_y88);
float measurement_speed_x88 = velocity_interp.x.quadratic(position_x88, position_y88);
float measurement_speed_y88 = velocity_interp.y.quadratic(position_x88, position_y88);
//probe 89 measurement
float measurement_pressure89 = Pressure_interp.quadratic(position_x89, position_y89);
float measurement_speed_x89 = velocity_interp.x.quadratic(position_x89, position_y89);
float measurement_speed_y89 = velocity_interp.y.quadratic(position_x89, position_y89);
//probe 90 measurement
float measurement_pressure90 = Pressure_interp.quadratic(position_x90, position_y90);
float measurement_speed_x90 = velocity_interp.x.quadratic(position_x90, position_y90);
float measurement_speed_y90 = velocity_interp.y.quadratic(position_x90, position_y90);
//probe 91 measurement
float measurement_pressure91 = Pressure_interp.quadratic(position_x91, position_y91);
float measurement_speed_x91 = velocity_interp.x.quadratic(position_x91, position_y91);
float measurement_speed_y91 = velocity_interp.y.quadratic(position_x91, position_y91);
//probe 92 measurement
float measurement_pressure92 = Pressure_interp.quadratic(position_x92, position_y92);
float measurement_speed_x92 = velocity_interp.x.quadratic(position_x92, position_y92);
float measurement_speed_y92 = velocity_interp.y.quadratic(position_x92, position_y92);
//probe 93 measurement
float measurement_pressure93 = Pressure_interp.quadratic(position_x93, position_y93);
float measurement_speed_x93 = velocity_interp.x.quadratic(position_x93, position_y93);
float measurement_speed_y93 = velocity_interp.y.quadratic(position_x93, position_y93);
//probe 94 measurement
float measurement_pressure94 = Pressure_interp.quadratic(position_x94, position_y94);
float measurement_speed_x94 = velocity_interp.x.quadratic(position_x94, position_y94);
float measurement_speed_y94 = velocity_interp.y.quadratic(position_x94, position_y94);
//probe 95 measurement
float measurement_pressure95 = Pressure_interp.quadratic(position_x95, position_y95);
float measurement_speed_x95 = velocity_interp.x.quadratic(position_x95, position_y95);
float measurement_speed_y95 = velocity_interp.y.quadratic(position_x95, position_y95);
//probe 96 measurement
float measurement_pressure96 = Pressure_interp.quadratic(position_x96, position_y96);
float measurement_speed_x96 = velocity_interp.x.quadratic(position_x96, position_y96);
float measurement_speed_y96 = velocity_interp.y.quadratic(position_x96, position_y96);
//probe 97 measurement
float measurement_pressure97 = Pressure_interp.quadratic(position_x97, position_y97);
float measurement_speed_x97 = velocity_interp.x.quadratic(position_x97, position_y97);
float measurement_speed_y97 = velocity_interp.y.quadratic(position_x97, position_y97);
//probe 98 measurement
float measurement_pressure98 = Pressure_interp.quadratic(position_x98, position_y98);
float measurement_speed_x98 = velocity_interp.x.quadratic(position_x98, position_y98);
float measurement_speed_y98 = velocity_interp.y.quadratic(position_x98, position_y98);
//probe 99 measurement
float measurement_pressure99 = Pressure_interp.quadratic(position_x99, position_y99);
float measurement_speed_x99 = velocity_interp.x.quadratic(position_x99, position_y99);
float measurement_speed_y99 = velocity_interp.y.quadratic(position_x99, position_y99);
//probe 100 measurement
float measurement_pressure100 = Pressure_interp.quadratic(position_x100, position_y100);
float measurement_speed_x100 = velocity_interp.x.quadratic(position_x100, position_y100);
float measurement_speed_y100 = velocity_interp.y.quadratic(position_x100, position_y100);
//probe 101 measurement
float measurement_pressure101 = Pressure_interp.quadratic(position_x101, position_y101);
float measurement_speed_x101 = velocity_interp.x.quadratic(position_x101, position_y101);
float measurement_speed_y101 = velocity_interp.y.quadratic(position_x101, position_y101);
//probe 102 measurement
float measurement_pressure102 = Pressure_interp.quadratic(position_x102, position_y102);
float measurement_speed_x102 = velocity_interp.x.quadratic(position_x102, position_y102);
float measurement_speed_y102 = velocity_interp.y.quadratic(position_x102, position_y102);
//probe 103 measurement
float measurement_pressure103 = Pressure_interp.quadratic(position_x103, position_y103);
float measurement_speed_x103 = velocity_interp.x.quadratic(position_x103, position_y103);
float measurement_speed_y103 = velocity_interp.y.quadratic(position_x103, position_y103);
//probe 104 measurement
float measurement_pressure104 = Pressure_interp.quadratic(position_x104, position_y104);
float measurement_speed_x104 = velocity_interp.x.quadratic(position_x104, position_y104);
float measurement_speed_y104 = velocity_interp.y.quadratic(position_x104, position_y104);
//probe 105 measurement
float measurement_pressure105 = Pressure_interp.quadratic(position_x105, position_y105);
float measurement_speed_x105 = velocity_interp.x.quadratic(position_x105, position_y105);
float measurement_speed_y105 = velocity_interp.y.quadratic(position_x105, position_y105);
//probe 106 measurement
float measurement_pressure106 = Pressure_interp.quadratic(position_x106, position_y106);
float measurement_speed_x106 = velocity_interp.x.quadratic(position_x106, position_y106);
float measurement_speed_y106 = velocity_interp.y.quadratic(position_x106, position_y106);
//probe 107 measurement
float measurement_pressure107 = Pressure_interp.quadratic(position_x107, position_y107);
float measurement_speed_x107 = velocity_interp.x.quadratic(position_x107, position_y107);
float measurement_speed_y107 = velocity_interp.y.quadratic(position_x107, position_y107);
//probe 108 measurement
float measurement_pressure108 = Pressure_interp.quadratic(position_x108, position_y108);
float measurement_speed_x108 = velocity_interp.x.quadratic(position_x108, position_y108);
float measurement_speed_y108 = velocity_interp.y.quadratic(position_x108, position_y108);
//probe 109 measurement
float measurement_pressure109 = Pressure_interp.quadratic(position_x109, position_y109);
float measurement_speed_x109 = velocity_interp.x.quadratic(position_x109, position_y109);
float measurement_speed_y109 = velocity_interp.y.quadratic(position_x109, position_y109);
//probe 110 measurement
float measurement_pressure110 = Pressure_interp.quadratic(position_x110, position_y110);
float measurement_speed_x110 = velocity_interp.x.quadratic(position_x110, position_y110);
float measurement_speed_y110 = velocity_interp.y.quadratic(position_x110, position_y110);
//probe 111 measurement
float measurement_pressure111 = Pressure_interp.quadratic(position_x111, position_y111);
float measurement_speed_x111 = velocity_interp.x.quadratic(position_x111, position_y111);
float measurement_speed_y111 = velocity_interp.y.quadratic(position_x111, position_y111);
//probe 112 measurement
float measurement_pressure112 = Pressure_interp.quadratic(position_x112, position_y112);
float measurement_speed_x112 = velocity_interp.x.quadratic(position_x112, position_y112);
float measurement_speed_y112 = velocity_interp.y.quadratic(position_x112, position_y112);
//probe 113 measurement
float measurement_pressure113 = Pressure_interp.quadratic(position_x113, position_y113);
float measurement_speed_x113 = velocity_interp.x.quadratic(position_x113, position_y113);
float measurement_speed_y113 = velocity_interp.y.quadratic(position_x113, position_y113);
//probe 114 measurement
float measurement_pressure114 = Pressure_interp.quadratic(position_x114, position_y114);
float measurement_speed_x114 = velocity_interp.x.quadratic(position_x114, position_y114);
float measurement_speed_y114 = velocity_interp.y.quadratic(position_x114, position_y114);
//probe 115 measurement
float measurement_pressure115 = Pressure_interp.quadratic(position_x115, position_y115);
float measurement_speed_x115 = velocity_interp.x.quadratic(position_x115, position_y115);
float measurement_speed_y115 = velocity_interp.y.quadratic(position_x115, position_y115);
//probe 116 measurement
float measurement_pressure116 = Pressure_interp.quadratic(position_x116, position_y116);
float measurement_speed_x116 = velocity_interp.x.quadratic(position_x116, position_y116);
float measurement_speed_y116 = velocity_interp.y.quadratic(position_x116, position_y116);
//probe 117 measurement
float measurement_pressure117 = Pressure_interp.quadratic(position_x117, position_y117);
float measurement_speed_x117 = velocity_interp.x.quadratic(position_x117, position_y117);
float measurement_speed_y117 = velocity_interp.y.quadratic(position_x117, position_y117);
//probe 118 measurement
float measurement_pressure118 = Pressure_interp.quadratic(position_x118, position_y118);
float measurement_speed_x118 = velocity_interp.x.quadratic(position_x118, position_y118);
float measurement_speed_y118 = velocity_interp.y.quadratic(position_x118, position_y118);
//probe 119 measurement
float measurement_pressure119 = Pressure_interp.quadratic(position_x119, position_y119);
float measurement_speed_x119 = velocity_interp.x.quadratic(position_x119, position_y119);
float measurement_speed_y119 = velocity_interp.y.quadratic(position_x119, position_y119);
//probe 120 measurement
float measurement_pressure120 = Pressure_interp.quadratic(position_x120, position_y120);
float measurement_speed_x120 = velocity_interp.x.quadratic(position_x120, position_y120);
float measurement_speed_y120 = velocity_interp.y.quadratic(position_x120, position_y120);
//probe 121 measurement
float measurement_pressure121 = Pressure_interp.quadratic(position_x121, position_y121);
float measurement_speed_x121 = velocity_interp.x.quadratic(position_x121, position_y121);
float measurement_speed_y121 = velocity_interp.y.quadratic(position_x121, position_y121);
//probe 122 measurement
float measurement_pressure122 = Pressure_interp.quadratic(position_x122, position_y122);
float measurement_speed_x122 = velocity_interp.x.quadratic(position_x122, position_y122);
float measurement_speed_y122 = velocity_interp.y.quadratic(position_x122, position_y122);
//probe 123 measurement
float measurement_pressure123 = Pressure_interp.quadratic(position_x123, position_y123);
float measurement_speed_x123 = velocity_interp.x.quadratic(position_x123, position_y123);
float measurement_speed_y123 = velocity_interp.y.quadratic(position_x123, position_y123);
//probe 124 measurement
float measurement_pressure124 = Pressure_interp.quadratic(position_x124, position_y124);
float measurement_speed_x124 = velocity_interp.x.quadratic(position_x124, position_y124);
float measurement_speed_y124 = velocity_interp.y.quadratic(position_x124, position_y124);
//probe 125 measurement
float measurement_pressure125 = Pressure_interp.quadratic(position_x125, position_y125);
float measurement_speed_x125 = velocity_interp.x.quadratic(position_x125, position_y125);
float measurement_speed_y125 = velocity_interp.y.quadratic(position_x125, position_y125);
//probe 126 measurement
float measurement_pressure126 = Pressure_interp.quadratic(position_x126, position_y126);
float measurement_speed_x126 = velocity_interp.x.quadratic(position_x126, position_y126);
float measurement_speed_y126 = velocity_interp.y.quadratic(position_x126, position_y126);
//probe 127 measurement
float measurement_pressure127 = Pressure_interp.quadratic(position_x127, position_y127);
float measurement_speed_x127 = velocity_interp.x.quadratic(position_x127, position_y127);
float measurement_speed_y127 = velocity_interp.y.quadratic(position_x127, position_y127);
//probe 128 measurement
float measurement_pressure128 = Pressure_interp.quadratic(position_x128, position_y128);
float measurement_speed_x128 = velocity_interp.x.quadratic(position_x128, position_y128);
float measurement_speed_y128 = velocity_interp.y.quadratic(position_x128, position_y128);
//probe 129 measurement
float measurement_pressure129 = Pressure_interp.quadratic(position_x129, position_y129);
float measurement_speed_x129 = velocity_interp.x.quadratic(position_x129, position_y129);
float measurement_speed_y129 = velocity_interp.y.quadratic(position_x129, position_y129);
//probe 130 measurement
float measurement_pressure130 = Pressure_interp.quadratic(position_x130, position_y130);
float measurement_speed_x130 = velocity_interp.x.quadratic(position_x130, position_y130);
float measurement_speed_y130 = velocity_interp.y.quadratic(position_x130, position_y130);
//probe 131 measurement
float measurement_pressure131 = Pressure_interp.quadratic(position_x131, position_y131);
float measurement_speed_x131 = velocity_interp.x.quadratic(position_x131, position_y131);
float measurement_speed_y131 = velocity_interp.y.quadratic(position_x131, position_y131);
//probe 132 measurement
float measurement_pressure132 = Pressure_interp.quadratic(position_x132, position_y132);
float measurement_speed_x132 = velocity_interp.x.quadratic(position_x132, position_y132);
float measurement_speed_y132 = velocity_interp.y.quadratic(position_x132, position_y132);
//probe 133 measurement
float measurement_pressure133 = Pressure_interp.quadratic(position_x133, position_y133);
float measurement_speed_x133 = velocity_interp.x.quadratic(position_x133, position_y133);
float measurement_speed_y133 = velocity_interp.y.quadratic(position_x133, position_y133);
//probe 134 measurement
float measurement_pressure134 = Pressure_interp.quadratic(position_x134, position_y134);
float measurement_speed_x134 = velocity_interp.x.quadratic(position_x134, position_y134);
float measurement_speed_y134 = velocity_interp.y.quadratic(position_x134, position_y134);
//probe 135 measurement
float measurement_pressure135 = Pressure_interp.quadratic(position_x135, position_y135);
float measurement_speed_x135 = velocity_interp.x.quadratic(position_x135, position_y135);
float measurement_speed_y135 = velocity_interp.y.quadratic(position_x135, position_y135);
//probe 136 measurement
float measurement_pressure136 = Pressure_interp.quadratic(position_x136, position_y136);
float measurement_speed_x136 = velocity_interp.x.quadratic(position_x136, position_y136);
float measurement_speed_y136 = velocity_interp.y.quadratic(position_x136, position_y136);
//probe 137 measurement
float measurement_pressure137 = Pressure_interp.quadratic(position_x137, position_y137);
float measurement_speed_x137 = velocity_interp.x.quadratic(position_x137, position_y137);
float measurement_speed_y137 = velocity_interp.y.quadratic(position_x137, position_y137);
//probe 138 measurement
float measurement_pressure138 = Pressure_interp.quadratic(position_x138, position_y138);
float measurement_speed_x138 = velocity_interp.x.quadratic(position_x138, position_y138);
float measurement_speed_y138 = velocity_interp.y.quadratic(position_x138, position_y138);
//probe 139 measurement
float measurement_pressure139 = Pressure_interp.quadratic(position_x139, position_y139);
float measurement_speed_x139 = velocity_interp.x.quadratic(position_x139, position_y139);
float measurement_speed_y139 = velocity_interp.y.quadratic(position_x139, position_y139);
//probe 140 measurement
float measurement_pressure140 = Pressure_interp.quadratic(position_x140, position_y140);
float measurement_speed_x140 = velocity_interp.x.quadratic(position_x140, position_y140);
float measurement_speed_y140 = velocity_interp.y.quadratic(position_x140, position_y140);
//probe 141 measurement
float measurement_pressure141 = Pressure_interp.quadratic(position_x141, position_y141);
float measurement_speed_x141 = velocity_interp.x.quadratic(position_x141, position_y141);
float measurement_speed_y141 = velocity_interp.y.quadratic(position_x141, position_y141);


output_probes.println(""+deltatime+","+measurement_pressure1+","+measurement_speed_x1+","+measurement_speed_y1+","+measurement_pressure2+","+measurement_speed_x2+","+measurement_speed_y2+","+measurement_pressure3+","+measurement_speed_x3+","+measurement_speed_y3+","+measurement_pressure4+","+measurement_speed_x4+","+measurement_speed_y4+","+measurement_pressure5+","+measurement_speed_x5+","+measurement_speed_y5+","+measurement_pressure6+","+measurement_speed_x6+","+measurement_speed_y6+","+measurement_pressure7+","+measurement_speed_x7+","+measurement_speed_y7+","+measurement_pressure8+","+measurement_speed_x8+","+measurement_speed_y8+","+measurement_pressure9+","+measurement_speed_x9+","+measurement_speed_y9+","+measurement_pressure10+","+measurement_speed_x10+","+measurement_speed_y10+","+measurement_pressure11+","+measurement_speed_x11+","+measurement_speed_y11+","+measurement_pressure12+","+measurement_speed_x12+","+measurement_speed_y12+","+measurement_pressure13+","+measurement_speed_x13+","+measurement_speed_y13+","+measurement_pressure14+","+measurement_speed_x14+","+measurement_speed_y14+","+measurement_pressure15+","+measurement_speed_x15+","+measurement_speed_y15+","+measurement_pressure16+","+measurement_speed_x16+","+measurement_speed_y16+","+measurement_pressure17+","+measurement_speed_x17+","+measurement_speed_y17+","+measurement_pressure18+","+measurement_speed_x18+","+measurement_speed_y18+","+measurement_pressure19+","+measurement_speed_x19+","+measurement_speed_y19+","+measurement_pressure20+","+measurement_speed_x20+","+measurement_speed_y20+","+measurement_pressure21+","+measurement_speed_x21+","+measurement_speed_y21+","+measurement_pressure22+","+measurement_speed_x22+","+measurement_speed_y22+","+measurement_pressure23+","+measurement_speed_x23+","+measurement_speed_y23+","+measurement_pressure24+","+measurement_speed_x24+","+measurement_speed_y24+","+measurement_pressure25+","+measurement_speed_x25+","+measurement_speed_y25+","+measurement_pressure26+","+measurement_speed_x26+","+measurement_speed_y26+","+measurement_pressure27+","+measurement_speed_x27+","+measurement_speed_y27+","+measurement_pressure28+","+measurement_speed_x28+","+measurement_speed_y28+","+measurement_pressure29+","+measurement_speed_x29+","+measurement_speed_y29+","+measurement_pressure30+","+measurement_speed_x30+","+measurement_speed_y30+","+measurement_pressure31+","+measurement_speed_x31+","+measurement_speed_y31+","+measurement_pressure32+","+measurement_speed_x32+","+measurement_speed_y32+","+measurement_pressure33+","+measurement_speed_x33+","+measurement_speed_y33+","+measurement_pressure34+","+measurement_speed_x34+","+measurement_speed_y34+","+measurement_pressure35+","+measurement_speed_x35+","+measurement_speed_y35+","+measurement_pressure36+","+measurement_speed_x36+","+measurement_speed_y36+","+measurement_pressure37+","+measurement_speed_x37+","+measurement_speed_y37+","+measurement_pressure38+","+measurement_speed_x38+","+measurement_speed_y38+","+measurement_pressure39+","+measurement_speed_x39+","+measurement_speed_y39+","+measurement_pressure40+","+measurement_speed_x40+","+measurement_speed_y40+","+measurement_pressure41+","+measurement_speed_x41+","+measurement_speed_y41+","+measurement_pressure42+","+measurement_speed_x42+","+measurement_speed_y42+","+measurement_pressure43+","+measurement_speed_x43+","+measurement_speed_y43+","+measurement_pressure44+","+measurement_speed_x44+","+measurement_speed_y44+","+measurement_pressure45+","+measurement_speed_x45+","+measurement_speed_y45+","+measurement_pressure46+","+measurement_speed_x46+","+measurement_speed_y46+","+measurement_pressure47+","+measurement_speed_x47+","+measurement_speed_y47+","+measurement_pressure48+","+measurement_speed_x48+","+measurement_speed_y48+","+measurement_pressure49+","+measurement_speed_x49+","+measurement_speed_y49+","+measurement_pressure50+","+measurement_speed_x50+","+measurement_speed_y50+","+measurement_pressure51+","+measurement_speed_x51+","+measurement_speed_y51+","+measurement_pressure52+","+measurement_speed_x52+","+measurement_speed_y52+","+measurement_pressure53+","+measurement_speed_x53+","+measurement_speed_y53+","+measurement_pressure54+","+measurement_speed_x54+","+measurement_speed_y54+","+measurement_pressure55+","+measurement_speed_x55+","+measurement_speed_y55+","+measurement_pressure56+","+measurement_speed_x56+","+measurement_speed_y56+","+measurement_pressure57+","+measurement_speed_x57+","+measurement_speed_y57+","+measurement_pressure58+","+measurement_speed_x58+","+measurement_speed_y58+","+measurement_pressure59+","+measurement_speed_x59+","+measurement_speed_y59+","+measurement_pressure60+","+measurement_speed_x60+","+measurement_speed_y60+","+measurement_pressure61+","+measurement_speed_x61+","+measurement_speed_y61+","+measurement_pressure62+","+measurement_speed_x62+","+measurement_speed_y62+","+measurement_pressure63+","+measurement_speed_x63+","+measurement_speed_y63+","+measurement_pressure64+","+measurement_speed_x64+","+measurement_speed_y64+","+measurement_pressure65+","+measurement_speed_x65+","+measurement_speed_y65+","+measurement_pressure66+","+measurement_speed_x66+","+measurement_speed_y66+","+measurement_pressure67+","+measurement_speed_x67+","+measurement_speed_y67+","+measurement_pressure68+","+measurement_speed_x68+","+measurement_speed_y68+","+measurement_pressure69+","+measurement_speed_x69+","+measurement_speed_y69+","+measurement_pressure70+","+measurement_speed_x70+","+measurement_speed_y70+","+measurement_pressure71+","+measurement_speed_x71+","+measurement_speed_y71+","+measurement_pressure72+","+measurement_speed_x72+","+measurement_speed_y72+","+measurement_pressure73+","+measurement_speed_x73+","+measurement_speed_y73+","+measurement_pressure74+","+measurement_speed_x74+","+measurement_speed_y74+","+measurement_pressure75+","+measurement_speed_x75+","+measurement_speed_y75+","+measurement_pressure76+","+measurement_speed_x76+","+measurement_speed_y76+","+measurement_pressure77+","+measurement_speed_x77+","+measurement_speed_y77+","+measurement_pressure78+","+measurement_speed_x78+","+measurement_speed_y78+","+measurement_pressure79+","+measurement_speed_x79+","+measurement_speed_y79+","+measurement_pressure80+","+measurement_speed_x80+","+measurement_speed_y80+","+measurement_pressure81+","+measurement_speed_x81+","+measurement_speed_y81+","+measurement_pressure82+","+measurement_speed_x82+","+measurement_speed_y82+","+measurement_pressure83+","+measurement_speed_x83+","+measurement_speed_y83+","+measurement_pressure84+","+measurement_speed_x84+","+measurement_speed_y84+","+measurement_pressure85+","+measurement_speed_x85+","+measurement_speed_y85+","+measurement_pressure86+","+measurement_speed_x86+","+measurement_speed_y86+","+measurement_pressure87+","+measurement_speed_x87+","+measurement_speed_y87+","+measurement_pressure88+","+measurement_speed_x88+","+measurement_speed_y88+","+measurement_pressure89+","+measurement_speed_x89+","+measurement_speed_y89+","+measurement_pressure90+","+measurement_speed_x90+","+measurement_speed_y90+","+measurement_pressure91+","+measurement_speed_x91+","+measurement_speed_y91+","+measurement_pressure92+","+measurement_speed_x92+","+measurement_speed_y92+","+measurement_pressure93+","+measurement_speed_x93+","+measurement_speed_y93+","+measurement_pressure94+","+measurement_speed_x94+","+measurement_speed_y94+","+measurement_pressure95+","+measurement_speed_x95+","+measurement_speed_y95+","+measurement_pressure96+","+measurement_speed_x96+","+measurement_speed_y96+","+measurement_pressure97+","+measurement_speed_x97+","+measurement_speed_y97+","+measurement_pressure98+","+measurement_speed_x98+","+measurement_speed_y98+","+measurement_pressure99+","+measurement_speed_x99+","+measurement_speed_y99+","+measurement_pressure100+","+measurement_speed_x100+","+measurement_speed_y100+","+measurement_pressure101+","+measurement_speed_x101+","+measurement_speed_y101+","+measurement_pressure102+","+measurement_speed_x102+","+measurement_speed_y102+","+measurement_pressure103+","+measurement_speed_x103+","+measurement_speed_y103+","+measurement_pressure104+","+measurement_speed_x104+","+measurement_speed_y104+","+measurement_pressure105+","+measurement_speed_x105+","+measurement_speed_y105+","+measurement_pressure106+","+measurement_speed_x106+","+measurement_speed_y106+","+measurement_pressure107+","+measurement_speed_x107+","+measurement_speed_y107+","+measurement_pressure108+","+measurement_speed_x108+","+measurement_speed_y108+","+measurement_pressure109+","+measurement_speed_x109+","+measurement_speed_y109+","+measurement_pressure110+","+measurement_speed_x110+","+measurement_speed_y110+","+measurement_pressure111+","+measurement_speed_x111+","+measurement_speed_y111+","+measurement_pressure112+","+measurement_speed_x112+","+measurement_speed_y112+","+measurement_pressure113+","+measurement_speed_x113+","+measurement_speed_y113+","+measurement_pressure114+","+measurement_speed_x114+","+measurement_speed_y114+","+measurement_pressure115+","+measurement_speed_x115+","+measurement_speed_y115+","+measurement_pressure116+","+measurement_speed_x116+","+measurement_speed_y116+","+measurement_pressure117+","+measurement_speed_x117+","+measurement_speed_y117+","+measurement_pressure118+","+measurement_speed_x118+","+measurement_speed_y118+","+measurement_pressure119+","+measurement_speed_x119+","+measurement_speed_y119+","+measurement_pressure120+","+measurement_speed_x120+","+measurement_speed_y120+","+measurement_pressure121+","+measurement_speed_x121+","+measurement_speed_y121+","+measurement_pressure122+","+measurement_speed_x122+","+measurement_speed_y122+","+measurement_pressure123+","+measurement_speed_x123+","+measurement_speed_y123+","+measurement_pressure124+","+measurement_speed_x124+","+measurement_speed_y124+","+measurement_pressure125+","+measurement_speed_x125+","+measurement_speed_y125+","+measurement_pressure126+","+measurement_speed_x126+","+measurement_speed_y126+","+measurement_pressure127+","+measurement_speed_x127+","+measurement_speed_y127+","+measurement_pressure128+","+measurement_speed_x128+","+measurement_speed_y128+","+measurement_pressure129+","+measurement_speed_x129+","+measurement_speed_y129+","+measurement_pressure130+","+measurement_speed_x130+","+measurement_speed_y130+","+measurement_pressure131+","+measurement_speed_x131+","+measurement_speed_y131+","+measurement_pressure132+","+measurement_speed_x132+","+measurement_speed_y132+","+measurement_pressure133+","+measurement_speed_x133+","+measurement_speed_y133+","+measurement_pressure134+","+measurement_speed_x134+","+measurement_speed_y134+","+measurement_pressure135+","+measurement_speed_x135+","+measurement_speed_y135+","+measurement_pressure136+","+measurement_speed_x136+","+measurement_speed_y136+","+measurement_pressure137+","+measurement_speed_x137+","+measurement_speed_y137+","+measurement_pressure138+","+measurement_speed_x138+","+measurement_speed_y138+","+measurement_pressure139+","+measurement_speed_x139+","+measurement_speed_y139+","+measurement_pressure140+","+measurement_speed_x140+","+measurement_speed_y140+","+measurement_pressure141+","+measurement_speed_x141+","+measurement_speed_y141+"");

    
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
  
  //if (timestep/10.0 == timestep/10) {
  //  saveFrame("saved/frame-####.tif");
  //}
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
