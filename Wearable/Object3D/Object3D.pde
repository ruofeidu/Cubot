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
static final int CALI_MAX_NUM = 1;
static final float CALI_PERCENT = 1.2; 
static final int MSG_LENGTH = 2 + 6; 
static final int CONTROL_VAR_ID = 4;   // 1, 2, 3, 4 
static final int HX_ID = 4;
static final int HY_ID = 5; 
static final int HZ_ID = 6; 
float delta = 40; 
float upDelta = 0; 
float degree = 0; 

class SlidingWindow {
  private static final int MAXN = 3; 
  public int[] arr; 
  private int cur;
  private int total;
  private int maxn; 
  
  SlidingWindow(){
    cur = 0; 
    total = 0; 
    maxn = MAXN; 
    arr = new int[MAXN];   
  }    
  
  SlidingWindow(int n) {
    cur = 0; 
    maxn = n; 
    total = 0; 
    arr = new int[n]; 
  }
  
  public void add(int x) {
    if (total < maxn) {
      ++total; 
    }
    cur = (cur + 1) % maxn; 
    arr[cur] = x;   
  }
  
  public int get() {
    int sum = 0; 
    for (int i = 0; i < total; ++i) {
      sum += arr[i]; 
    }
    int ans = ((int) ((float) sum / total) ); 
    return ans; 
  }
  
  
}

SlidingWindow compass = new SlidingWindow(); 

void setup() {
  size(800, 600, P2D);
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

static final float STEP = 1;

void draw() {
  background(0);
  
  if (ON_SERIAL) {
      String msg = port.readStringUntil(LF); 
      if (msg != null) {
        //print(msg); 
        String[] dataStr = split(msg, ','); 
        if(dataStr.length == MSG_LENGTH && dataStr[0].length() > 0 && dataStr[0].charAt(0) == HEADER)
        {
          int val = Integer.parseInt(dataStr[CONTROL_VAR_ID]);
          compass.add(val); 
          int ans = compass.get(); 
          if (ans % 2 == 0) ans += 1;  
          shader.set("time", (float)ans / 360 * 18);
        }
      }
  }
    
  shader(shader); 
  rect(0, 0, width, height);
  
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
  
  
  shader.set("time", delta);
  println("time:" + delta); 
  shader.set("mouse", delta/2 - upDelta, delta);
}

