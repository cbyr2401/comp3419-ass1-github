//
// Custom Blob Detection library written for COMP3419
// @author: Cian Byrne
// @modified: 30/05/2017
//

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
} // END FUNCTION

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
   
   //println("dots: " + blbs.size() );
   
   // Return PGraphic object.
   //return field;
}