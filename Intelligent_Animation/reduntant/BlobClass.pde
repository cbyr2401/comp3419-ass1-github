//
// Custom Blob Object written for COMP3419
// @author: Cian Byrne
// @modified: 30/05/2017
//

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