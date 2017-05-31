//
// Custom Drawing library written for COMP3419
// @author: Cian Byrne
// @modified: 31/05/2017
//

PGraphics makeBus(String brand){
  PGraphics bus = createGraphics(150, 80);
  
  bus.beginDraw();
  
  // main body
  bus.rectMode(CORNERS);
  bus.stroke(0);
  
  if ( brand == "Sydney" )
  {
    // blue bit
    bus.fill(27, 114, 211);
    bus.rect(10, 50, 140, 65);
    // white bit
    bus.fill(255,255,255);
    bus.rect(10, 10, 140, 50);
  }
  else if ( brand == "Forest" )
  {
    // white bit
    bus.fill(255,255,255);
    bus.rect(10, 50, 140, 65);
    bus.rect(10, 10, 140, 50);
    // lines
    bus.stroke(0,127,0);
    bus.strokeWeight(3);
    bus.line(12, 15, 135, 15);
    bus.line(12, 45, 90, 45);
    bus.line(90, 45, 85, 63);
    bus.strokeWeight(1);
    bus.stroke(0);
  }
  else if ( brand == "Hills" )
  {
     // yellow bit
    bus.fill(240,255,0);
    bus.rect(10, 10, 140, 65);
  }
  else if ( brand == "Metro" )
  {
    // yellow bit
    bus.fill(255,0,0);
    bus.rect(10, 10, 140, 65); 
  }
  
  // wheels
  bus.fill(25,25,25);
  bus.ellipse(40, 65, 20, 20);
  bus.ellipse(120, 65, 20, 20);
  
  bus.fill(200,200,200);
  bus.ellipse(40, 65, 12, 12);
  bus.ellipse(120, 65, 12, 12);
  
  bus.fill(170,170,170);
  bus.ellipse(40, 65, 8, 8);
  bus.ellipse(120, 65, 8, 8);
  
  // windows
  bus.rectMode(CORNER);
  bus.fill(127,127,127);
  bus.rect(15, 18, 20, 21);
  bus.rect(40, 18, 20, 21);
  bus.rect(65, 18, 20, 21);
  bus.rect(90, 18, 20, 21);
  bus.rect(115, 15, 25, 30);
  
  // head light
  bus.fill(255,255,0);
  bus.ellipse(135, 50, 7, 7);
  bus.strokeWeight(7);
  bus.stroke(255,255,0);
  bus.line(145, 50, 150, 50);
  bus.strokeWeight(1);
  bus.stroke(0);
  bus.fill(255,69,0);
  bus.ellipse(137, 57, 5, 5);
  
  bus.endDraw();
  
  return bus; 
}


PGraphics makeSydneyTrain(int numcars){  
  int startx = 15;
  int starty = 10;
  int wide = 200;
  int high = 60;
  
  PGraphics train = createGraphics((numcars*wide)+30, 80);
  
  train.beginDraw();
  
  for (int i = 1; i < numcars + 1; i++)
  {
    if ( i % numcars == 0 )
    {
      drawCarraigeTrain(train, startx, starty, wide, high, 99);
      break;
    }
    else
    {
      drawCarraigeTrain(train, startx, starty, wide, high, i);
      startx += wide;
    }
  }

  // END SINGLE CARRAIGE
  
  train.endDraw();
  
  return train; 
}

void drawCarraigeTrain(PGraphics train, int startx, int starty, int wide, int high, int carnumber){
  color windowtint = color(50,50,50);
  
  // SINGLE MIDDLE CARRIAGE
  // wheels  
  train.fill(0,0,0);
  train.ellipse(startx+10, starty+high, 10, 10);
  train.ellipse(startx+20, starty+high, 10, 10);
  train.ellipse(startx+30, starty+high, 10, 10);
  
  train.ellipse(startx+wide-10, starty+high, 10, 10);
  train.ellipse(startx+wide-20, starty+high, 10, 10);
  train.ellipse(startx+wide-30, starty+high, 10, 10);
  
  // main body
  train.rectMode(CORNERS);
  train.stroke(0);
  // grey bit
  train.fill(127,127,127);
  train.rect(startx, starty, startx+wide, starty+high);
  
  // draw on the guard compartment
  if( carnumber == 1 ){
    // front bit
    train.fill(255,165,0);
    train.noStroke();
    train.rect(startx+10, starty, startx-2, starty+high);
    train.triangle(startx-2, starty, startx-2, starty+high, startx-15, starty+high);
    train.fill(windowtint);
    train.triangle(startx+5, starty+10, startx+5, starty+high-25, startx-5, starty+high-25);
  }
  else if ( carnumber == 8 || carnumber == 99 ){
    // front bit
    train.fill(255,165,0);
    train.noStroke();
    train.rect(startx+wide-10, starty, startx+wide+2, starty+high);
    train.triangle(startx+wide+2, starty, startx+wide+2, starty+high, startx+wide+15, starty+high);
    train.fill(windowtint);
    train.triangle(startx+wide-5, starty+10, startx+wide-5, starty+high-25, startx+wide+5, starty+high-25);
  }
  
  // lines
  train.stroke(255,165,0);
  train.strokeWeight(2);
  train.line(startx+2, starty+high-2, startx+wide-2, starty+high-2);
  train.strokeWeight(1);
  train.stroke(0);
  
  // doors
  train.rectMode(CORNERS);
  train.fill(255,255,0);
  train.rect(startx+15, starty+15, startx+45, starty+high-12);
  train.rect(startx+wide-15, starty+15, startx+wide-45, starty+high-12);
  train.fill(windowtint);
  train.rect(startx+20, starty+20, startx+28, starty+high-17);
  train.rect(startx+32, starty+20, startx+40, starty+high-17);
  train.rect(startx+wide-20, starty+20, startx+wide-28, starty+high-17);
  train.rect(startx+wide-32, starty+20, startx+wide-40, starty+high-17);
  
  // windows
  train.rectMode(CORNERS);
  train.fill(windowtint);
  train.rect(startx+50, starty+12, startx+wide-50, starty+30);
  train.rect(startx+50, starty+35, startx+wide-50, starty+52);
  
  // joiner
  train.fill(200,200,200);
  if( carnumber != 1 ) train.rect(startx, starty+10, startx+5, starty+high-10);
  if ( carnumber != 8 && carnumber != 99 ) train.rect(startx+wide-5, starty+10, startx+wide, starty+high-10);

}


// Light Rail
PGraphics makeSydneyLightRail(int numcars){  
  int startx = 15;
  int starty = 10;
  int wide = 150;
  int high = 50;
  
  PGraphics train = createGraphics((numcars*wide)+30, 80);
  
  train.beginDraw();
  
  for (int i = 1; i < numcars + 1; i++)
  {
    if ( i % numcars == 0 )
    {
      drawCarraigeLR(train, startx, starty, wide, high, 99);
      break;
    }
    else
    {
      drawCarraigeLR(train, startx, starty, wide, high, i);
      startx += wide;
    }
  }

  // END SINGLE CARRAIGE
  
  train.endDraw();
  
  return train; 
}

void drawCarraigeLR(PGraphics train, int startx, int starty, int wide, int high, int carnumber){
  color windowtint = color(50,50,50);
  
  // SINGLE MIDDLE CARRIAGE
  // wheels  
  train.fill(0,0,0);
  train.ellipse(startx+10, starty+high, 10, 10);
  train.ellipse(startx+20, starty+high, 10, 10);
  
  train.ellipse(startx+wide-10, starty+high, 10, 10);
  train.ellipse(startx+wide-20, starty+high, 10, 10);
  
  // main body
  train.rectMode(CORNERS);
  train.stroke(0);
  // grey bit
  train.fill(255,50,50);
  train.rect(startx, starty, startx+wide, starty+high);
  
  // draw on the guard compartment
  if( carnumber == 1 ){
    // front bit
    train.fill(255,50,50);
    train.noStroke();
    train.rect(startx+10, starty, startx-2, starty+high);
    train.triangle(startx-2, starty, startx-2, starty+high, startx-15, starty+high);
    train.fill(windowtint);
    train.triangle(startx+5, starty+10, startx+5, starty+high-25, startx-5, starty+high-25);
    train.stroke(1);
  }
  else if ( carnumber == 8 || carnumber == 99 ){
    // front bit
    train.fill(255,50,50);
    train.noStroke();
    train.rect(startx+wide-10, starty, startx+wide+2, starty+high);
    train.triangle(startx+wide+2, starty, startx+wide+2, starty+high, startx+wide+15, starty+high);
    train.fill(windowtint);
    train.triangle(startx+wide-5, starty+10, startx+wide-5, starty+high-25, startx+wide+5, starty+high-25);
    train.stroke(1);
  }
  
  // doors
  train.rectMode(CORNERS);
  train.fill(255,100,100);
  train.rect(startx+15, starty+15, startx+45, starty+high-12);
  train.rect(startx+wide-15, starty+15, startx+wide-45, starty+high-12);
  train.fill(windowtint);
  train.rect(startx+20, starty+20, startx+28, starty+high-17);
  train.rect(startx+32, starty+20, startx+40, starty+high-17);
  train.rect(startx+wide-20, starty+20, startx+wide-28, starty+high-17);
  train.rect(startx+wide-32, starty+20, startx+wide-40, starty+high-17);
  
  // windows
  train.rectMode(CORNERS);
  train.fill(windowtint);
  train.rect(startx+50, starty+12, startx+wide-50, starty+40);
  
  // joiner
  train.fill(200,200,200);
  if( carnumber != 1 ) train.rect(startx, starty+10, startx+5, starty+high-10);
  if ( carnumber != 8 && carnumber != 99 ) train.rect(startx+wide-5, starty+10, startx+wide, starty+high-10);

}