

void setup(){
 size(600,400); 
 noLoop();
}

void draw(){
  rectMode(CORNERS);
  // hand
  stroke(126);
  fill(126);
  strokeWeight(1);
  ellipse(200,200,30,30);
  // arm
  strokeWeight(12);
  line(200,200,(200+250-10)/2,(200+250+25)/2);
  line((200+250-10)/2,(200+250+25)/2,250,250);
  strokeWeight(1);
  // body?
  ellipseMode(CENTER);
  ellipse(250,250,40,40);
  
}