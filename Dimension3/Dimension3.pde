int screenX = 1400;
int screenY = 1000;
int screenZ = 1000;

String modeText = "No Mode Selected";
Mode mode = Mode.NONE;

boolean mechanicDraw = true;

PShape wasp;
PShape tree;
PShape flowers;

enum Mode
{
    NONE, GOAL, START, BOIDS, OBSTACLES
};

void setup() {
  size(1400, 1000, P3D);
  camera = new Camera();
  wasp = loadShape("Wasp.obj");
  tree = loadShape("Tree1.obj");
  flowers = loadShape("Flowers.obj");
}

void draw() {
  background(20, 100, 200);
  UpdateBoidsPosition();
  UpdateObstacle();
  DrawBoids();
  DrawObstacle();
  DrawPoints();
  if(mechanicDraw == true) {
    DrawConnections();
  }  
  DrawUI();
  DrawScene();
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
  if (mode == Mode.START) {
    fill(25, 25, 100);
    square(mouseX, mouseY, 20);
  }else if (mode == Mode.GOAL) {
    fill(125, 100, 25);
    square(mouseX, mouseY, 20);
  }
}

void DrawScene() {
  fill(0, 150, 70);
  pushMatrix();
  translate(-5000, 900 ,-5000);
  rotateX(PI/2);
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
    for(int i=0;i<100;i++){
      boids.add(new Boid());
    }
  } else if(key == 'p' || key == 'P'){
    modeText = "Spawn Obstacles";
    mode = Mode.OBSTACLES;
    obstacles.add(new Obstacle());
  } else if(key == 'o' || key == 'O') {
    GenerateRandomPoints();
    connections = new ArrayList<Connection>();
    for(Point point : points) {
      GenerateConnections(point);
    }
    SearchGraph();
  } else if(key == 'b' || key == 'B') {
    mechanicDraw = !mechanicDraw;
  }
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
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
  //for(Obstacle obstacle: obstacles){
  //  if(keyPressed == true){
  //    if (keyCode == UP){
  //      obstacle.pos.add(0,-3,0);
  //    }
  //    if (keyCode == DOWN){
  //      obstacle.pos.add(0,3,0);
  //    }
  //    if (keyCode == LEFT){
  //      obstacle.pos.add(-3,0,0);
  //    }
  //    if (keyCode == RIGHT){
  //      obstacle.pos.add(3,0,0);
  //    }
  //  }
  //}
}
