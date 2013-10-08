class MyStatusBar {
  
  public static final String POSITION_TOP = "top";
  public static final String POSITION_BOTTOM = "bottom";
  
  private String position;
  private String statusText = "";
  private float statusBarHeight = 30;
  
  MyStatusBar(String _position) {
    this.position = _position;
  }
  
  void setMyStatusBarHeight(float _statusBarHeight) {
    this.statusBarHeight = _statusBarHeight;
  }
  
  float getMyStatusBarHeight() {
    return statusBarHeight;
  }
  
  void setStatusText(String _text) {
    this.statusText = _text;
  }
  
  String getStatusText() {
    return statusText;
  }
  
  void setPosition(String _position) {
    this.position = _position;
  }

  String getPosition() {
    return position;
  }  
  
  void display() {
    float y = 0;
    float x = 0;
    
    if (position.equals(POSITION_TOP)) {
      y = 0;
    } else if (position.equals(POSITION_BOTTOM)) {
      y = height-statusBarHeight;
    }
    
    rectMode(CORNER);
    fill(0,0,0);
    rect(x,y,width,statusBarHeight);
    
    fill(0,255,0);
    textSize(statusBarHeight/2);
    textAlign(LEFT, CENTER);
    text(statusText,x+5,y+(statusBarHeight/2));
  }
  
}

