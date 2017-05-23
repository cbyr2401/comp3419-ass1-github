//
// Custom Motion Detection library written for COMP3419
// @author: Cian Byrne
// @modified: 23/05/2017
//

// Searches an image, checking if where blocks have moved.
// @Params: PImage previous, PImage current, gridsize
// @Return: PImage PGraphic
PGraphics searchBlocks(PImage A, PImage B, int gridsize){
  int NEIGHBOURHOOD = 3 * gridsize;
  int LARGENUM = 20000000;
  int WLIMITPX = A.width - (gridsize-1);
  int HLIMITPX = A.height - (gridsize-1);
  int WGRIDACROSS = round(A.width / gridsize);
  int HGRIDACROSS = round(A.height / gridsize);
  int HALFGRID = int(gridsize/2);
  
  // 3D Matrix for holding the displacements of each image
  int[][][] displacement = new int[WGRIDACROSS][HGRIDACROSS][2];
  
  // displacement PGraphic to return
  PGraphics disfield;
  
  // index variables for each image
  int di = 0;
  int dj = 0;
  
  // temporary storage for the 
  int[] coords = new int[2];
  float resmin = LARGENUM;
  float res = 0;
  
  // variables for drawing on the lines
  disfield = createGraphics(A.width, A.height);
  disfield.beginDraw();
  disfield.stroke(255,255,255);
  
  // iterate through all the grids from the first image 1 time.
  for(int ax = 0; ax < WLIMITPX; ax += gridsize){
    // reset the row counter.
    dj = 0;
    for(int ay = 0; ay < HLIMITPX; ay += gridsize){
      // set the starting values so that if the same block comes up, 
      // it will be ok.
      resmin = LARGENUM;
      coords[0] = ax;
      coords[1] = ay;
      
      // iterate through all the grids in the second image NUM_GRIDS times
      //  for each grid block from the first image.
      for(int bx = ax - NEIGHBOURHOOD ; bx < ax + NEIGHBOURHOOD && (bx < WLIMITPX); bx += gridsize){
        for(int by = ay - NEIGHBOURHOOD; by < ay + NEIGHBOURHOOD && (by < HLIMITPX); by += gridsize){
          // complete the SSD for each block and store the result...
          if( bx > -1 && by > -1 && ax > -1 && ay > -1){
            res = SSD(A, ax, ay, B, bx, by, gridsize);
            if (res < resmin){
              resmin = res;
              coords[0] = bx;
              coords[1] = by;
            } 
          }
          
          if(bx >= WLIMITPX || by >= HLIMITPX) break;
        }
      }
      
      if ( resmin > 5000 ) {
        // insert the vector into the storage array
        displacement[di][dj][0] = coords[0];
        displacement[di][dj][1] = coords[1];
      } else {
        continue;
      }
      
      
      // draw the vector onto the displacement field
      // if any of the blocks are the same, don't draw anything
      if ( ax == coords[0] && ay == coords[1] ){
        continue;
      }
      
      // draw displacement
      disfield.line(coords[0]+HALFGRID, coords[1]+HALFGRID, ax+HALFGRID, ay+HALFGRID);
      disfield.ellipse(coords[0]+HALFGRID,coords[1]+HALFGRID,3,3);
      disfield.ellipse(ax+HALFGRID,ay+HALFGRID,3,3);
      
      // increment the y-coordinate counter for the displacement array
      dj++;
    }
    
    // increment the x-coordinate counter for the displacement array
    di++;
  }

  // end the drawing on the graphic
  disfield.endDraw();
  image(disfield, 0, 0); 
  
  // release all memory
  
  // return the displacement field (can only be drawn from draw method)
  return disfield;
}


// The minimum sum difference of each pixel.  Called by searchBlocks
// Forumla: SSD(Block_i, Block_i+1) = squareroot ( sum(colorsA - colorsB ) ^2 )
// @Params: PImage previous, PImage current, gridsize
// @Return: PImage PGraphic
float SSD(PImage A, int ax, int ay, PImage B, int bx, int by, int blocksize){
  float sum = 0;
  int cellA = 0;
  int cellB = 0;
  
  for (int x = 0; x < blocksize; x++){
    for(int y = 0; y < blocksize; y++){
      cellA = (ax + x) + ((ay + y) * A.width);
      cellB = (bx + x) + ((by + y) * B.width);
      sum += pow(red(A.pixels[cellA]) - red(B.pixels[cellB]), 2)
            + pow(green(A.pixels[cellA]) - green(B.pixels[cellB]), 2) 
            + pow(blue(A.pixels[cellA]) - blue(B.pixels[cellB]), 2);
    }
  }
  
  //sum = sqrt((float)sum);
  return sum; 
}


// Draws an arrow to the main display.
// @Params: PImage previous, PImage current, gridsize
// @Return: PImage PGraphic
void arrowdraw(int x1, int y1, int x2, int y2) { 
  line(x1, y1, x2, y2);
  pushMatrix(); 
  translate(x2, y2); 
  float a = atan2(x1-x2, y2-y1); 
  rotate(a); 
  line(0, 0, -10, -10);
  line(0, 0, 10, -10); 
  popMatrix(); 
}