///*********************************************************
//Two Foils
//*******************************************************/

//class TwoFoils extends BodyUnion{
//  float x0,y0,x1,y1,L,th,St;
  
//  TwoFoils( float x0, float y0, float x1, float y1, float L, float th, float St, Window view){
////  make geometry
//    super(new NACA(x0,y0,L,t,view),        // front foil
//          new NACA(x1,y1,L,t,view));     // back foil

////// save parameters
////    this.L = L;                              // Foil coord
////    this.x0 = x0; this.y0 = y0;              // Starting position of front foil
////    this.s = s; this.lead = lead;            // Spacing and phase lag
////    this.St = St;                            // Strouhal number of motion

////// set pitch amplitude to get 10 degree AOA
////    pamp = atan(PI*St)-PI/18.;               
    
////// set initial state
////    bodyList.get(0).follow(kinematics(x0,y0,0),new PVector());
////    bodyList.get(1).follow(kinematics(x1,y1,0),new PVector());

//////// set color
//////    bodyColor=color(255);
////  }

////// update the position of the two foils
////  void update(float t, float dt){
////    bodyList.get(0).follow(kinematics(0,0,t),dkinematics(0,t,dt));
////    bodyList.get(1).follow(kinematics(s,lead,t),dkinematics(lead,t,dt));
////  }
  
////// define the foil motion
////  PVector kinematics(float s, float lead, float t){    
////    float phase = PI*St*t/L+lead;          // phase
////    return new PVector(x0+s,               // x position
////                       y0-L*sin(phase),    // y position
////                       pamp*cos(phase));   // pitch position
////  }
////  PVector dkinematics(float lead, float t, float dt){
////    float phase = PI*St*t/L+lead;          // phase
////    return new PVector(0,                  // dx
////                       -cos(phase)*PI*St*dt,   // dy
////                       -pamp*sin(phase)*PI*St/L*dt); // dphi
////  }
  
////// get pressure force of both foils
////  PVector[] pressForces(Field p){
////    PVector f0 = bodyList.get(0).pressForce(p);
////    PVector f1 = bodyList.get(1).pressForce(p);
////    return new PVector[]{f0,f1};
////  }
//}
