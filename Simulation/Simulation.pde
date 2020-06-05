int screenX = 1400;
int screenY = 1000;

String modeText = "No Mode Selected";
Mode mode = Mode.NONE;

enum Mode
{
    NONE, GOAL, START, BOIDS, OBSTACLES
};

PShape tree;
PShape tower;
PShape chest;
PShape dragon;
PShape floor;
PShape table;
PShape pirate;
PImage map;

void setup() {
  size(1400, 1000, P3D);
  camera = new Camera();
  tree = loadShape("BirchTree_1.obj");
  tower = loadShape("tower.obj");
  chest = loadShape("Chest_Ingots.obj");
  dragon = loadShape("Dragon.obj");
  floor = loadShape("WallRocks.obj");
  table = loadShape("Table2.obj");
  pirate = loadShape("pirate_crew.obj");
  map = loadImage("map.png");
}

void draw() {
  background(200, 200, 200);
  UpdateBoidsPosition();
  UpdateObstacle();
  DrawBoids();
  DrawObstacle();
  DrawPoints();
  DrawConnections();
  DrawScene();
  DrawUI();
  camera.Update(1/frameRate);
  surface.setTitle("Spring System   FPS" + "  -  " +str(round(frameRate)));
}

void DrawUI() {
  // Mode Text
  switch(mode) {
   case OBSTACLES:
      fill(200, 0, 0);
      break;
   case BOIDS:
      fill(50, 100, 255);
      break;
   case START:
     fill(25, 25, 100);
     break;
   case GOAL:
     fill(175, 100, 50);
     break;
   default :
      fill(255, 255, 255);
  }
  textSize(20);
  text(modeText, 20, screenY- 30);
  
  // Control Panel Text
  fill(0, 0, 0);
  text("Controls:", 1000, screenY - 160);
    fill(50, 50, 50);
    textSize(14);
    text("Spawn Graph (O)", 1020, screenY - 140);
    fill(0, 0, 0);
    text("Modes:", 1020, screenY - 120);
      fill(25, 25, 100);
      text("Set Start (H)", 1040, screenY - 100);
      fill(175, 100, 50);
      text("Set Goal (G)", 1040, screenY - 80);
      fill(50, 100, 255);
      text("Boid (X), hold key to spawn multiple", 1040, screenY - 60);
      fill(200, 0, 0);
      text("Obstacle (P), (M) & (N) to scale", 1040, screenY - 40);
  
  
  // Mouse UI
  if(mode == Mode.OBSTACLES){
    fill(200, 100, 100);
    circle(mouseX, mouseY, obstacleRadius * 2);
  } else if (mode == Mode.BOIDS) {
    fill(50, 100, 255);
    circle(mouseX, mouseY, boidRadius);
  } else if (mode == Mode.START) {
    fill(25, 25, 100);
    square(mouseX, mouseY, 20);
  }else if (mode == Mode.GOAL) {
    fill(125, 100, 25);
    square(mouseX, mouseY, 20);
  }
}

void DrawScene() {
  // Draw Map
  pushMatrix();
  translate(0, 0, -2);
  image(map, 0, 0, screenX, screenY);
  popMatrix();
  
  // Draw Floor
  pushMatrix();
  translate(0, 500, -780);
  rotateY(PI/2);
  scale(1000);
  shape(floor);
  popMatrix();
  
  pushMatrix();
  translate(1500, 500, -780);
  rotateY(PI/2);
  scale(1000);
  shape(floor);
  popMatrix();  
  
  // Draw Table
  pushMatrix();
  translate(700, 500, -732);
  rotateX(PI/2);
  rotateY(PI/2);
  scale(900);
  shape(table);
  popMatrix();
  
  //Background
  pushMatrix();
  translate(-5000, -5000, -1000);
  fill(0, 0, 0);
  square(0, 0, 10000);
  popMatrix();
}

// USER CONTROLS
void keyPressed(){
  if (key == 'g' || key ==  'G'){
    modeText = "Set Goal";
    mode = Mode.GOAL;
  } else if (key == 'h' || key ==  'H'){
    modeText = "Set Start";
    mode = Mode.START;
  } else if(key == 'x' || key == 'X') {
    modeText = "Spawn Boids";
    mode = Mode.BOIDS;
    // if users hold s key, boids are continously spawned
    for(int i=0; i<20; i++){
      boids.add(new Boid());
    }
  } else if(key == 'p' || key == 'P'){
    modeText = "Spawn Obstacles";
    mode = Mode.OBSTACLES;
  } else if(key == 'o' || key == 'O') {
    GenerateRandomPoints();
    connections = new ArrayList<Connection>();
    for(Point point : points) {
      GenerateConnections(point);
    }
    SearchGraph();
  }
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
}

void mousePressed() {
  if (mode == Mode.OBSTACLES) {
    obstacles.add(new Obstacle());
  } else if (mode == Mode.BOIDS) {
    boids.add(new Boid());
  } else if (mode == Mode.START) {
    startPos = new PVector(mouseX,mouseY,0);  
  } else if (mode == Mode.GOAL) {
    goalPos = new PVector(mouseX,mouseY,0);  
  } 
}

void UpdateObstacle(){
  if(keyPressed == true && mode == Mode.OBSTACLES){
      if (key == 'm' || key == 'M'){
        obstacleRadius++;
      }
      if (key == 'n' || key == 'N') {
        obstacleRadius--;
      }
    }
  for(Obstacle obstacle: obstacles){
    if(keyPressed == true){
      if (key == 'l' || key == 'L'){
        obstacle.pos.add(0,-3,0);
      }
      if (key == 'K' || key == 'K'){
        obstacle.pos.add(0,3,0);
      }
      if (key == 'j' || key == 'J'){
        obstacle.pos.add(-3,0,0);
      }
      if (key == ';' || key == ':'){
        obstacle.pos.add(3,0,0);
      }
    }
  }
}
