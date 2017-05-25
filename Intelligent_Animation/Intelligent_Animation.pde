//  COMP3419 Major Assessment - Intelligent Animation
//
//  @author: wallarug
//  @created: 17/05/2017 22:11 PM
//  @modified: 21/05/2017 22:20 PM

// IMPORTS
import processing.video.*;
import processing.sound.*;


// GLOBAL VARIABLES
Movie originalMovie;
PImage segmentedImg;
PImage binaryImg;
PImage improvedImg;
PGraphics boxes;
ArrayList<Blob> xyz;
int framenumber = 0;
int BLOCKSIZE = 13;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  size(1704,960);  // the size of the window to be rendered.
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));
  
  //boxes = createGraphics(improvedImg.width,improvedImg.height);
  
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
  
  // TOP RIGHT (2): draw the segmented movie
  if ( segmentedImg != null ) {
    image(segmentedImg, 568, 0);
    text("Segmented Image", 568+234, 300);
  }
  
  // BOTTOM LEFT (3): draw the improved binary image
  if ( improvedImg != null ) {
    boxes = drawBlobs(improvedImg);
    image(boxes, 0, 320);
    text("Displacement boxes", 234, 320+300);
  }
  
  // BOTTOM RIGHT (4): draw the binary movie
  if ( improvedImg != null ) {  
    image(improvedImg, 568, 320);
    text("Improved Binary Image", 568+234, 320+300);
  }

  // export the whole image frame
  //saveFrame();
  
}


// Processing Movie Event function.  This is called every time a 
//  new frame is available to read for the playing movie.
void movieEvent(Movie m) {
  m.read();
  
  segmentedImg = segmentMarkers(m, false);
  binaryImg = segmentMarkers(m, true);
  improvedImg = correctAndEnhance(binaryImg);
  //boxes = drawBlobs(improvedImg);
  
  // save the frame
  //binaryImg.save(sketchPath("") + "binary/image" + nf(framenumber, 4) + ".tif");
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
  int AlphaRed = 160;
  int AlphaGreen = 110;  
  
  // go through all the pixels of the monkey frame.
  for(int x = 0; x < video.width; x++){
    for(int y = 0; y < video.height; y++){
      // work out the current pixel location in the matrix
      //  and get the color at that pixel.
      int mloc = x + y * video.width;
      color c = video.pixels[mloc];
    
      // if the pixel correct has color, calculate the new location 
      if( red(c) > AlphaRed && green(c) < AlphaGreen ) {
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
  for ( int i = 0; i < 0; i++) improvement = im_erosion(improvement);
  
  // dilate image many times
  for ( int i = 0; i < 8; i++) improvement = im_dilation(improvement);

  return improvement;
}


// Determines where the location is.
// @param: enhanced binary image
// @return: PGraphic with blobs on it
PGraphics drawBlobs(PImage bin){
   // set up a new PGraphic for temporarily dumping the blobs on.
   PGraphics field;
   field = createGraphics(bin.width, bin.height);
   
   // get the blobs
   ArrayList<Blob> blbs = findBlobs(bin);  

   // set up the field.
   field.beginDraw();
   field.background(0);
   field.fill(255,0,0);
   
   // set the method that Processing needs to use for drawing the objects.
   field.rectMode(CORNERS);
   
   // go through all the blobs and draw them to the PGraphic
   for ( Blob b : blbs ) field.rect(b.minx, b.maxy, b.maxx, b.miny);

   // close the object
   field.endDraw();
   
   // Return PGraphic object.
   return field;
} //<>//

// Determines where the location is.
// @param: PImage enhanced binary
// @return: ArrayList of blobs
ArrayList findBlobs(PImage bin){
   ArrayList<Blob> blobs = new ArrayList<Blob>(5);
   
   color white = color(255,255,255);  // convience.
   int threshold = 9;  // number of pixels to be within a blob
   int jump = 2;    // number of pixels to skip, looking at all of them will take a while.
   
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
  
  // go through all elements twice, checking if there is an overlap.
  for ( Blob a : list ){
    for ( Blob b : list ){
      if (a == b )
      {
        // do not check same elements
      }
      else 
      {
          // check for overlaps, add to removal set if 
          //  there is an overlap.
          if ( a.isInside(b) ) removal.add(b);
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
}
// FUNCTIONS FOR GENERATING MOVIE OBJECTS


//
//    ~~ SPLIT ~~
//