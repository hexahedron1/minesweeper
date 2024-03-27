String state = "mainmenu";
int difficulty = 0;
boolean debug = false;
boolean[][] mines = new boolean[0][0];
boolean[][] revealed = new boolean[0][0];
boolean[][] flags = new boolean[0][0];
int gridSize = 0;
int mineCount = 0;
int flagCount = 0;
int dugCount = 0;
int cellSize = 0;
int cursorX = 0;
int cursorY = 0;
int startTime = 0;
int stopTime = 0;
void setup() {
  size(512, 512, P2D);
  stroke(255);
  windowTitle("mines weeper");
}
color[] numColors = new color[] {
  #000000, //0
  #1C3070, //1
  #026600, //2
  #EB2525, //3
  #8366EB, //4
  #FF6201, //5
  #37EBE9, //6
  #FF00C3, //7
  #E5FFDE, //8
}; 
int time = 0;
void draw() {
  if (state == "mainmenu") {
    background(#050F24);
    bgLines();
    stroke(255);
    fill(255);
    textSize(34);
    text("Minesweeper", 2, 28);
    fill(#050F24);
    textSize(18);
    rect(2, 40, 80, 22);
    if (cursorIn(2, 40, 82, 62)) {
      fill(255);
      rect(2, 40, 80, 22);
      fill(#050F24);
    } else
      fill(255);
    text("Play", 6, 56);
  } else if (state == "gameStart") {
    background(#050F24);
    bgLines();
    fill(#050F24);
    textSize(18);
    stroke(255);
    rect(2, 2, 80, 22);
    if (cursorIn(2, 2, 82, 24)) {
      fill(255);
      rect(2, 2, 80, 22);
      fill(#050F24);
    } else
      fill(255);
    text("Back", 6, 20);
    fill(255);
    text("Press keys 1-5 to select difficulty\nPress enter to confirm: " + difficulty + "\nGrid size: " + gridSize + 'x' + gridSize + "\n Mines: " + mineCount, 6, 42);
  } else if (state == "game") {
    background(#020712);
    bgLines();
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        int checker = ((x % 2 + y % 2) % 2);
        int minesNear = countMines(x, y);
        cursorX = (mouseX) / cellSize;
        cursorY = (mouseY) / cellSize;
        color col = 0;
        if (revealed[x][y]) {
          if (mines[x][y])
            col = checker == 1 ? #FF512E : #C7302B;
          else 
            col = checker == 1 ? #DEA535 : #AD8129;
        } else {
          col = checker == 1 ? #40FF4C : #2AA631;
        }
        fill(col);
        stroke(col);
        rect(x*cellSize, y*cellSize, cellSize, cellSize);
        if (flags[x][y]) {
          col = checker == 1 ? #FF512E : #C7302B;
          fill(col);
          stroke(col);
          rect(x*cellSize + cellSize/4, y*cellSize + cellSize/4, cellSize/2, cellSize/2);
        }
        if (inRange(cursorX, 0, gridSize - 1) && inRange(cursorY, 0, gridSize - 1)) {
          noFill();
          stroke(255);
          rect(cursorX * cellSize, cursorY * cellSize, cellSize, cellSize);
        }
        if (minesNear > 0 && !mines[x][y] && revealed[x][y]) {
          textSize(cellSize*0.8);
          fill(numColors[minesNear]);
          text(minesNear, x*cellSize + cellSize/4, y*cellSize + (cellSize*0.8));
        }
      }
    }
    textSize(18);
    fill(flagCount > mineCount? #FF0000 : #FFFFFF);
    text(flagCount + "/" + mineCount, cellSize*gridSize + 10, 20);
    int time = millis() - startTime;
    text(padLeft(Integer.toString((time/1000/60)%60), 2, '0') + ":" + padLeft(Integer.toString((time/1000)%60), 2, '0'), cellSize*gridSize + 10, 40);// 
  } else if (state == "deathscreen") {
    background(#050F24);
    bgLines();
    textSize(34);
    text("You lost!", 2, 36);
    textSize(18);
    text("To return to the main menu press any key", 2, 56);
  } else if (state == "winscreen") {
    background(#050F24);
    bgLines();
    textSize(34);
    text("You won!", 2, 36);
    textSize(18);
    int time = stopTime-startTime;
    text("You were playing for "  + (time/1000/60)%60 + " minute(s) and " + (time/1000)%60 + " second(s)\nTo return to the main menu press any key", 2, 56);
  } else {
    background(#050F24);
    text("You got into a nonexistent screen.\nPress any key to go to the main menu\nAlso notify the developer about this.\nScreen code: " + state.toUpperCase(), 6, 42);
  }
  fill(255);
  if (debug) {
    textSize(18);
    text(round(frameRate) + " FPS", 2, height - 22);
    text(cursorX + " " + cursorY, 2, height - 42);
  }
  text("v1.0", 2, height - 2);
  time += 1;
}

boolean cursorIn(int x1, int y1, int x2, int y2) {
  return mouseX > x1 && mouseX < x2 && mouseY > y1 && mouseY < y2;
}
void mouseClicked() {
  if (state == "mainmenu") {
    if (cursorIn(2, 40, 82, 62))
      state = "gameStart";
  } else if (state == "gameStart") {
    if (cursorIn(2, 2, 82, 24))
      state = "mainmenu";
  } else if (state == "game" && inRange(cursorX, 0, gridSize - 1) && inRange(cursorY, 0, gridSize - 1)) {
    if (mouseButton == LEFT && !flags[cursorX][cursorY]) {
      dig(cursorX, cursorY);
      if (mines[cursorX][cursorY]) {
        state = "deathscreen";
      }
    }
    else if (mouseButton == RIGHT && !revealed[cursorX][cursorY]) {
      if (flags[cursorX][cursorY]) {
        flags[cursorX][cursorY] = false;
        flagCount--;
      } else {
        flags[cursorX][cursorY] = true;
        flagCount++;
      }
    }
      
  }
}
void bgLines() {
  stroke(#02050D);
  for (int i = 0; i < height / 16 + 2; i++)
    line(0, (time + i*15) % height, width, (time + i*15) % height);
} 
void keyPressed() {
  if (state == "gameStart") {
    if (Character.isDigit(key)) {
      int input = int(key) - 48;
      if (input > 0 && input <= 5) {
        difficulty = input;
        gridSize = 5 * (difficulty);
        mineCount = floor(10 * (difficulty*0.9));
      }
    } else if (keyCode == ENTER) {
      mines = new boolean[gridSize][gridSize];
      revealed = new boolean[gridSize][gridSize];
      flags = new boolean[gridSize][gridSize];
      cellSize = (width - 150) / gridSize;
      for (int i = 0; i < mineCount; i++) {
        int x = floor(random(gridSize));
        int y = floor(random(gridSize));
        if (mines[x][y] || (x == 0 && y == 0)) {
          i--;
          continue;
        };
        mines[x][y] = true;
      }
      startTime = millis();
      state = "game";
    }
  } else if (state == "deathscreen" || state == "winscreen") {
    state = "mainmenu";
  }
}

int countMines(int x, int y) {
  int output = 0;
  for (int x_ = x-1; x_ <= x+1; x_++) {
    for (int y_ = y-1; y_ <= y+1; y_++) {
      if (inRange(x_, 0, gridSize-1) && inRange(y_, 0, gridSize-1) && mines[x_][y_])
        output++;
    }
  }
  return output;
}

boolean inRange(int number, int min, int max) {
  return number >= min && number <= max;
}
void dig(int x, int y) {
  if (revealed[x][y]) return;
  dugCount++;
  if (dugCount + flagCount == pow(gridSize, 2)) {
    stopTime = millis();
    state = "winscreen";
  }
  revealed[x][y] = true;
  if (countMines(x, y) == 0) {
      for (int x_ = x-1; x_ <= x+1; x_++) {
        for (int y_ = y-1; y_ <= y+1; y_++) {
          if (inRange(x_, 0, gridSize-1) && inRange(y_, 0, gridSize-1) && !mines[x_][y_] && !flags[cursorX][cursorY])
            dig(x_, y_);
        }
      } 
  }
}
String padRight(String s, int n, char c) {
     return String.format("%-" + n + "s", s).replace(' ', c);
}

String padLeft(String s, int n, char c) {
    return String.format("%" + n + "s", s).replace(' ', c);  
}
