//  COMP3419 Major Assessment - Intelligent Animation
//
//  @author: wallarug
//  @created: 17/05/2017 22:11 PM
//  @modified: 17/05/2017 22:20 PM

// IMPORTS
import processing.video.*;
import processing.sound.*;


// GLOBAL VARIABLES
Movie originalMovie;
PImage segmentedImg;

// Processing Set-up function.  This is run once.  All initial 
//  parameters and settings are set here.
void setup(){
  size(1136,640);  // the size of the window to be rendered.
  
  // the original un-modified file that we are importing to processing
  originalMovie = new Movie(this, sketchPath("monkey.mov"));

  // stop the null pointer
  segmentedImg = loadImage("blank.png");
  
  // play the original movie file
  originalMovie.play();
  originalMovie.loop();
  
}

// Processing Draw function.  This is run on a constant loop
//  and controls all drawing / output to the display.
void draw(){
  
  // draw the original movie to the top left box
  image(originalMovie, 0, 0);
  
  // draw the segmented movie to the top right box
  image(segmentedImg, 568, 0);
  
}


// Processing Movie Event function.  This is called every time a 
//  new frame is available to read for the playing movie.
void movieEvent(Movie m) {
  m.read();
  segmentedImg = segmentRed(m);
}


// FUNCTIONS FOR SEGEMENTING MOTION



// FUNCTIONS FOR GENERATING MOVIE OBJECTS
PImage segmentRed(PImage video)
{
  // variables to control the placement within the new background
  //  this is required if your canvas is a different size to the
  //  original video.
  int adjust_width = 0;
  int adjust_height = 0;
  
  // create a blank image to place the segment on
  PImage blank = new PImage(video.width, video.height);
  
  // go through all the pixels of the monkey frame.
  for(int x = 0; x < video.width; x++){
    for(int y = 0; y < video.height; y++){
      // work out the current pixel location in the matrix
      //  and get the color at that pixel.
      int mloc = x + y * video.width;
      color c = video.pixels[mloc];
    
      // if the pixel has color, calculate the new location
      
      if( red(c) > 160 ) {
        int bgx = constrain(x + adjust_width, 0, blank.width);
        int bgy = constrain(y + adjust_height, 0, blank.height);
        int bgloc = bgx + bgy * blank.width;
        blank.pixels[bgloc] = c;
      }
    }
  }
  
  // return the new canvas with the segmented image on it
  return blank;
}