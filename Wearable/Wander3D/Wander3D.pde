/** 
 * 3D Wander
 * Ruofei Du, Fan Du
 * HCIL, UMD
 *
 * Elevated
 * https://www.shadertoy.com/view/MdX3Rr by inigo quilez
 * Created by inigo quilez - iq/2013
 * License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * Processing port by Raphaël de Courville.
 */
PShader shader;
import processing.serial.*;          // For Arduino

// for serial testing
static Serial port;  
static final boolean ON_SERIAL = true; 
static final int SERIAL_ID = 2; 
static final short LF = 10;
static final char HEADER = '~'; 

// calibration and control variable
static int caliNum = 0; 
static int caliValue = 0; 
static final int CALI_MAX_NUM = 20;
static final float CALI_PERCENT = 1.2; 
static final int MSG_LENGTH = 2 + 6; 
static final int CONTROL_VAR_ID = 1;   // 1, 2, 3, 4 
static final int HX_ID = 4;
static final int HY_ID = 5; 
static final int HZ_ID = 6; 
float delta = 40; 
float upDelta = 0; 
float degree = 0; 

void setup() {
  size(1024, 768, P2D);
  noStroke();
   
  // The code of this shader shows how to integrate shaders from shadertoy
  // into Processing with minimal changes.
  shader = loadShader("landscape.glsl");
  shader.set("resolution", float(width), float(height));   
  //shader.set("mouse", delta, delta);
  shader.set("mouse", delta/2 - upDelta, delta);
  frameRate(15); // depends on your computer 
  if (ON_SERIAL) {
    for (int i = 0; i < 3; ++i) {
      println(Serial.list()[i]);
    }
    port = new Serial(this, Serial.list()[SERIAL_ID], 9600);
  }
}

static final float STEP = 5;

void draw() {
  background(0);
  
  if (ON_SERIAL) {
      String msg = port.readStringUntil(LF); 
      if (msg != null) {
        print(msg); 
        String[] dataStr = split(msg, ','); 
        if(dataStr.length == MSG_LENGTH && dataStr[0].length() > 0 && dataStr[0].charAt(0) == HEADER)
        {
          int hx = Integer.parseInt(dataStr[4]);
          int hy = Integer.parseInt(dataStr[4]);
          int hz = Integer.parseInt(dataStr[4]);
          
          if (hx < 270 && hx > 200) {
            delta += STEP; 
          } else 
          if (hx < 100) {
            delta -= STEP; 
          } 
          if (hx > 330) {
            upDelta += STEP;
          } else
          if (hx > 100 && hx < 200) {
            upDelta -= STEP; 
          }
          
        }
      }
  }
  
   shader.set("mouse", delta/2 - upDelta, delta);
   
  //shader.set("time", (float)(millis()/1000.0));
  shader(shader); 
  rect(0, 0, width, height);
  shader.set("mouse", delta/2 - upDelta, delta);

  if (mouseButton == LEFT) {
    delta += STEP; 
    shader.set("mouse", delta/2 - upDelta, delta);
  }
  else 
  if (mouseButton == RIGHT) {
    delta -= STEP;   
    shader.set("mouse", delta/2 - upDelta, delta);
  }
  
  frame.setTitle("frame: " + frameCount + " - fps: " + frameRate);     
  
}

void mousePressed() {
  /*
  if (mouseButton == RIGHT) {
    delta -= 0.1; 
    shader.set("mouse", 0, delta);
  } else {
    delta += 0.1; 
    shader.set("mouse", 0, delta);
  } 
  */
}

void keyPressed() {
  switch (keyCode) {
    case UP: upDelta += STEP; break; 
    case DOWN: upDelta -= STEP; break; 
    case LEFT: delta += STEP; break; 
    case RIGHT: delta -= STEP; break; 
  }
  
  shader.set("mouse", delta/2 - upDelta, delta);
}

