// To Track Object Collisions 

// MOVING OBJECT CLASS

public class MovingObject{
  private int x = 0;
  private int y = 0;
  private int speed = 10;
  private boolean left = false;
  private PGraphics obj;
  
  public MovingObject(PGraphics o, int xp, int yp, int s, boolean direction){
    obj = o;
    x = xp - o.width;
    y = yp;
    left = direction;
    speed = s;
  }
  
  public void move(){
    // check for collisions
    
    
    // move forwards in the desired direction
    if ( left ) {
       x -= speed; 
    } else {
       x += speed; 
    }
    
    // actually move the object
    image(obj, x, y); 
  }
   
  public void checkCollision(){
     
    
    
  }
}