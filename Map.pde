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

