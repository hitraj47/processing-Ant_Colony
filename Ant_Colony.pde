/*
  (CC) 2010 Forrest Oliphant, http://sembiki.com/
 This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License
 http://creativecommons.org/licenses/by-sa/3.0/
 */
 
 
//color ANT_COLOR = color(68, 0, 8);
int DIRT_R = 217;
int DIRT_G = 165;
int DIRT_B = 78;
color DIRT_COLOR = color(DIRT_R, DIRT_G, DIRT_B);
color FOOD_COLOR = color(158, 55, 17);
int HOME_R = 96;
int HOME_G = 85;
int HOME_B = 33;
//color PHER_HOME_COLOR = color(HOME_R, HOME_G, HOME_B);
int FOOD_R = 255;
int FOOD_G = 255;
int FOOD_B = 255;
//color PHER_FOOD_COLOR = color(FOOD_R, FOOD_G, FOOD_B);
 
Colony col;
Food food;
Map pherHome;
Map pherFood;

PImage img;

// convolution/blur stuff
int blurWidth = 60;  // box width and height
float blurAmount = 0.111;
float[][] matrix = { { blurAmount, blurAmount, blurAmount },
                     { blurAmount, blurAmount, blurAmount },
                     { blurAmount, blurAmount, blurAmount } };
 
void setup() {
  size(900, 506, P2D);
  background(DIRT_COLOR);
  noStroke();
  //smooth();
 
  pherHome = new Map(width, height);
  pherFood = new Map(width, height);
  col = new Colony(100, 100, 50, pherHome, pherFood);
  food = new Food(width, height);
 
  // Sprinkle some crumbs around
  for (int i=0; i<10; i++) {
    food.addFood(400+int(random(-50, 50)), 300+int(random(-50, 50)));
  }
  
  // load our image for convolution
  img = createImage(width, height, RGB);
  
}
 
void draw() {
  // Clear bg
  //background(DIRT_COLOR);
  
  // Add food
  if (mousePressed && mouseButton == LEFT) {
    food.addFood(mouseX, mouseY);
  }
 
  loadPixels();
  for (int i=0; i<pherHome.length; i++) {
    color pixelColor;
    if (food.getValue(i)) {
      // Draw food
      pixelColor = FOOD_COLOR;
    }
    else {
      // Draw pheromones
      // I found the direct math to be faster than blendColor()
      float pixelAlpha = pherHome.getPercentage(i);
      int pixel_r = int(HOME_R * pixelAlpha + DIRT_R * (1-pixelAlpha));
      int pixel_g = int(HOME_G * pixelAlpha + DIRT_G * (1-pixelAlpha));
      int pixel_b = int(HOME_B * pixelAlpha + DIRT_B * (1-pixelAlpha));
       
      pixelAlpha = pherFood.getPercentage(i);
      pixel_r = int(FOOD_R * pixelAlpha + pixel_r * (1-pixelAlpha));
      pixel_g = int(FOOD_G * pixelAlpha + pixel_g * (1-pixelAlpha));
      pixel_b = int(FOOD_B * pixelAlpha + pixel_b * (1-pixelAlpha));
       
      // Using bitwise color math instead of color() on the following line
      // upped the framerate from 43 to 58 on my computer
      //pixelColor = color(pixel_r, pixel_g, pixel_b);
      pixelColor = pixel_r << 16 | pixel_g << 8 | pixel_b;
    }
    // Set
    pixels[i] = pixelColor;
    
    // set img pixels
    img.pixels = pixels;
  }
  updatePixels();
 
  // Draw ants
  for (int i = 0; i < col.ants.length; i++) {
    Ant thisAnt = col.ants[i];
 
    thisAnt.step();
 
    int thisXi = thisAnt.intX;
    int thisYi = thisAnt.intY;
    float thisXf = thisAnt.x;
    float thisYf = thisAnt.y;
 
    //fill(ANT_COLOR);
    
    // change the fill to the ant color
    fill(thisAnt.antColor);
 
    if (thisAnt.hasFood) {
      fill(FOOD_COLOR);
      if (thisXi>col.x-10 && thisXi<col.x+10 && thisYi>col.y-10 && thisYi<col.y+10) {
        // Close enough to home
        thisAnt.hasFood = false;
        thisAnt.homePher = 100;
      }
    }
    else if(food.getValue(thisXi, thisYi)) {
      thisAnt.hasFood = true;
      thisAnt.foodPher = 100;
      food.bite(thisXi, thisYi);
    }
 
    if (abs(thisAnt.dx) > abs(thisAnt.dy)) {
      // Horizontal ant
      rect(thisXf,thisYf,3,2);
    } else {
      // Vertical ant
      rect(thisXf,thisYf,2,3);
    }
  }
 
  // Evaporate
  pherHome.step();
  pherFood.step();
 
  // Debug
  //println(frameRate);
  
}

void mouseDragged() {
  
  if (mouseButton == RIGHT) {
    // Calculate the blur rectangle
    int xstart = constrain(mouseX - blurWidth/2, 0, img.width);
    int ystart = constrain(mouseY - blurWidth/2, 0, img.height);
    int xend = constrain(mouseX + blurWidth/2, 0, img.width);
    int yend = constrain(mouseY + blurWidth/2, 0, img.height);
    int matrixsize = 3;
    loadPixels();

    // Begin our loop for every pixel in the smaller image
    for (int x = xstart; x < xend; x++) {
      for (int y = ystart; y < yend; y++) {
        color c = convolution(x, y, matrix, matrixsize, img);
        int loc = x + y*img.width;
        pixels[loc] = c;
      }
    }
  }
  updatePixels();
}

color convolution(int x, int y, float[][] matrix, int matrixsize, PImage img)
{
  float rtotal = 0.0;
  float gtotal = 0.0;
  float btotal = 0.0;
  int offset = matrixsize / 2;
  for (int i = 0; i < matrixsize; i++){
    for (int j= 0; j < matrixsize; j++){
      // What pixel are we testing
      int xloc = x+i-offset;
      int yloc = y+j-offset;
      int loc = xloc + img.width*yloc;
      // Make sure we haven't walked off our image, we could do better here
      loc = constrain(loc,0,img.pixels.length-1);
      // Calculate the convolution
      rtotal += (red(img.pixels[loc]) * matrix[i][j]);
      gtotal += (green(img.pixels[loc]) * matrix[i][j]);
      btotal += (blue(img.pixels[loc]) * matrix[i][j]);
    }
  }
  // Make sure RGB is within range
  rtotal = constrain(rtotal, 0, 255);
  gtotal = constrain(gtotal, 0, 255);
  btotal = constrain(btotal, 0, 255);
  // Return the resulting color
  return color(rtotal, gtotal, btotal);
}

