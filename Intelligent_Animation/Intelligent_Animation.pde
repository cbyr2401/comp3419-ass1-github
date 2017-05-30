//  COMP3419 Major Assessment - Intelligent Animation
//
//  @author: wallarug
//  @created: 17/05/2017 22:11 PM
//  @modified: 26/05/2017 00:41 AM

// IMPORTS
import processing.video.*;
import processing.sound.*;

// FIXED DIMENTIONS - bad practice
int GLOBAL_WIDTH = 568;
int GLOBAL_HEIGHT = 320;

// GLOBAL VARIABLES
Movie originalMovie;
PImage segmentedImg;
PImage binaryImg;
PImage improvedImg;
ArrayList<PImage> imageParts;
PGraphics boxes;
PGraphics dots;
ArrayList<Blob> xyz;
int framenumber = 0;
int BLOCKSIZE = 13;
Creature monster;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  size(1704,640);  // the size of the window to be rendered.
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));
  
  // use only one PGraphics object throughout the whole execution to save memory
  boxes = createGraphics(GLOBAL_WIDTH, GLOBAL_HEIGHT);
  dots = createGraphics(GLOBAL_WIDTH, GLOBAL_HEIGHT);
  
  imageParts = new ArrayList<PImage>(5);
  imageParts.add(loadImage("monster/lefthand.png"));
  imageParts.add(loadImage("monster/righthand.png"));
  imageParts.add(loadImage("monster/leftfoot.png"));
  imageParts.add(loadImage("monster/rightfoot.png"));
  imageParts.add(loadImage("monster/body.png"));
  
  monster = new Creature();
  
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
    drawBlobs(improvedImg);
    image(boxes, 568, 320);
    text("Displacement boxes", 568+234, 320+300);
  }
  
  // BOTTOM RIGHT (6): draw the dots
  if ( improvedImg != null ) {
    drawDots(improvedImg);
    image(dots, 1136, 320);
    //image(dots, 0, 0);
    text("Dots Image", 1136+234, 320+300);
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


// Uses the Quad Method for getting the points.
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
    
    // compute points
    points.add(new PVector(minimumx, minimumy));
    points.add(new PVector(maximumx, minimumy));
    points.add(new PVector(minimumx, maximumy));
    points.add(new PVector(maximumx, maximumy));
    points.add(new PVector((minimumx + maximumx) / 2, (minimumy+maximumy) / 2));
  
    return points;
}


// Draws the blobs
// @param: enhanced binary image
// @return: PGraphic with blobs on it
void drawBlobs(PImage bin){
   // set up a new PGraphic for temporarily dumping the blobs on.
   //PGraphics field;
   //field = createGraphics(bin.width, bin.height);
   
   // get the blobs
   ArrayList<Blob> blbs = findBlobs(bin);  

   // set up the field.
   boxes.beginDraw();
   boxes.clear();
   boxes.background(0);
   boxes.fill(255,0,0);
   
   // set the method that Processing needs to use for drawing the objects.
   boxes.rectMode(CORNERS);
   
   // go through all the blobs and draw them to the PGraphic
   for ( Blob b : blbs ) boxes.rect(b.minx, b.maxy, b.maxx, b.miny);

   // close the object
   boxes.endDraw();
   
   // Return PGraphic object.
   //return field;
}

// Determines where the location is.
// @param: enhanced binary image
// @return: PGraphic with blobs on it
void drawDots(PImage bin){
   // set up a new PGraphic for temporarily dumping the blobs on.
   //PGraphics field;
   //field = createGraphics(bin.width, bin.height);
   
   // get the blobs
   ArrayList<Blob> blbs = findBlobs(bin);  

   // set up the field.
   dots.beginDraw();
   dots.clear();
   dots.background(0);
   dots.fill(255,0,0);
   
   // go through all the blobs and draw them to the PGraphic
   for ( Blob b : blbs ) dots.ellipse(b.cx(), b.cy(), 10, 10);
    
   // close the object
   dots.endDraw();
   
   //drawCreature(blbs);
   
   println("dots: " + blbs.size() );
   
   // Return PGraphic object.
   //return field;
} //<>//

// Determines where the location is.
// @param: PImage enhanced binary
// @return: ArrayList of blobs
ArrayList findBlobs(PImage bin){
   ArrayList<Blob> blobs = new ArrayList<Blob>(5);
   
   color white = color(255,255,255);  // convience.
   int threshold = 5;  // number of pixels to be within a blob
   int jump = 1;    // number of pixels to skip, looking at all of them will take a while.
   
   boolean inBlob = false;
   
   // go through all the pixels in the binary image and decide where which
   //  'blob' it should belong to.
   for ( int y = 0; y < bin.height; y += jump ) 
   {
     for ( int x = 0; x < bin.width; x += jump )  
     {      
       // reset variables for each round.
       inBlob = false;
       
       // check if the pixel is white, otherwise ignore
       if ( bin.pixels[x + bin.width * y] == white ) 
       {
         // search all the blobs to determine if this point is within an
         //  existing blob.  Modify according to "Threshold Check".
         for ( Blob b : blobs ) 
         {
           if (inBlob) { break; }  
             //   ~ Threshold Check ~
             //  1) x inside larger square
             //  2) y inside larger square
             //  3) x not inside smaller square
             //    i) expand direction
             //   ii) modify blob
             //  4) y not inside smaller square
             //    i) expand direction
             //   ii) modify blob
             
             if ( checkXTh(b, x, threshold) ) 
             {
               // if the "x" coordinate is within the threshold, then we need to check
               //  that the "Y" coordinate is also in it's bounds.  Otherwise
               //  we cannot include the point.
               if ( checkYTh(b, y, threshold) ) 
               {
                 
                 // okey, this is where it gets tricky... we now know that this point
                 //  is within the "THRESHOLD BLOCK", but which way are we going to be expanding?
                 if ( !checkX(b, x) ) 
                 {
                   // we need to work out which way on "x" we are expanding. 
                   if ( x < b.minx ) b.minx = x;
                   else if ( x > b.maxx ) b.maxx = x;
                 }

                 if ( !checkY(b, y) ) 
                 {
                   // we need to work out which way on "y" we are expanding.
                   if ( y < b.miny ) b.miny = y;
                   else if ( y > b.maxy ) b.maxy = y;
                 }
                 
                 // break out, there is no need to check any of the other blobs
                 inBlob = true;
                 break;
                    
               } // END IF checkYTh()
               else
               {
                 // failed, outside of y threshold square - check next blob
                 // if it is not within the threshold, this point cannot be included.
                 continue;
               }
               
             } // END IF checkXTh()
             else 
             {
               // failed, outside of x threshold square - check next blob
               // if it is not within the threshold, this point is not 
               //  going to be included on the y axis either.
               //  disregard it and move on.
               continue;
             } // END X-MAIN
         } // END FOR BLOBS
         
         // IF the pixel is not in a pixel because it is outside the threshold or something,
         //  then we need to add it to a new blob.
         if ( !inBlob ) { 
           blobs.add( new Blob(x,y) );
         }
           
       } // END IF-WHITE
     } // END FOR-Y
   } // END FOR-X
   
   // check that none of the blobs overlap, this could cause problems later.
   checkBlobs(blobs);
   
   // return the blobs
   return blobs;
} // END FUNCTION //<>//


// Checks if any generated blobs overlap and removes them.
// @param: ArrayList of blobs
// @return: void
void checkBlobs(ArrayList<Blob> list){
  // create temporary data store for items to remove.
  ArrayList<Blob> removal = new ArrayList<Blob>();
  
  // near distance
  int NEAR = 20;
  
  // go through all elements twice, checking if there is an overlap.
  for ( Blob a : list ){
    for ( Blob b : list ){
      if (a == b )
      {
        // do not check same elements
      }
      else if ( removal.contains(a) || removal.contains(b) )
      {
        // do not check elements already due for deletion
      }
      else 
      {
          // check for overlaps, add to removal set if 
          //  there is an overlap.
          if ( a.isInside(b) ) removal.add(b);
          else if ( a.isNear(b, NEAR) ) removal.add(b);
      }
    }
  }
  
  // remove all items from removal set.
  if(removal.size() > 0) list.removeAll(removal);
}


//
// Blob checkers
//
// Returns if the point lies within the x boundaries
// @param: Blob object, int coordinate
// @return: boolean
boolean checkX(Blob b, int x){
   // now refine it to just inside the blob
   if ( x >= b.minx && x <= b.maxx ) {
     // inside blob, no action required
     return true;
   }
   return false;
}

// Returns if the point lies within the x threshold boundaries
// @param: Blob object, int coordinate
// @return: boolean
boolean checkXTh(Blob b, int x, int threshold){
   // if the "x" coordinate is in between the blobs extremities, then 
   //  we need to either, expand the blob or say everything is ok.
   // this statement checks if it is within the threshold as well.
   if ( x >= b.minx - threshold && x <= b.maxx + threshold ){
     return true;
   }
   return false; 
}

// Returns if the point lies within the y boundaries
// @param: Blob object, int coordinate
// @return: boolean
boolean checkY(Blob b, int y){
   // now refine it to just inside the blob
   if ( y >= b.miny && y <= b.maxy ) {
     // inside blob, no action required
     return true;
   }
   return false;
}

// Returns if the point lies within the y threshold boundaries
// @param: Blob object, int coordinate
// @return: boolean
boolean checkYTh(Blob b, int y, int threshold){
   // if the "y" coordinate is in between the blobs extremities, then 
   //  we need to either, expand the blob or say everything is ok.
   // this statement checks if it is within the threshold as well.
   if ( y >= b.miny - threshold && y <= b.maxy + threshold ){
     return true;
   }
   return false; 
}


public class Blob {
    public int minx;
    public int maxy;
    public int maxx;
    public int miny;
    
    public Blob(int tx, int ty){
        minx = tx;
        maxy = ty;
        maxx = tx+5;
        miny = ty-5;
    }
    
    // Returns a string with details about the Blob
    public String display(){
      return "Blob: (" + minx + "," + maxy + ") (" + maxx + "," + miny + ")";
    }
    
    // Returns if the given blob is inside this.
    public boolean isInside(Blob b){
        if(b.maxx <= maxx && b.maxx >= minx &&
           b.minx <= maxx && b.minx >= minx &&
           b.maxy <= maxy && b.maxy >= miny &&
           b.miny <= maxy && b.miny >= miny) return true;
        else return false;
    }
    
    // Returns if the given blob is distance near
    public boolean isNear(Blob b, int df){
       int clocx = (minx + maxx)/2;
       int clocy = (miny + maxy)/2;
       
       int clocbx = (b.minx + b.maxx)/2;
       int clocby = (b.miny + b.maxy)/2;
       
       if ( dist(clocx, clocy, clocbx, clocby) < df) return true;

       return false;
    }
    
    // Returns centre x-coordinate
    public int cx(){
       return (int) ((minx + maxx)/2); 
    }
    
    // Returns centre x-coordinate
    public int cy(){
       return (int) ((miny + maxy)/2); 
    }
}

// FUNCTIONS FOR GENERATING MOVIE OBJECTS

// Draws the creature to the display.

void drawCreature(ArrayList<Blob> blobs){
  int arrlen = blobs.size();
  Blob top_left = null;
  Blob top_right = null;
  Blob centre = null;
  Blob bot_left = null;
  Blob bot_right = null;
  ArrayList<Blob> sorted = new ArrayList<Blob>(5);  // temp array
    
  // ONLY RUN IF WE HAVE THE RIGHT NUMBER OF DOTS, OTHERWISE, DRAW PREVIOUS
  if ( arrlen == 5 ) {
    // find the points for the top. (minimising y)
    int targetx = 999;
    int targety = 999;
    
    // find top left.
    targetx = 999;
    targety = 999;
    for ( Blob b : blobs ){
        if (b.miny < targety && b.minx < targetx) {
          targety = b.cy();
          targetx = b.cx();
          top_left = b;
        }
    }
    
    blobs.remove(top_left);
    
    // find top right
    targetx = 0;
    targety = 999;
    for ( Blob b : blobs ){
        if (b.cy() < targety && b.cx() > targetx) {
          targety = b.cy();
          targetx = b.cx();
          top_right = b;
        }
    }
    
    blobs.remove(top_right);
    
    // find bottom left
    targetx = 999;
    targety = 0;
    for ( Blob b : blobs ){
        if (b.cy() > targety && b.cx() < targetx) {
          targety = b.cy();
          targetx = b.cx();
          bot_left = b;
        }
    } 
    
    blobs.remove(bot_left);
    
    // find bottom right
    targetx = 0;
    targety = 0;
    for ( Blob b : blobs ){
        if (b.cy() > targety && b.cx() > targetx) {
          targety = b.cy();
          targetx = b.cx();
          bot_right = b;
        }
    }
    
    blobs.remove(bot_right);
    
    // find centre - the cheat method.
    for ( Blob b : blobs ){
        if ( ( b == top_left ||
             b == top_right ||
             b == bot_left ||
             b == bot_right ) && 
             arrlen > 4 ){}
        else {
          centre = b;
          break;
        }       
    }
    
    // determine which parts are missing.
    // compinsate for missing points by using the previous values (done in class)
    // add all to the array list to update the creature
  }

  if ( arrlen < 5 ) {
    // find the points for the top. (minimising y)
    int targetx = 999;
    int targety = 999;
    
    // find top left.
    targetx = 999;
    targety = 999;
    for ( Blob b : blobs ){
        if (b.miny < targety && b.minx < targetx) {
          targety = b.cy();
          targetx = b.cx();
          top_left = b;
        }
    }
    
    blobs.remove(top_left);
    
    // find top right
    targetx = 0;
    targety = 999;
    for ( Blob b : blobs ){
        if (b.cy() < targety && b.cx() > targetx) {
          targety = b.cy();
          targetx = b.cx();
          top_right = b;
        }
    }
    
    blobs.remove(top_right);
    
    
    // determine which parts are missing.
    // compinsate for missing points by using the previous values (done in class)
    // add all to the array list to update the creature
  }  
  
  // find the correct parts based on dot position
  sorted.add(top_left);
  sorted.add(top_right);
  sorted.add(bot_left);
  sorted.add(bot_right);
  sorted.add(centre);
  
  // update monster
  monster.update(sorted);
  
  // render the monster
  monster.render();
  
    
}


// NEW CLASS FOR CREATURE
public class Creature{
    BodyPart top_left = null;
    BodyPart top_right = null;
    BodyPart bot_left = null;
    BodyPart bot_right = null;
    BodyPart centre = null;
    
    public Creature() {
      top_left = new BodyPart(imageParts.get(0));
      top_right = new BodyPart(imageParts.get(1));
      bot_left = new BodyPart(imageParts.get(2));
      bot_right = new BodyPart(imageParts.get(3));
      centre = new BodyPart(imageParts.get(4));  
      
      top_left.setSize(30,30);
      top_right.setSize(30,30);
      bot_left.setSize(30,30);
      bot_right.setSize(30,30);
      centre.setSize(60,120);
      
      //top_left = new BodyPart();
      //top_right = new BodyPart();
      //bot_left = new BodyPart();
      //bot_right = new BodyPart();
      //centre = new BodyPart();  
    }
    
    public void update(ArrayList<Blob> list){
       // order: top left, top right, bot left, bot right, centre
       if ( list.get(0) != null ){
         top_left.setPosition(list.get(0).cx(), list.get(0).cy());
       }
       
       if ( list.get(1) != null ){
         top_right.setPosition(list.get(1).cx(), list.get(1).cy());
       }
       
       if ( list.get(2) != null ){
         bot_left.setPosition(list.get(2).cx(), list.get(2).cy());
       }
       
       if ( list.get(3) != null ){
         bot_right.setPosition(list.get(3).cx(), list.get(3).cy());
       }
       
       if ( list.get(4) != null ){
         centre.setPosition(list.get(4).cx(), list.get(4).cy());
       }
    }
    
    public void render(){
      //top_left.renderHand(centre);
      //top_right.renderHand(centre);
      //bot_left.renderHand(centre);
      //bot_right.renderHand(centre);
      //centre.renderBody();
      
      bot_left.render();
      bot_right.render();
      top_left.render();
      top_right.render();
      centre.render();
      
      // extra parts
      
    }
  
  
}


public class BodyPart{
   int xcoord = 200;
   int ycoord = 200;
   PImage texture = null;
   int m_height;
   int m_width;
   
   public BodyPart(PImage texturePath){
      texture = texturePath;
      m_height = texture.height;
      m_width = texture.width;
   }
   
   public BodyPart(){
     
   }
   
   public void setPosition(int x, int y){
     xcoord = x;
     ycoord = y;
   }
   
   public void setSize(int w, int h){
      m_height = h;
      m_width = w;
   }
   
   public void render(){ 
     // resize
     texture.resize(m_width, m_height);
     // set draw mode to from centre
     imageMode(CENTER);
     // draw object
     image(texture, xcoord, ycoord);
   }
   
   public void renderHand(BodyPart center){
      // hand
      stroke(126);
      fill(126);
      strokeWeight(1);
      ellipse(xcoord,ycoord,30,30);
      // arm
      strokeWeight(12);
      //line(xcoord,ycoord,(ycoord+center.cx()-10)/2,(ycoord+center.cy()+25)/2);
      //line((xcoord+center.cx()-10)/2,(ycoord+center.cy()+25)/2,center.cx(),center.cy());
      line(xcoord, ycoord, center.cx(), center.cy());
   }
   
   public void renderBody(){
      stroke(126);
      fill(126);
      strokeWeight(1);
      ellipse(xcoord,ycoord,60,100);
   }
   
   public int cx(){ return xcoord; }
   public int cy(){ return ycoord; }
}

//
//    ~~ SPLIT ~~
//