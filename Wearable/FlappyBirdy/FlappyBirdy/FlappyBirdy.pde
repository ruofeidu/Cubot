/** 
 * FlappyBirdy
 * Ruofei Du, Fan Du
 * HCIL, UMD
 *
 * License: Creative Commons Attribution-Share Alike 3.0 and GNU GPL license
 *
 * References:
 * 1) http://tinyurl.com/reddit-crappybird 
 * 2) http://www.ktbyte.com/js/processing/sketches/crappierbird.pde
 *
 */

import processing.serial.*;          // For Arduino
import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
static final String flapFile = "flap.wav"; 


static final boolean FINGER_JUMP = true; 

AudioPlayer flapPlayer;
AudioInput input;
AudioOutput out;
// for serial testing
static Serial port;  
static final boolean ON_SERIAL = true; 
static final int SERIAL_ID = 2; 
static final short LF = 10;
static final char HEADER = '~'; 
static final int EASINESS = 150;
static final int CALI_MAX_NUM = 20;
static float CALI_PERCENT = 1.; //1.9; //1.2; 
static final int MSG_LENGTH = 2 + 6; 
static final int CONTROL_VAR_ID = 1;   // 1, 2, 3, 4 

// calibration and control variable
static boolean secondJump = false; 
static int peakValue = -1; 
static int prevValue = -1; 
static boolean jumping = false;  
static boolean downwards = false; 

static int caliNum = 0; 
static int caliValue = 0; 
static boolean started = false; 
static boolean musicPlayed = false; 

PImage c, b, w, m;

//TODO: it is too hard. Make it easier by reducing the jumping strength
void setup() {
  minim = new Minim(this);
  flapPlayer = minim.loadFile(flapFile);
  //input = minim.getLineIn();
  out = minim.getLineOut();
  out.setTempo( 80 );
  //out.pauseNotes();
  println("FlappyBirdy Starts"); 
  size(600,  800); 
  frameRate(30); 
  
  if (ON_SERIAL) {
    for (int i = 0; i < 3; ++i) {
      println(Serial.list()[i]);
    }
    port = new Serial(this, Serial.list()[SERIAL_ID], 9600);
  }
  
  if (FINGER_JUMP) {
     CALI_PERCENT = 1.3; 
  } else {
     CALI_PERCENT = 1.8; 
  }
  
  c = loadImage("background.png");
  b = loadImage("birdy.png"); 
  w = loadImage("obstacle.png");
  m = loadImage("welcomebg.png"); 
}

//PImage c = loadImage("http://photo.duruofei.com/background.png"), b = loadImage("http://photo.duruofei.com/birdy.png"); 
//PImage w = loadImage("http://photo.duruofei.com/obstacle.png"), m = loadImage("http://photo.duruofei.com/welcomebg.png"); 


int r, s=0, d=1, x, y=400, vy, wx[]={0, 0}, wy[]={0, 0}, e=1800, l=600, hs=0, v=800; 

void draw() { 
  if (ON_SERIAL) {
      String msg = port.readStringUntil(LF); 
      if (msg != null) {
        //print(msg); 
        String[] dataStr = split(msg, ','); 
        if(dataStr.length == MSG_LENGTH && dataStr[0].length() > 0 && dataStr[0].charAt(0) == HEADER)
        { 
          int val = Integer.parseInt(dataStr[CONTROL_VAR_ID]);
          println(val);
          
          // 1 - 4
          if (caliNum < CALI_MAX_NUM) {
            ++caliNum; 
            caliValue += val; 
          } else
          if (caliNum == CALI_MAX_NUM) {
            caliValue = caliValue / CALI_MAX_NUM;   
            ++caliNum;
            println(caliValue); 
          } else {
            // It's a jump by default
            if (val > caliValue * CALI_PERCENT) {
              jumping = true; 
              
              // see if it's a second jump
              if (!downwards) {
                if (val >= peakValue) {
                  if (!FINGER_JUMP) {    
                    if (!secondJump) {
                      jump(); 
                      println(val + "\t" + 1); 
                    }
                    secondJump = !secondJump; 
                  } else {
                    jump();
                  }
                  peakValue = val; 
                } else {
                  prevValue = val; 
                  downwards = true; 
                }
              } else {
                if (val >= prevValue) {
                  //another peak
                  if (FINGER_JUMP) {    
                    jump(); 
                    println("2nd jump: " + val); 
                  }
                  peakValue = val; 
                  downwards = false; 
                } else {
                  prevValue = val; 
                }
              }
              
            } else {
              jumping = false; 
              downwards = false;   
              peakValue = -1; 
            }
          }
        }
      }
  }
   
  for(int t=0, q=1; t<=e; t+=e, q=1) {
    for(imageMode(1); q>0; q--, imageMode(3)) {
      image(c, x+t, 0);  
    }
  }
  
  for(int i=0, z=y+=vy+=1, q=(x=x-6==-1800?0:x-6); i<2; i++, fill(0), textSize(40), image(b, l/2, y)){
    for(int j=-1; j<2; j+=2, text(""+(s+534), l/2-15, 700)) 
      image(w,  wx[i],  wy[i] + j*(w.height/2+EASINESS)); 
      
    if((wx[i]=wx[i]<0?(wy[i]=(int)random(200, v-200))/wy[i]*l:wx[i]-6)==l/2&&d==0) 
      hs=max(++s, hs); 
      if ((abs(width/2-wx[i])<25 && abs(y-wy[i])>EASINESS) || y > height || y < 0) {
        d = 1;
        /*
        if (!started) {
          out.playNote("C4");
          started = true; 
        } else {
          started = false; 
        }
        */
      } 
  } 
  if (d==(r=1)) {
    for(imageMode(1); r>0; r--, rectMode(3), text("Score: "+(hs+534), 50, l)) {
      image(m,  0,  0);
    }
  } 
} 

void jump() {
   out.playNote("C3" );
    if (d==(vy=-17)/-17) {
      //out.playNote("C4" );
      y=(wx[1]=900) + 100 - ((wy[0]=(wy[1]=wx[0]=600)-200)+200 + (x = s = d = 0)); 
    }
}

void mousePressed() { 
  // Right mouse to save the frame
  if (mouseButton == RIGHT) {
     saveFrame("output-####.png");
  } else {
    //flapPlayer.play();
    jump();
  }
} 

void calibrate() {
  caliNum = 0;   
}

void keyPressed() {
  if((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z')) {
    int keyIndex; 
    if (key == 'c') {
      calibrate(); 
    }  
  }
}
  
void mouseReleased() {
  
  flapPlayer.close();
  flapPlayer = minim.loadFile(flapFile); 
}
