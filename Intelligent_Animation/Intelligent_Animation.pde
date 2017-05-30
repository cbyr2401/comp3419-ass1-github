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
PImage binaryImg;
PImage improvedImg;
PImage backgroundImg;

// Data Structures
ArrayList<PImage> imageParts;
Creature monster;
int framenumber = 0;

// Canvas Elements
PGraphics monsterCanvas;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  // the size of the window to be rendered.
  size(1280,720);  
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));
  
  // use only one PGraphics object throughout the whole execution to save memory
  monsterCanvas = createGraphics(GLOBAL_WIDTH, GLOBAL_HEIGHT);
  
  // load all the image files into a single array, these are then used to create the creature.
  imageParts = new ArrayList<PImage>(5);
  imageParts.add(loadImage("monster/lefthand.png"));
  imageParts.add(loadImage("monster/righthand.png"));
  imageParts.add(loadImage("monster/leftfoot.png"));
  imageParts.add(loadImage("monster/rightfoot.png"));
  imageParts.add(loadImage("monster/body.png"));
  
  // create the new creature / monster overlay
  monster = new Creature(imageParts);
  
  // load the background image
  //backgroundImg = loadImage("");
  
  // play the original movie file
  originalMovie.play();
  
}

// Processing Draw function.  This is run on a constant loop
//  and controls all drawing / output to the display.
void draw(){
  
  // clear the frame ready for next execution
  background(0); // clear

  // draw on the background image
  //image(backgroundImage, 0, 0);
  
  // draw the creature to the screen if there is an image avaiable.
  if ( improvedImg != null ) {
    drawCreature(improvedImg);
    image(monsterCanvas, 200, 200);
  }
  
  // draw the randomly generated objects
  
  
  // check collisions with the random objects
  
  

  // export the whole image frame
  //saveFrame("export/image-######.tif");
  
}


// Processing Movie Event function.  This is called every time a 
//  new frame is available to read for the playing movie.
void movieEvent(Movie m) {
  // read in the next movie frame
  m.read();
  
  // create and built all the images we need.
  binaryImg = segmentMarkers(m, true);
  improvedImg = correctAndEnhance(binaryImg);
  
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
    
    // safety check - check we have the point, otherwise add it.
    if ( !tl ) points.add(new PVector(minimumx+25, minimumy+25));
    
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
    
    // safety check - check we have the point, otherwise add it.
    if ( !tr ) points.add(new PVector(maximumx-25, minimumy+25));
    
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
    
    // safety check - check we have the point, otherwise add it.
    if ( !bl ) points.add(new PVector(minimumx+25, maximumy-25));
    
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
    
    // safety check - check we have the point, otherwise add it.
    if ( !br ) points.add(new PVector(maximumx-25, maximumy-25));    
    
    // calculate the centre point
    points.add(new PVector((minimumx + maximumx) / 2, (minimumy+maximumy) / 2));
  
    return points;
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