// NEW CLASS FOR CREATURE
public class Creature{
    BodyPart top_left = null;
    BodyPart top_right = null;
    BodyPart bot_left = null;
    BodyPart bot_right = null;
    BodyPart centre = null;
    
    public Creature(ArrayList<PImage> imgp) {
      top_left = new BodyPart(imgp.get(0));
      top_right = new BodyPart(imgp.get(1));
      bot_left = new BodyPart(imgp.get(2));
      bot_right = new BodyPart(imgp.get(3));
      centre = new BodyPart(imgp.get(4));  
      
      top_left.setSize(45,45);
      top_right.setSize(45,45);
      bot_left.setSize(45,45);
      bot_right.setSize(45,45);
      centre.setSize(90,150);
      
      //top_left = new BodyPart();
      //top_right = new BodyPart();
      //bot_left = new BodyPart();
      //bot_right = new BodyPart();
      //centre = new BodyPart();  
    }
    
    public void update(ArrayList<PVector> list){
       // order: top left, top right, bot left, bot right, centre
       if ( list.get(0) != null ){
         top_left.setPosition(list.get(0).x, list.get(0).y);
       }
       
       if ( list.get(1) != null ){
         top_right.setPosition(list.get(1).x, list.get(1).y);
       }
       
       if ( list.get(2) != null ){
         bot_left.setPosition(list.get(2).x, list.get(2).y);
       }
       
       if ( list.get(3) != null ){
         bot_right.setPosition(list.get(3).x, list.get(3).y);
       }
       
       if ( list.get(4) != null ){
         centre.setPosition(list.get(4).x, list.get(4).y);
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
    
    public void render(PGraphics canvas){
       canvas.beginDraw();
       canvas.clear();
       canvas.imageMode(CENTER);
       canvas.stroke(34,177,76);
       canvas.strokeWeight(15);
       
       canvas.line(bot_left.xcoord+15, bot_left.ycoord-15, centre.xcoord, centre.ycoord);
       canvas.image(bot_left.texture, bot_left.xcoord, bot_left.ycoord);
      
       canvas.line(bot_right.xcoord-15, bot_right.ycoord+15, centre.xcoord, centre.ycoord);
       canvas.image(bot_right.texture, bot_right.xcoord, bot_right.ycoord);
       
       canvas.line(top_left.xcoord, top_left.ycoord, centre.xcoord, centre.ycoord);
       canvas.image(top_left.texture, top_left.xcoord, top_left.ycoord);
       
       canvas.line(top_right.xcoord, top_right.ycoord, centre.xcoord, centre.ycoord);
       canvas.image(top_right.texture, top_right.xcoord, top_right.ycoord);

       canvas.image(centre.texture, centre.xcoord, centre.ycoord);       
       canvas.endDraw();
    }
    
    public boolean checkCollision(MovingObject other){
      // check all parts
      if ( bot_left.minx() < other.maxx() &&
           bot_left.maxx() > other.minx() &&
           bot_left.miny() < other.maxy() &&
           bot_left.maxy() > other.miny()
          ) return true;
      
      if ( bot_right.minx() < other.maxx() &&
           bot_right.maxx() > other.minx() &&
           bot_right.miny() < other.maxy() &&
           bot_right.maxy() > other.miny()
          ) return true;
          
      if ( top_left.minx() < other.maxx() &&
           top_left.maxx() > other.minx() &&
           top_left.miny() < other.maxy() &&
           top_left.maxy() > other.miny()
          ) return true;
          
      if ( bot_right.minx() < other.maxx() &&
           bot_right.maxx() > other.minx() &&
           bot_right.miny() < other.maxy() &&
           bot_right.maxy() > other.miny()
          ) return true;
          
      if ( centre.minx() < other.maxx() &&
           centre.maxx() > other.minx() &&
           centre.miny() < other.maxy() &&
           centre.maxy() > other.miny()
          ) return true;    
      
      return false;
    }
}


public class BodyPart {
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
   
   public void setPosition(float x, float y){
     xcoord = (int)x;
     ycoord = (int)y;
   }
   
   public void setSize(int w, int h){
      m_height = h;
      m_width = w;
      texture.resize(w, h);
   }
   
   public void render(){ 
     // resize
     //texture.resize(m_width, m_height);
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
      //line(xcoord,ycoord,(ycoord+center.x-10)/2,(ycoord+center.y+25)/2);
      //line((xcoord+center.x-10)/2,(ycoord+center.y+25)/2,center.x,center.y);
      line(xcoord, ycoord, center.xcoord, center.ycoord);
   }
   
   public void renderBody(){
      stroke(126);
      fill(126);
      strokeWeight(1);
      ellipse(xcoord,ycoord,60,100);
   }
   
   public int maxx() { return xcoord + texture.width; }
   public int minx() { return xcoord; }
   public int maxy() { return ycoord + texture.height; }
   public int miny() { return ycoord; }
   
}