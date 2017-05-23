//
// Custom Image library written for COMP3419
// @author: Cian Byrne
// @modified: 21/05/2017
//

// Creates a grey scale image of a given frame
// @Params: PImage image
// @Return: PImage greyscale of image
PImage im_greyscale(PImage img)
{
  // create a new image to return with grey scale.
  PImage nImg = new PImage(img.width, img.height);
  int w = nImg.width;
  int h = nImg.height;
  
  // calculate the grey levels for each pixel in the image
  //  and set the value in the new image.
  for (int i = 0; i < w*h; i++){      
      // Calculate the grey scale
      float rtotal = (red(img.pixels[i]) * 0.21267);
      float gtotal = (green(img.pixels[i]) * 0.715160);
      float btotal = (blue(img.pixels[i]) * 0.072169);
      float greytotal = rtotal + gtotal + btotal;
      
      // Make sure RGB is within range
      rtotal = constrain(rtotal, 0, 255);
      gtotal = constrain(gtotal, 0, 255);
      btotal = constrain(btotal, 0, 255);
      
      // add to image
      nImg.pixels[i] = color(greytotal);
  }
  
  // return the new grey complete image.
  return nImg;
}

// Finds the edges of an object and returns as a new PImage
// @Params: PImage frame
// @Return: PImage edges of frame objects
PImage im_edgedetection(PImage img){
 // dilate and erode first
 PImage open = im_dilation(img);
 
 // subtract the source from the result:
 PImage result = new PImage(img.width, img.height);
 
 for(int c=0; c < img.width*img.height; c++){
   int col = img.pixels[c] - open.pixels[c];
   result.pixels[c] = col;
   //if(col == 0) result.pixels[c] = color(0,0,0);
   //else result.pixels[c] = color(255,255,255);
 }
 
 return result;  
}

// Produces a open image of the given frame
// @Params: PImage frame
// @Return: PImage open frame
PImage im_opening(PImage img){
   PImage erode = im_erosion(img);
   PImage di = im_dilation(erode);
   
   return di;
}

// Produces a closed image of the given frame
// @Params: PImage frame
// @Return: PImage closed frame
PImage im_closing(PImage img){
   PImage di = im_dilation(img);
   PImage erode = im_erosion(di);
   return erode;
}

// Produces a erosion image of the given frame
// @Params: PImage frame
// @Return: PImage eroded frame
PImage im_erosion(PImage img)
{
 // Create a new PImage object to return the dialation.
 PImage img_corrected = new PImage(img.width, img.height);
 
 // Initialise variables
 color white = color(255,255,255);
 color black = color(0,0,0);
 boolean yes = false;
 boolean[] chk = new boolean[9];
 
 
 // check the edges
 for(int i=1; i < img.height-1; i++){
   for(int j=1; j < img.width-1; j++){
     // We have been given a 3x3 structuring element that we need
     //  to overlay on all elements in the image matrix.
     // The result will be inserted into the new image if any elements
     //  from the binary image match when overlayed.
     
     // default action: add to image
     yes = true;
     
     // set all values
     for(int k=0; k < 5; k++){
       chk[k] = false;
     }

     // apply the matrix using these if statements (pretend matrix)
     if(img.pixels[(j+0) + ((i-1)*img.width)] == white) chk[0] = true;
     if(img.pixels[(j-1) + ((i+0)*img.width)] == white) chk[1] = true;
     if(img.pixels[(j+0) + ((i+0)*img.width)] == white) chk[2] = true;
     if(img.pixels[(j+1) + ((i+0)*img.width)] == white) chk[3] = true;
     if(img.pixels[(j+0) + ((i+1)*img.width)] == white) chk[4] = true;

     // check the temp matrix to see if we need to add a pixel.
     for(int k=0; k < 5; k++){
      if(chk[k] == true){
        yes = true;
      }else{
        yes = false;
        break;
      }
     }
     
     // insert into image...
     if(yes){
       img_corrected.pixels[j + i*img.width] = white;
     }else{
       img_corrected.pixels[j + i*img.width] = black;
     }   
   }
 }
 return img_corrected;  
}


// Produces a dialated image of the given frame
// @Params: PImage frame
// @Return: PImage dialated frame
PImage im_dilation(PImage img)
{
 // Create a new PImage object to return the dialation.
 PImage img_corrected = new PImage(img.width, img.height);
 
 // Initialise variables
 color white = color(255,255,255);
 color black = color(0,0,0);
 boolean yes = false;

 // check the edges
 for(int i=1; i < img.height-1; i++){
   for(int j=1; j < img.width-1; j++){
     // We have been given a 3x3 structuring element that we need
     //  to overlay on all elements in the image matrix.
     // The result will be inserted into the new image if any elements
     //  from the binary image match when overlayed.
     
     // default action:  do not add
     yes = false;
     
     // apply the matrix using these if statements (pretend matrix)
     if(img.pixels[(j+0) + ((i-1)*img.width)] == white) yes = true;
     if(img.pixels[(j-1) + ((i+0)*img.width)] == white) yes = true;
     if(img.pixels[(j+0) + ((i+0)*img.width)] == white) yes = true;
     if(img.pixels[(j+1) + ((i+0)*img.width)] == white) yes = true;
     if(img.pixels[(j+0) + ((i+1)*img.width)] == white) yes = true;
     
     // insert into image...
     if(yes){
       img_corrected.pixels[j + i*img.width] = white;
     }else{
       img_corrected.pixels[j + i*img.width] = black;
     }   
   }
 }
 return img_corrected;  
}


// Produces a binary image of the given frame
// @Params: PImage frame
// @Return: PImage binary frame
PImage im_binary(PImage img)
{
 PImage binary = new PImage(img.width, img.height);
 
 for(int i=0; i < img.width*img.height; i++){
   int bright = int(brightness(img.pixels[i]));
   if(bright > 128){
     binary.pixels[i] = color(255,255,255);
   }
   else{
     binary.pixels[i] = color(0,0,0);
   }
 }
 
 return binary;
}