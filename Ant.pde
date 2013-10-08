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
      float distance;
      if (hungerLevel < minHungerLevel) {  // fat ass ant, moves less!
        distance = 0.1;
      } else {
        distance = 1.5;  // original random distance
      }
      // Sniff trails
      if (hasFood) {
        // Look for home
        int[] direction = homeMap.getStrongest(intX, intY);
        dx += direction[0] * random(distance);
        dy += direction[1] * random(distance);
      }
      else
      {
        // Look for food
        int[] direction = foodMap.getStrongest(intX, intY);
        dx += direction[0] * random(distance);
        dy += direction[1] * random(distance);
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

