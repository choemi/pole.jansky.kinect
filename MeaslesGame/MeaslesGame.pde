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
PolygonBlob poly;
PImage blobs;
PImage cam = createImage(640, 480, RGB);
ArrayList<CustomShape> polygons = new ArrayList<CustomShape>();
int kinectWidth = 640;
int kinectHeight = 480;
float reScale;
color blobColor;

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
   //drawUser();
   drawVirus();
   
     background(bgColor);
  // update the SimpleOpenNI object
  context.update();

  cam = context.userImage();
  cam.loadPixels();
  color black = color(0,0,0);
  // filter out grey pixels (mixed in depth image)
  for (int i=0; i<cam.pixels.length; i++)
  { 
    color pix = cam.pixels[i];
    int blue = pix & 0xff;
    if (blue == ((pix >> 8) & 0xff) && blue == ((pix >> 16) & 0xff))
    {
      cam.pixels[i] = black;
    }
  }
  cam.updatePixels();
  
  // copy the image into the smaller blob image
  blobs.copy(cam, 0, 0, cam.width, cam.height, 0, 0, blobs.width, blobs.height);
  // blur the blob image
  blobs.filter(BLUR, 1);
  // detect the blobs
  theBlobDetection.computeBlobs(blobs.pixels);
  // initialize a new polygon
  poly = new PolygonBlob();
  // create the polygon from the blobs (custom functionality, see class)
  poly.createPolygon();
  // create the box2d body from the polygon
  poly.createBody();
  // update and draw everything (see method)
  updateAndDrawBox2D();
  // destroy the person's body (important!)
  poly.destroyBody();
  // set the colors randomly every 240th frame
  //setRandomColors(240);
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

void updateAndDrawBox2D() {
  // if frameRate is sufficient, add a polygon and a circle with a random radius

  
  if (frameRate > 30) {
    CustomShape shape = new CustomShape(kinectWidth/4, -50, 20, BodyType.DYNAMIC);
    polygons.add(shape);
    /*
    CustomShape shape1 = new CustomShape(kinectWidth/2, -50, -1,BodyType.DYNAMIC) ;
     CustomShape shape2 = new CustomShape(kinectWidth/2, -50, random(2.5, 20),BodyType.DYNAMIC);
    polygons.add(shape1);
    polygons.add(shape2);
    */
  }
  // take one step in the box2d physics world
  box2d.step();
 
  // center and reScale from Kinect to custom dimensions
  translate(0, (height-kinectHeight*reScale)/2);
  scale(reScale);
 
  // display the person's polygon  
  noStroke();
  fill(blobColor);
  gfx.polygon2D(poly);
 
  // display all the shapes (circles, polygons)
  // go backwards to allow removal of shapes
  for (int i=polygons.size()-1; i>=0; i--) {
    CustomShape cs = polygons.get(i);
    // if the shape is off-screen remove it (see class for more info)
    
    
    if (cs.done()) {
      polygons.remove(i);
    // otherwise update (keep shape outside person) and display (circle or polygon)
    } else {
      cs.update();
      cs.display();
    }
  }
}
