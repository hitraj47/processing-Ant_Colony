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

Button btnToggleHungerDisplay;
String showHungerLabel = "Show hunger levels";
String hideHungerLabel = "Hide hunger levels";

float antHungerRate = 0.01;  // how much the ant gains hunger
float antHungerReduction = 20;  // how much hunger is reduced when ant eats
 
void setup() {
  size(900, 506);
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
  
  // show/hide ant hunger
  btnToggleHungerDisplay = new Button(showHungerLabel, 800, 20, 120, 30);
  
}

void draw() {
  
  // Clear bg
  //background(DIRT_COLOR);
  
  loadPixels();
  for (int i=0; i<pherHome.length; i++) {
    color pixelColor;
    if (food.getValue(i)) {
      // Draw food
      pixelColor = FOOD_COLOR;
    } else {
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
  }
  updatePixels();
 
  // Draw ants
  for (int i = 0; i < col.ants.length; i++) {
    Ant thisAnt = col.ants[i];
    
    if (thisAnt.getHungerLevel() >= thisAnt.getMaxHungerLevel()) {
      thisAnt.setAlive(false);
    }
    
    if (thisAnt.isAlive()) {
      thisAnt.step();
      thisAnt.setHungerLevel(thisAnt.getHungerLevel() + antHungerRate);
    }
 
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
      thisAnt.setHungerLevel(thisAnt.getHungerLevel() - antHungerReduction);
    }
 
    if (abs(thisAnt.dx) > abs(thisAnt.dy)) {
      // Horizontal ant
      rect(thisXf,thisYf,3,2);
    } else {
      // Vertical ant
      rect(thisXf,thisYf,2,3);
    }
    
    if (btnToggleHungerDisplay.getLabel().equals(showHungerLabel)) {
      if (mouseNearAnt(thisAnt.intX, thisAnt.intY)) {
        showAntHunger(thisAnt);
      }
    } else if (btnToggleHungerDisplay.getLabel().equals(hideHungerLabel)) {
      showAntHunger(thisAnt);
    }
  }
 
  // Evaporate
  pherHome.step();
  pherFood.step();
 
  // Debug
  //println(frameRate);
  
  // display button
  btnToggleHungerDisplay.display();
  
}

void mousePressed() {
   // Add food
  if (mouseButton == LEFT) {
    if (btnToggleHungerDisplay.isMouseOverButton()) {
      toggleHungerDisplayButton();
    } else {
      food.addFood(mouseX, mouseY);
    }
  }
}

void toggleHungerDisplayButton() {
  if (btnToggleHungerDisplay.getLabel().equals(showHungerLabel)) {
    btnToggleHungerDisplay.setLabel(hideHungerLabel);
  } else {
    btnToggleHungerDisplay.setLabel(showHungerLabel);
  }
}

boolean mouseNearAnt(int _antX, int _antY) {
  // buffer distance, since ants are small
  int buffer = 15;
  
  if ( (mouseX >= _antX-buffer && mouseX <= _antX+buffer) && (mouseY >= _antY-buffer && mouseY <= _antY+buffer) ) {
    return true;
  } else {
    return false;
  }
}

void showAntHunger (Ant _ant) {
  textAlign(CENTER);
  textSize(10);
  int antHunger = (int) _ant.hungerLevel;
  if (antHunger >= _ant.getMaxHungerLevel()) {
    fill(255,0,0);
  } else if (antHunger < _ant.getMinHungerLevel()) {
    fill(0,0,255);
  } else {
    fill(0,0,0);
  }
  text(antHunger, _ant.intX, _ant.intY);
}

void mouseDragged() {
  
  if (mouseButton == RIGHT) {
    pherHome.blur(mouseX, mouseY);
    pherFood.blur(mouseX, mouseY);
  }
}

class Ant {
  float dx = random(-1, 1);
  float dy = random(-1, 1);
  float x;
  float y;
  int intX;
  int intY;
  int lastX;
  int lastY;
  int homeX;
  int homeY;
 
  boolean hasFood = false;
 
  float homePher = 100;
  float foodPher = 100;
  private float USE_RATE = .995;
  private float WANDER_CHANCE = .92;
 
  int bored = 0;
 
  Map homeMap;
  Map foodMap;
  
  color antColor;
  
  // the current hunger level
  float hungerLevel = 0.0;
  
  // what does it take to kill this ant?!
  float maxHungerLevel = 100.0;
  
  // minimum hunger level. If ant eats food after this, they're overweight!
  float minHungerLevel = 0.0;
  
  // is the ant alive?
  boolean alive = true;
 
  Ant(int _x, int _y, Map _homePher, Map _foodMap) {
    intX = homeX = _x;
    intY = homeY = _y;
    x = float(_x);
    y = float(_y);
    homeMap = _homePher;
    foodMap = _foodMap;
    
    // assign a random color for the ant to make it easier to track
    antColor = color(random(255), random(255), random(255));
  }
  
  float getHungerLevel() {
    return hungerLevel;
  }
  
  public void setHungerLevel(float _hungerLevel) {
    this.hungerLevel = _hungerLevel;
  }
  
  public void setMaxHungerLevel(float _maxHungerLevel) {
    this.maxHungerLevel = _maxHungerLevel;
  }
  
  public float getMaxHungerLevel() {
    return maxHungerLevel;
  }
  
  public void setMinHungerLevel(float _minHungerLevel) {
    this.minHungerLevel = _minHungerLevel;
  }
  
  public float getMinHungerLevel() {
    return minHungerLevel;
  }
  
  boolean isAlive() {
    return alive;
  }
  
  public void setAlive(boolean _alive) {
    this.alive = _alive;
  }
 
  void step() {
    // Wander chance .1
    if (random(1) > WANDER_CHANCE) dx += random(-1, 1);
    if (random(1) > WANDER_CHANCE) dy += random(-1, 1);
    if (random(1) > .99) bored += floor(random(15));
     
    if (bored>0) {
      // Ignore pheromones
      bored--;
    } else {
      // Sniff trails
      // will look for home if they have food trail, or if they're fat!
      if (hasFood || hungerLevel < minHungerLevel) {
        // Look for home
        int[] direction = homeMap.getStrongest(intX, intY);
        dx += direction[0] * random(1.5);
        dy += direction[1] * random(1.5);
      }
      else
      {
        // Look for food
        int[] direction = foodMap.getStrongest(intX, intY);
        dx += direction[0] * random(1.5);
        dy += direction[1] * random(1.5);
      }
    }
    // Bounding limits, bounce off of edge
    if (x<2) dx = 1;
    if (x>width-2) dx = -1;
    if (y<2) dy = 1;
    if (y>height-2) dy = -1;
    // Speed limit
    dx = Math.min(dx, 1);
    dx = Math.max(dx, -1);
    dy = Math.min(dy, 1);
    dy = Math.max(dy, -1);
    // Move
    x += dx;
    y += dy;
    intX = floor(x);
    intY = floor(y);
 
    // Only if ant has moved enough (to another pixel)
    if (lastX!=intX || lastY!=intY) {
      // Leave trails
      if (hasFood) {
        // Leave food pheromone trail
        foodPher = foodPher * USE_RATE;
        foodMap.setValue(intX, intY, foodPher);
      }
      else
      {
        // Leave home pheromone trail
        homePher = homePher * USE_RATE;
        homeMap.setValue(intX, intY, homePher);
      }
    }
 
    lastX = intX;
    lastY = intY;
  }
}

class Button {
  
  private String label;
  private float buttonWidth, buttonHeight;
  private float x,y;
  private float borderColorR = 0, borderColorG = 0, borderColorB = 0;
  private float buttonColorR = 255, buttonColorG = 255, buttonColorB = 255;
  private float labelColorR = 0, labelColorG = 0, labelColorB = 0;
  private boolean updating = false;
  
  Button(String label) {
    this.label = label;
  }
  
  Button(String _label, float _x, float _y, float _buttonWidth, float _buttonHeight) {
    this.label = _label;
    this.x = _x;
    this.y = _y;
    this.buttonWidth = _buttonWidth;
    this.buttonHeight = _buttonHeight;
  }
  
  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void setDimensionss(float buttonWidth, float buttonHeight) {
    this.buttonWidth = buttonWidth;
    this.buttonHeight = buttonHeight;
  }
  
  void setWidth(float buttonWidth) {
    this.buttonWidth = buttonWidth;
  }
  
  float getWidth() {
    return buttonWidth;
  }
  
  void setHeight(float buttonHeight) {
    this.buttonHeight = buttonHeight;
  }
  
  float getHeight() {
    return buttonHeight;
  }
  
  void setXPosition(float x) {
    this.x = x;
  }
  
  float getXPosition() {
    return x;
  }
  
  void setYPosition(float y) {
    this.y = y;
  }
  
  float getYPosition() {
    return y;
  }
  
  void setButtonColor(float r, float g, float b) {
    this.buttonColorR = r;
    this.buttonColorG = g;
    this.buttonColorB = b;
  }
  
  void setBorderColor(float r, float g, float b) {
    this.borderColorR = r;
    this.borderColorG = g;
    this.borderColorB = b;
  }
  
  void setLabelColor(float r, float g, float b) {
    this.labelColorR = r;
    this.labelColorG = g;
    this.labelColorB = b;
  }
  
  boolean isMouseOverButton() {
    return (mouseX >= x-(buttonWidth/2) 
      && mouseX <= (x+buttonWidth/2) 
      && mouseY >= (y-buttonHeight/2) 
      && mouseY <= (y+buttonHeight/2));
  }
  
  void display() {
    
    if (updating) {
      stroke(255,0,0);
    } else {
      stroke(borderColorR, borderColorG, borderColorB);
    }
    fill(buttonColorR, buttonColorG, buttonColorB);
    rectMode(CENTER);
    rect(x,y,buttonWidth,buttonHeight,10);
    noStroke();
    textSize(buttonHeight*0.4);
    textAlign(CENTER, CENTER);
    fill(labelColorR, labelColorG, labelColorB);
    text(label,x,y);
  }
  
  void setLabel(String label) {
    this.label = label;
  }
  
  String getLabel() {
    return label;
  }
  
  boolean isUpdating() {
    return updating;
  }
  
  void setUpdating(boolean _updating) {
    this.updating = _updating;
  }
}

class Colony {
 
  Ant[] ants;
  int x;
  int y;
 
  Colony (int _x, int _y, int count, Map _pherHome, Map _pherFood) {
    ants = new Ant[count];
    x = _x;
    y = _y;
    for (int i = 0; i < count; i++) {
      ants[i] = new Ant(x, y, _pherHome, _pherFood);
    }
  }
}

class Food {
 
  private boolean[] mapVals;
  public int length;
  private int mapW;
  private int mapH;
   
  // A boolean map
  Food (int w, int h) {
    mapW = w;
    mapH = h;
    length = mapW*mapH;
    mapVals = new boolean[length];
    for (int i = 0; i < mapVals.length; i++) {
      mapVals[i] = false;
    }
  }
 
  void addFood(int x, int y) {
    try {
      // 10x10 bit of food
      for (int i=x; i<mapW && i<x+10; i++) {
        for (int j=y; j<mapH && j<y+10; j++) {
          setValue(i, j, true);
        }
      }
    }
    catch (Throwable t) {
    }
  }
 
  void setValue(int x, int y, boolean val) {
    try {
      mapVals[y * mapW + x] = val;
    }
    catch (Throwable t) {
    }
  }
 
  void bite(int x, int y) {
    setValue(x-1, y-1, false);
    setValue(x-1, y, false);
    setValue(x-1, y+1, false);
    setValue(x, y-1, false);
    setValue(x, y, false);
    setValue(x, y+1, false);
    setValue(x+1, y-1, false);
    setValue(x+1, y, false);
    setValue(x+1, y+1, false);
  }
   
  boolean getValue(int index) {
    return mapVals[index];
  }
   
  boolean getValue(int x, int y) {
    try {
      return mapVals[y * mapW + x];
    }
    catch (Throwable t) {
      // Off the map
      return false;
    }
  }
 
}

class Map {
 
  private float[] mapVals;
  public int length;
  private int mapW;
  private int mapH;
 
  private float MAX_VAL = 100;
  private float EVAPORATION_RATE = .999;
  
  // convolution/blur stuff
  int blurWidth = 30;  // box width and height
  float blurAmount = 0.111;
  float[][] matrix = { { blurAmount, blurAmount, blurAmount },
                       { blurAmount, blurAmount, blurAmount },
                       { blurAmount, blurAmount, blurAmount } };
 
  // A float map
  Map (int w, int h) {
    mapW = w;
    mapH = h;
    length = mapW*mapH;
    mapVals = new float[length];
    for (int i = 0; i < mapVals.length; i++) {
      mapVals[i] = 0.0;
    }
  }
 
  // Evaporate
  void step() {
    for (int i=0; i<mapVals.length; i++) {
      mapVals[i] = mapVals[i]*EVAPORATION_RATE;
    }
  }
 
  void setValue(int x, int y, float val) {
    try {
      int index = y * mapW + x;
      float oldVal = mapVals[index];
//      mapVals[index] = (oldVal + val)/2;
      if (val>oldVal) {
        mapVals[index] = val;
      }
    }
    catch (Throwable t) {
    }
  }
 
  float getPercentage(int index) {
    return mapVals[index]/MAX_VAL;
  }
 
  float getValue(int index) {
    return mapVals[index];
  }
 
  float getValue(int x, int y) {
    try {
      return mapVals[y * mapW + x];
    }
    catch (Throwable t) {
      // Off the map
      return -1;
    }
  }
 
  /**
   Returns a 2D vector of the strongest direction
   */
  int[] getStrongest(int x, int y) {
    float compare = 0;
    float strongestVal = 0;
    int[] strongest = {
      0, 0
    };
 
    compare = getValue(x-1, y-1); // up left
    if (compare > strongestVal) {
      strongest[0] = -1;
      strongest[1] = -1;
      strongestVal = compare;
    }
    compare = getValue(x, y-1); // up
    if (compare > strongestVal) {
      strongest[0] = 0;
      strongest[1] = -1;
      strongestVal = compare;
    }
    compare = getValue(x+1, y-1); // up right
    if (compare > strongestVal) {
      strongest[0] = 1;
      strongest[1] = -1;
      strongestVal = compare;
    }
    compare = getValue(x-1, y); // left
    if (compare > strongestVal) {
      strongest[0] = -1;
      strongest[1] = 0;
      strongestVal = compare;
    }
    compare = getValue(x+1, y); // right
    if (compare > strongestVal) {
      strongest[0] = 1;
      strongest[1] = 0;
      strongestVal = compare;
    }
    compare = getValue(x-1, y+1); // down left
    if (compare > strongestVal) {
      strongest[0] = -1;
      strongest[1] = 1;
      strongestVal = compare;
    }
    compare = getValue(x, y+1); // down
    if (compare > strongestVal) {
      strongest[0] = 0;
      strongest[1] = 1;
      strongestVal = compare;
    }
    compare = getValue(x+1, y+1); // down right
    if (compare > strongestVal) {
      strongest[0] = 1;
      strongest[1] = 1;
      strongestVal = compare;
    }
 
    return strongest;
  }
  
  void blur(int _xpos, int _ypos) {
    // Calculate the blur rectangle
    int xstart = constrain(_xpos - blurWidth/2, 0, width);
    int ystart = constrain(_ypos - blurWidth/2, 0, height);
    int xend = constrain(_xpos + blurWidth/2, 0, width);
    int yend = constrain(_ypos + blurWidth/2, 0, height);
    int matrixsize = 3;

    // Begin our loop for every pixel in the smaller image
    for (int x = xstart; x < xend; x++) {
      for (int y = ystart; y < yend; y++) {
        setValue(x, y, convolution(x, y, matrix, matrixsize));
      }
    }
  }
  
  float convolution(int x, int y, float[][] matrix, int matrixsize)
  {
    float atotal = 0.0;
    for (int i = 0; i < matrixsize; i++){
      for (int j= 0; j < matrixsize; j++){
        atotal += (getValue(x-1+i, y-1+i) * matrix[i][j]);
      }
    }
    // Return the resulting color
    return atotal;   
  }
  
}


