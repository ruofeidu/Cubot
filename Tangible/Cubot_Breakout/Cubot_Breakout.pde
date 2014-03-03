//http://blog.163.com/hailin_xin/blog/static/218162190201342181943434

float x = 300;
float y = 300;
float dx = 3;
float dy = -5;
int t;
int count=0;
int points=0;

float heightbounce=600;

float mousex = 500, mousey = 500;

// beginners level
boolean[][] inside=new boolean[1][11];

void draw() {
  change_state();
  // t=0 to start new level
  if (t==0) {
    background(0);
    stroke(255);

    // Display Level the first 2 seconds
    if (count<120) {
      fill(255);
      textAlign(CENTER);
      text("LEVEL " + inside.length, 300, 500);
    }

    //draw moving point
    strokeWeight(10);
    point(x, y);
    strokeWeight(1);

    randomSeed(1);
    // box to be destroied
    for (int j=0;j<inside.length;j++) {
      for (int k=0;k<inside[0].length;k++) {
        // distance between circles and moving point
        float dx2=50+50*k-x;
        float dy2=50+50*j-y;
        float dis2=sqrt(pow(dx2, 2)+pow(dy2, 2));

        // draw circle if outside
        if (dis2>=25. && inside[j][k]==false) {
          //fill(0,255-k*10,200,150);
          fill(255, random(255));
          ellipse(50+50*k, 50+50*j, 50, 50);
        }
        // check if moving point are inside circle and from which direction it comes
        else if (dx2<=(dis2*cos(PI/4))&& dy2<=-(dis2*sin(PI/4)) && inside[j][k]==false) {
          dy*=-1;
          inside[j][k]=true;
          points++;
        }
        else if (dx2<=(dis2*cos(PI/4)) && dy2>=(dis2*sin(PI/4)) && inside[j][k]==false) {
          dy*=-1;
          inside[j][k]=true;
          points++;
        }
        else if (dy2<=(dis2*sin(PI/4)) && dx2<=-(dis2*cos(PI/4)) && inside[j][k]==false) {
          dx*=-1;
          inside[j][k]=true;
          points++;
        }
        else if (dy2<=(dis2*sin(PI/4)) && dx2>=(dis2*cos(PI/4)) && inside[j][k]==false) {
          dx*=-1;
          inside[j][k]=true;
          points++;
        }
      }
    }

    // bounce ball at y position of mouse
    heightbounce=mousey;

    //Bar to bounce ball on
    float barsize=75.;
    strokeWeight(3);
    line(mousex-barsize, heightbounce, mousex+barsize, heightbounce);
    strokeWeight(1);

    // change direction if moving point hits boundaries
    if (x>=width || x<=0) {
      dx*=-1;
    }
    if (y<=0) {
      dy*=-1;
    }
    // change direction if moving point hits bar depending on where the point came from
    if (y>=heightbounce && y<heightbounce+10) {
      //left part - left left - get more horisontal
      if (x>(mousex-barsize) && x< (mousex-(1./3)*barsize) && dx>0 && dy>0) {
        dy*=-0.95;
        dx*=-1.05;
      }
      //left part - right left - get more horisontal
      else if (x>(mousex-barsize) && x< (mousex-(1./3)*barsize) && dx<0 && dy>0) {
        dy*=-0.95;
        dx*=1.05;
      }
      //right part - left right - get more horisontal
      else if (x>(mousex+(1./3)*barsize) && x< (mousex+barsize) && dx>0 && dy>0) {
        dy*=-0.95;
        dx*=1.05;
      }
      //right part - right right - get more horisontal
      else if (x>(mousex+(1./3)*barsize) && x< (mousex+barsize) && dx<0 && dy>0) {
        dy*=-0.95;
        dx*=-1.05;
      }
      //middle part - just bounce - get more vertical
      else if (x>(mousex-(1./3)*barsize) && x< (mousex+(1./3)*barsize) && dy>0) {
        dy*=-1.05;
        dx*=0.95;
      }
    }


    //Print points
    textAlign(RIGHT);
    fill(255);
    textSize(20);
    text(points, 550, 550);

    //GAME OVER
    if (y>height) {
      t=1;
      fill(255);
      textAlign(CENTER);
      text("GAME OVER", 300, 300);
      text("CLICK TO RESTART GAME", 300, 400);
      text("PRESS SPACE TO RESTART LEVEL", 300, 500);
    }

    //Finished
    if (checkinside()) {
      t=2;
      fill(255);
      textAlign(CENTER);
      text("FINISHED", 300, 300);
      text("CLICK FOR NEXT LEVEL", 300, 400);
    }

    // incrementing moving point
    x=x+dx;
    y=y+dy;

    count++;
  }
  // end of t=0

  // if game over
  else if (t==1) {

    x = 300;
    y = 300;
    dx = 3;
    dy = -5;
    count=0;
    points=0;
    if (mousePressed==true) {
      t=0;
      inside=new boolean[inside.length][inside[0].length];
    }
    if (keyPressed) {
      if (key == ' ') {
        t=0;
        inside=new boolean[1][11];
      }
    }
  }

  // if level compleated
  else {
    x = 300;
    y = 300;
    dx = 3;
    dy = -5;
    count=0;
    if (mousePressed==true) {
      t=0;
      inside=new boolean[inside.length+1][inside[0].length];
    }
  }
}


// Return true when all values are true - no false values left in array
boolean checkinside() {
  for (int j=0;j<inside.length;j++) {
    for (int k=0;k<inside[0].length;k++) {
      if (inside[j][k] == false) {
        return false;
      }
    }
  }
  return true;
}

//-----

import processing.serial.*;

Serial port;
char val;
String state;
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

boolean sketchFullScreen() {
  return true;
}

void setup()
{
  size(600, 600);
  smooth();

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
  if (v[mi2] == 0 || float(v[mi1]) / v[mi2] > 5.0) {
    r2 = "";
  }

  state = "";
  state += "x "+str(vals[0])+"\ny "+str(vals[1])+"\nz "+str(vals[2]);
  state += "\n\n"+r1+" " +r2;
  
  println(state);

  if (r2.equals("+z"))
    left();
  else if (r2.equals("-z"))
    right();
  else if (r2.equals("+y"))
    front();
  else if (r2.equals("-y"))
    back();
}

float single_step = 30;
void left() {
  mousex += single_step;
}

void right() {
  mousex -= single_step;
}

void front() {
  mousey += single_step;
}

void back() {
  mousey -= single_step;
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

