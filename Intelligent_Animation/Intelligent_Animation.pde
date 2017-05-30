//  COMP3419 Major Assessment - Intelligent Animation
//
//  @author: wallarug
//  @created: 17/05/2017 22:11 PM
//  @modified: 30/05/2017 21:41 PM

// IMPORTS
import processing.video.*;
import processing.sound.*;

// FIXED DIMENTIONS - bad practice
int GLOBAL_WIDTH = 568;
int GLOBAL_HEIGHT = 320;

// GLOBAL VARIABLES
// Movie Files
Movie originalMovie;

// Sound Files

// Image Files
PImage segmentedImg;
PImage binaryImg;
PImage improvedImg;

// Data Structures
ArrayList<PImage> imageParts;
Creature monster;
int framenumber = 0;

// Canvas Elements
PGraphics boxes;
PGraphics monsterCanvas;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  size(1704,640);  // the size of the window to be rendered.
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));
  
  // use only one PGraphics object throughout the whole execution to save memory
  boxes = createGraphics(GLOBAL_WIDTH, GLOBAL_HEIGHT);
  monsterCanvas = createGraphics(GLOBAL_WIDTH, GLOBAL_HEIGHT);
  
  // load all the image files into a single array, these are then used to create the creature.
  imageParts = new ArrayList<PImage>(5);
  imageParts.add(loadImage("monster/lefthand.png"));
  imageParts.add(loadImage("monster/righthand.png"));
  imageParts.add(loadImage("monster/leftfoot.png"));
  imageParts.add(loadImage("monster/rightfoot.png"));
  imageParts.add(loadImage("monster/body.png"));
  
  monster = new Creature(imageParts);
  
  // play the original movie file
  originalMovie.play();
  //originalMovie.loop();
  
}

// Processing Draw function.  This is run on a constant loop
//  and controls all drawing / output to the display.
void draw(){
  
  // some debug text
  textSize(18);
  fill(255,0,0);
  background(0); // clear
  
  // TOP LEFT (1): draw the original movie
  image(originalMovie, 0, 0);
  text("Original Movie File", 234, 300);
  
  // TOP CENTER (2): draw the segmented movie
  if ( segmentedImg != null ) {
    image(segmentedImg, 568, 0);
    text("Segmented Image", 568+234, 300);
  }
  
  // TOP RIGHT (3): draw the binary image
  if ( binaryImg != null ) {
    image(binaryImg, 1136, 0);
    text("Binary Image", 1136+234, 300);
  }
  
  // BOTTOM LEFT (4): draw the improved binary image
  if ( improvedImg != null ) {  
    image(improvedImg, 0, 320);
    text("Improved Binary Image", 234, 320+300);
  }
  
  // BOTTOM CENTER (5): draw the boxes
    if ( improvedImg != null ) {
    //drawBlobs(improvedImg);
    drawPoints(improvedImg);
    image(boxes, 568, 320);
    text("Points", 568+234, 320+300);
  }
  
  // BOTTOM RIGHT (6): draw the dots
  if ( improvedImg != null ) {
    //drawDots(improvedImg);
    drawCreature(improvedImg);
    image(monsterCanvas, 1136, 320);
    //image(dots, 0, 0);
    text("Monster Canvas Image", 1136+234, 320+300);
  }

  // export the whole image frame
  //saveFrame("export/image-######.tif");
  
}


// Processing Movie Event function.  This is called every time a 
//  new frame is available to read for the playing movie.
void movieEvent(Movie m) {
  m.read();
  
  segmentedImg = segmentMarkers(m, false);
  //segmentedImg = segmentMonkey(m, false);
  binaryImg = segmentMarkers(m, true);
  //binaryImg = segmentMonkey(m, true);
  improvedImg = correctAndEnhance(binaryImg);
  //boxes = drawBlobs(improvedImg);
  
  // save the frame
  //segmentedImg.save(sketchPath("") + "seg/image" + nf(framenumber, 4) + ".tif");
  framenumber++;
}


// FUNCTIONS FOR SEGEMENTING MOTION
// Segements the red markers from the image and returns as a PImage
// @param: PImage video frame, produce binary image
// @return: PImage segmented frame
PImage segmentMarkers(PImage video, boolean bin_image)
{
  // variables to control the placement within the new background
  //  this is required if your canvas is a different size to the
  //  original video.
  int adjust_width = 0;
  int adjust_height = 0;
  
  // create a blank image to place the segment on
  PImage blank = new PImage(video.width, video.height);
  
  // Remove all the pixels that do not contain high enough levels of 
  //  red.  The thresholds have been found by experimentation:
  boolean takeColor = false;
  boolean ignoreFilter1 = true;
  boolean ignoreFilter2 = true;
  
  // go through all the pixels of the monkey frame.
  for(int x = 0; x < video.width; x++){
    for(int y = 0; y < video.height; y++){
      // work out the current pixel location in the matrix
      //  and get the color at that pixel.
      int mloc = x + y * video.width;
      color c = video.pixels[mloc];
      takeColor = red(c) > 149 
                  && green(c) > 37 
                  && green(c) < 199 
                  && blue(c) > 39
                  && blue(c) < 125;
      // face chromes
      ignoreFilter1 = red(c) > 190 
                  && red(c) < 254
                  && green(c) > 132
                  && green(c) < 199
                  && blue(c) > 44
                  && blue(c) < 125;
      // browns
      ignoreFilter2 = red(c) > 148 
                  && red(c) < 201
                  && green(c) > 83
                  && green(c) < 166
                  && blue(c) > 39
                  && blue(c) < 116;
                 
      // if the pixel correct has color, calculate the new location 
      if( takeColor && !ignoreFilter1 && !ignoreFilter2){
        int bgx = constrain(x + adjust_width, 0, blank.width);
        int bgy = constrain(y + adjust_height, 0, blank.height);
        int bgloc = bgx + bgy * blank.width;
        if ( bin_image == true ){
          blank.pixels[bgloc] = color(255,255,255);
        }
        else {
          blank.pixels[bgloc] = c;
        }
      }
    }
  }
  // return the new canvas with the segmented image on it
  return blank;
}



// Improves the segemented image by removing artifacts
// @param: PImage binary image
// @return: PImage improveed frame
PImage correctAndEnhance(PImage bin){
  PImage improvement = new PImage(bin.width, bin.height);
  
  // first erode all the small bits
  improvement = im_erosion(bin);  
  for ( int i = 0; i < 1; i++) improvement = im_erosion(improvement);
  
  // dilate image many times
  for ( int i = 0; i < 7; i++) improvement = im_dilation(improvement);

  return improvement;
}


// Uses the QUAD Method for getting the points.
// @param: enhanced binary image
// @return: PGraphic with blobs on it
ArrayList<PVector> findPoints(PImage bin){
    ArrayList<PVector> points = new ArrayList<PVector>(5);
    
    // search the binary image for the four corners of the quad.
    //  Then we can calculate the center.
    int maximumx = 0;
    int maximumy = 0;
    int minimumx = 999;
    int minimumy = 999;
    
    color white = color(255,255,255);
    int jump = 1;

    for ( int x = 0; x < bin.width; x += jump ){
      for ( int y = 0; y < bin.height; y += jump ){
        int loc = x + y * bin.width;
        color c = bin.pixels[loc];
        // if pixel is white:
        if ( c == white) {
           if ( x > maximumx ) maximumx = x;
           else if ( x < minimumx ) minimumx = x;
           
           if ( y > maximumy ) maximumy = y;
           else if (y < minimumy ) minimumy = y;
        }
      }
    }
    
    // Only search the quadrant where we expect to find the point.  This
    //  is to prevent us from accidently picking up a different point or
    //  the centre point.
    int quadrantx = (minimumx + maximumx) / 2;
    int quadranty = (minimumy + maximumy) / 2;
    int quadrant_threshold = 15;
    
    // these are here for later on.
    boolean tl = false;
    boolean tr = false;
    boolean bl = false;
    boolean br = false;

    // find the points individually. (top left)
    TLLoop:
    for ( int x = minimumx; x < quadrantx - quadrant_threshold; x += jump ){ //maximumx - searcharea_x
      for ( int y = minimumy; y < quadranty - quadrant_threshold; y += jump ){ //maximumy - searcharea_y
        int loc = x + y * bin.width;
        color c = bin.pixels[loc];
        // if pixel is white:
        if ( c == white) {
           points.add(new PVector(x, y));
           tl = true;
           break TLLoop;
        }
      }
    }
    
    
    // find the points individually (top right)
    TRLoop:
    for ( int x = maximumx; x > quadrantx + quadrant_threshold; x -= jump ){ //minimumx + searcharea_x
      for ( int y = minimumy; y < quadranty - quadrant_threshold; y += jump ){ //maximumy - searcharea_y
        int loc = x + y * bin.width;
        color c = bin.pixels[loc];
        // if pixel is white:
        if ( c == white) { 
           points.add(new PVector(x, y));
           tr = true;
           break TRLoop;
        }
      }
    }
    
    // find the points individually (bottom left)
    BLLoop:
    for ( int x = minimumx; x < quadrantx - quadrant_threshold; x += jump ){ //maximumx - searcharea_x
      for ( int y = maximumy; y > quadranty + quadrant_threshold; y -= jump ){ //minimumy + searcharea_y
        int loc = x + y * bin.width;
        color c = bin.pixels[loc];
        // if pixel is white:
        if ( c == white) {
           points.add(new PVector(x, y));
           bl = true;
           break BLLoop;
        }
      }
    }
    
    // find the points individually (bottom right)
    BRLoop:
    for ( int x = maximumx; x > quadrantx + quadrant_threshold; x -= jump ){ // minimumx + searcharea_x
      for ( int y = maximumy; y > quadranty + quadrant_threshold; y -= jump ){ //minimumy + searcharea_y
        int loc = x + y * bin.width;
        color c = bin.pixels[loc];
        // if pixel is white:
        if ( c == white) { 
           points.add(new PVector(x, y));
           br = true;
           break BRLoop;
        }
      }
    }
    
    // safety check - check we have all the points
    if ( !tl ) points.add(new PVector(minimumx+25, minimumy+25));
    if ( !tr ) points.add(new PVector(maximumx-25, minimumy+25));
    if ( !bl ) points.add(new PVector(minimumx+25, maximumy-25));
    if ( !br ) points.add(new PVector(maximumx-25, maximumy-25));
    
    // compute points - old method without finding the actual points.  Produces
    //  a very large box and only shows small movements
    //points.add(new PVector(minimumx, minimumy));
    //points.add(new PVector(maximumx, minimumy));
    //points.add(new PVector(minimumx, maximumy));
    //points.add(new PVector(maximumx, maximumy));
    points.add(new PVector((minimumx + maximumx) / 2, (minimumy+maximumy) / 2));
  
    return points;
}



// Draws the points onto the "boxes" PGraphic
// @param: enhanced binary image
// @return: PGraphic with blobs on it
void drawPoints(PImage bin){   
   // get the points
   ArrayList<PVector> pints = findPoints(bin);  

   // set up the field.
   boxes.beginDraw();
   boxes.clear();
   boxes.background(0);
   boxes.fill(255,0,0);
   
   // go through all the blobs and draw them to the PGraphic
   for ( PVector p : pints ) boxes.ellipse(p.x, p.y, 15, 15);

   // close the object
   boxes.endDraw();
   
   // **DEBUG ONLY:
   //println("points: ", pints.size());
}

 //<>//
// FUNCTIONS FOR GENERATING MOVIE OBJECTS

// Draws the creature to the display.
// @param: ArrayList of Vectors
// @return: create onto image
void drawCreature(PImage img){ 
  // find points
  ArrayList<PVector> vectors = findPoints(img);
  
  // update monster
  monster.update(vectors);
  
  // render the monster
  monster.render(monsterCanvas);
}