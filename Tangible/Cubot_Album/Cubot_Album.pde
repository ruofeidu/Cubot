/** 
 * FlappyBirdy
 * Ruofei Du, Fan Du
 * HCIL, UMD
 *
 * License: Creative Commons Attribution-Share Alike 3.0 and GNU GPL license
 *
 * References:
 * Figures courtesy of Jon's slides: http://www.cs.umd.edu/class/spring2014/cmsc838f/Lecture05_Sensors.pdf
 *
 */

import processing.serial.*;

Serial port;
char val;
String state;
Album album;
int[] port_vals;

int look_for_port(String portName) {
  int portIndex = -1;
  for (int i=0; i<Serial.list().length; i++) {
    println(Serial.list()[i]);
    if (Serial.list()[i].compareTo(portName) == 0)
      portIndex = i;
  }
  return portIndex;
}

//boolean sketchFullScreen() {
//  return true;
//}

void setup()
{
  size(1440, 900);
//  size(800, 600);

  album = new Album();
  background(#000000);
  smooth();
  frame.setTitle("Robot - Fan Du, Ruofei Du @ University of Maryland, 2014");

  int portIndex = look_for_port("/dev/tty.usbmodem1421");
  if (portIndex == -1) {
    println("Serial port not found");
    exit();
  }
  else {
    println("Connecting to " + Serial.list()[portIndex]);
    port = new Serial(this, Serial.list()[portIndex], 9600);
  }

  new DataThread().start();
}

int[] strings_to_ingeters(String[] strings) {
  int[] integers = new int[strings.length];
  for (int i=0; i<strings.length; i++) {
    integers[i] = Integer.parseInt(strings[i]);
  }
  return integers;
}

void draw_text(String s, float x, float y, int fontSize, int fontColor, int leftJustified) {
  fill(#FFFFFF);
  textSize(18);
  if (leftJustified == 0)
    textAlign(LEFT, TOP);
  else if (leftJustified == 1)
    textAlign(RIGHT, TOP);
  else if (leftJustified == 2)
    textAlign(CENTER, TOP);
  text(s, x, y);
}

void draw()
{
  change_state();
  background(#000000);
  album.show();
  delay(400);
}

void change_state() {
  int []vals = port_vals;

  for (int i=0; i<vals.length; i++)
    vals[i] /= 20;

  int []v = new int[3];
  v[0] = abs(vals[0]);
  v[1] = abs(vals[1]);
  v[2] = abs(vals[2]);

  int mi1=0, mi2=0;

  if (v[0] > v[1]) {
    if (v[0] > v[2]) {
      mi1 = 0;
      if (v[2] > v[1]) {
        mi2 = 2;
      }
      else {
        mi2 = 1;
      }
    }
    else {
      mi1 = 2;
      mi2 = 0;
    }
  }
  else if (v[1] > v[0]) {
    if (v[1] > v[2]) {
      mi1 = 1;
      if (v[0] > v[2]) {
        mi2 = 0;
      }
      else {
        mi2 = 2;
      }
    }
    else {
      mi1 = 2;
      mi2 = 1;
    }
  }

  String axis1 = "x";
  if (mi1 == 1) axis1 = "y";
  else if (mi1 == 2) axis1 = "z";

  String axis2 = "x";
  if (mi2 == 1) axis2 = "y";
  else if (mi2 == 2) axis2 = "z";

  String dir1 = "+";
  if (vals[mi1] < 0) dir1 = "-";

  String dir2 = "+";
  if (vals[mi2] < 0) dir2 = "-";

  String r1 = dir1+axis1;
  String r2 = dir2+axis2;
  if (v[mi2] == 0 || float(v[mi1]) / v[mi2] > 3.0) {
    r2 = "";
  }

  state = "";
  state += "x "+str(vals[0])+"\ny "+str(vals[1])+"\nz "+str(vals[2]);
  state += "\n\n"+r1+" " +r2;

  if (r2.equals("+z"))
    left();
  else if (r2.equals("-z"))
    right();
  else if (r2.equals("+y"))
    front();
  else if (r2.equals("-y"))
    back();
}

void after() {
}

void left() {
  println("left");
  album.next(1);
  after();
}

void right() {
  println("right");
  album.prev(1);
  after();
}

void front() {
  println("front");
  after();
}

void back() {
  println("back");
  after();
}


//-----------------Data-------------------

class DataThread extends Thread {
  public void run() {
    println("data thread running");
    while (true) {
      read_line();
      delay(1);
    }
  }
}

void read_line() {
  while (true) {
    StringBuffer line = get_line();
    boolean error = false;
    int []vals = null;
    try {
      vals = strings_to_ingeters(line.toString().split(","));
      if (vals.length!= 3) 
        throw new Exception();
    }
    catch (Exception e) {
      println(line);
      println("protocol error, line skipped");
      continue;
    }
    port_vals = vals;
    break;
  }
}

StringBuffer get_line() {
  StringBuffer line = new StringBuffer();
  while (true) {
    if (port.available() > 0) {
      val = port.readChar();
      if (val == ';')
        break;
      else
        line.append(val);
    }
    delay(0);
  }
  return line;
}

//// Album ////

class Album {
  int cur;
  PImage []imgs;
  final int N = 4;
  public Album() {
    imgs = new PImage[N];
    for (int i=0; i<N; i++) {
      imgs[i] = loadImage(str(i)+".jpg");
    }
    cur = 0;
  }
  public void next(int step) {
    cur += 1;
    if (cur == N) cur = 0;
  }

  public void prev(int step) {
    cur -= 1;
    if (cur < 0) cur = N-1;
  }

  public void show() {
    image(imgs[cur], 0, 0);
  }
}

