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
  btnToggleHungerDisplay = new Button(showHungerLabel, 800, 20, 150, 30);
  
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

