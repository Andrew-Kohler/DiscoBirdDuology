class Button{  // Button class for making button creation easy and unobtrustive
 int x;  // X position
 int y;  // Y position
 int w;  // Width
 int h;  // Height
 PImage sprite;  // Button sprite
 String text;  // Text that button contains
 
 Button(int x, int y, int w, int h, PImage sprite, String text){  // Constructor
  this.x = x;
  this.y = y;
  this.w = w;
  this.h = h;
  this.sprite = sprite;
  this.text = text;
 }
 
 void drawButton(){    // Draw in the button and the text on top of it
   textAlign(LEFT);
   image(sprite, x, y);
   if(w == 200){
     if(h == 50){
       text(text, x+(w/6), y+(5*h/8));
     }
     else{
       text(text, x+(w/4), y+(5*h/8));
     }
     
   }
   if(w == 320){
     text(text, x+(w/8), y+(5*h/8));
   }

 }
 
 // If pressed return true
 boolean pressed(){
   if(mousePressed){
    if(mouseX > x && mouseX < x+w && mouseY > y && mouseY< y+h){
      return true;
    }
    else{
      return false;
    }
   }
   else{
     return false;
   }
 }
  
}

// text width and center are both things
