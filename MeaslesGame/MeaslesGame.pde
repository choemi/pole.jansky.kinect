import SimpleOpenNI.*;
import blobDetection.*; // blobs
import toxi.geom.*; // toxiclibs shapes and vectors
import toxi.processing.*; // toxiclibs display
import shiffman.box2d.*; // shiffman's jbox2d helper library
import org.jbox2d.collision.shapes.*; // jbox2d
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.common.*; // jbox2d
import org.jbox2d.dynamics.*; // jbox2d
SimpleOpenNI context;


PImage userImage;
PShape virus;
int[] userMap;
PImage rgbImage;
color pixelColor;
color bgColor = color(255, 255, 255);
color userColor = color(0, 0, 0);
BlobDetection theBlobDetection;
ToxiclibsSupport gfx;
Box2DProcessing box2d;


void setup(){
  size(640,480, OPENGL);
  context=new SimpleOpenNI(this);
  if (!context.enableDepth() || !context.enableUser()) { 
    println("Kinect not connected!"); 
    exit();
  } else {
    context.setMirror(true);
    context.enableRGB();
    context.enableDepth();
    context.enableUser();
    userImage=createImage(640,480,RGB);
    virus = loadShape("virus.svg");
    
    theBlobDetection = new BlobDetection(userImage.width, userImage.height);
    theBlobDetection.setThreshold(0.3);
    // initialize ToxiclibsSupport object
    gfx = new ToxiclibsSupport(this);
    // setup box2d, create world, set gravity
    box2d = new Box2DProcessing(this);
    box2d.createWorld();
    box2d.setGravity(0, -40);
    
  }
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
