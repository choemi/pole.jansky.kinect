import SimpleOpenNI.*;
SimpleOpenNI context;


PImage userImage;
PShape virus;
int[] userMap;
PImage rgbImage;
color pixelColor;
color bgColor = color(255, 255, 255);
color userColor = color(0, 0, 0);

void setup(){
  size(640,480, P2D);
  context=new SimpleOpenNI(this);
  context.enableRGB();
  context.enableDepth();
  context.enableUser();
  userImage=createImage(640,480,RGB);
  virus = loadShape("virus.svg");
}

void draw(){
   drawUser();
   drawVirus();
}

void drawUser(){
  background(0);
  context.update();
  rgbImage=context.rgbImage();
  userMap=context.userMap();
  for(int y=0;y<context.depthHeight();y++){
    for(int x=0;x<context.depthWidth();x++){
      int index=x+y*640;
      if(userMap[index]!=0){
          pixelColor=rgbImage.pixels[index];
        userImage.pixels[index]=userColor;
      }else{
        userImage.pixels[index]=bgColor;
      }
 
 
    }
  }
  userImage.updatePixels();
  image(userImage,0,0);
}

void drawVirus(){
    
    shape(virus, 150, 50, 100, 100);
    virus.rotate(0.1);
}
