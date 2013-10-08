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

