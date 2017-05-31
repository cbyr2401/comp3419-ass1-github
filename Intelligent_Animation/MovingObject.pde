// To Track Object Collisions 

// MOVING OBJECT CLASS

public class MovingObject{
  private int x = 0;
  private int y = 0;
  private int speed = 10;
  private boolean left = false;
  private PGraphics obj;
  private boolean delete = false;
  
  public MovingObject(PGraphics o, int yp, int s, boolean direction){
    obj = o;
    if ( direction ) x = GLOBAL_WIDTH + o.width;
    else x = 0 - o.width;
    y = yp;
    left = direction;
    speed = s;
  }
  
  public void move(){
    // check for collisions
    
    // check to be deleted?
    if ( ( x < (0 - obj.width) && left ) || ( x > (GLOBAL_WIDTH+obj.width) && !left ) )
    {
      delete = true;
    }
    
    
    // move forwards in the desired direction
    if ( left ) {
       x -= speed; 
    } else {
       x += speed; 
    }
    
    // actually move the object
    image(obj, x, y); 
  }
  
  public int maxy() { return y+obj.height; }
  public int miny() { return y; }
  public int maxx() { return x+obj.width; }
  public int minx() { return x; }
    

  public boolean checkCollision(MovingObject other){
    // TODO: Confirm this is working  
    // check if the positions overlap
      if ( minx() < other.maxx() &&
           maxx() > other.minx() &&
           miny() < other.maxy() &&
           maxy() > other.miny()
          )
      {
         // yes they have collided
         println("collision " + framenumber);
         return true;
      }
             
      return false;
  }  
  
  
  public boolean tbd(){ return delete; }
}