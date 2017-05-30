// NEW CLASS FOR CREATURE
public class Creature{
    BodyPart top_left = null;
    BodyPart top_right = null;
    BodyPart bot_left = null;
    BodyPart bot_right = null;
    BodyPart centre = null;
    
    public Creature() {
      top_left = new BodyPart(imageParts.get(0));
      top_right = new BodyPart(imageParts.get(1));
      bot_left = new BodyPart(imageParts.get(2));
      bot_right = new BodyPart(imageParts.get(3));
      centre = new BodyPart(imageParts.get(4));  
      
      top_left.setSize(30,30);
      top_right.setSize(30,30);
      bot_left.setSize(30,30);
      bot_right.setSize(30,30);
      centre.setSize(60,120);
      
      //top_left = new BodyPart();
      //top_right = new BodyPart();
      //bot_left = new BodyPart();
      //bot_right = new BodyPart();
      //centre = new BodyPart();  
    }
    
    public void update(ArrayList<Blob> list){
       // order: top left, top right, bot left, bot right, centre
       if ( list.get(0) != null ){
         top_left.setPosition(list.get(0).cx(), list.get(0).cy());
       }
       
       if ( list.get(1) != null ){
         top_right.setPosition(list.get(1).cx(), list.get(1).cy());
       }
       
       if ( list.get(2) != null ){
         bot_left.setPosition(list.get(2).cx(), list.get(2).cy());
       }
       
       if ( list.get(3) != null ){
         bot_right.setPosition(list.get(3).cx(), list.get(3).cy());
       }
       
       if ( list.get(4) != null ){
         centre.setPosition(list.get(4).cx(), list.get(4).cy());
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
   
   public void setSize(int w, int h){
      m_height = h;
      m_width = w;
   }
   
   public void render(){ 
     // resize
     texture.resize(m_width, m_height);
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
      //line(xcoord,ycoord,(ycoord+center.cx()-10)/2,(ycoord+center.cy()+25)/2);
      //line((xcoord+center.cx()-10)/2,(ycoord+center.cy()+25)/2,center.cx(),center.cy());
      line(xcoord, ycoord, center.cx(), center.cy());
   }
   
   public void renderBody(){
      stroke(126);
      fill(126);
      strokeWeight(1);
      ellipse(xcoord,ycoord,60,100);
   }
   
   public int cx(){ return xcoord; }
   public int cy(){ return ycoord; }
}