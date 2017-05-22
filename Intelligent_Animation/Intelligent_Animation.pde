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
int framenumber = 0;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  size(1136,640);  // the size of the window to be rendered.
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));

  // stop the null pointer
  segmentedImg = loadImage("blank.png");
  
  // stop the null pointer
  binaryImg = loadImage("blank.png");
  
  improvedImg = loadImage("blank.png");
  
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
  
  // draw the original movie to the top left box
  image(originalMovie, 0, 0);
  text("Original Movie File", 284, 318);
  
  // draw the segmented movie to the top right box
  image(segmentedImg, 568, 0);
  text("Segmented Image", 568+284, 318);
  
  // draw the binary movie to the bottom right box
  image(binaryImg, 568, 320);
  text("Binary Image", 568+284, 636);
  
  // draw the improved binary image to the bottom left box
  image(improvedImg, 568, 0);
  text("Improved Image", 568+284, 318);
  
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
  
  // save the frame
  binaryImg.save(sketchPath("") + "binary/image" + nf(framenumber, 4) + ".tif");
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
  improvement = erosion(bin);
  // close image
  improvement = closing(improvement);

  return improvement;
}

// FUNCTIONS FOR GENERATING MOVIE OBJECTS


//
//    ~~ SPLIT ~~
//