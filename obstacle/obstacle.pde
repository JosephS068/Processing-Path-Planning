int screenX = 1400;
int screenY = 1000;
int numberOfBoids = 800;

// boids
int boidRadius = 5;

// obstacle
PVector obstacleVector = new PVector(500,500,0);
float obstacleRadius = 50;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

// start
PVector start = new PVector(100,100,0);
// goal
PVector goal = new PVector(1000,900,0);

ArrayList<Boid> boids = new ArrayList<Boid>();
String modeText = "No Mode Selected";
String mode = "None";

// Graph related variables
int pointNum = 35;
Point[] points = new Point[pointNum];
boolean pointsGenerated = false;
int maxConnectionRadius = 100;

//check points if in the obstacles
boolean[] checkPoints = new boolean[pointNum];

void setup() {
  size(1400, 1000);
}

void generateRandomPoints() {
  int i=1;
  boolean count = true;
  while(count == true){
    float x = random(100, screenX - 100);
    float y = random(100, screenY - 100);
    checkPoints[i] = true;
    PVector pos = new PVector(x,y);
    for(Obstacle obstacle: obstacles){
        if(PVector.sub(pos,obstacle.pos).mag() < obstacleRadius+10){
          println(1);
          checkPoints[i] = false;
        }
    }
    if(checkPoints[i] == true){
      points[i] = new Point(i, pos, PVector.sub(pos, goal).mag());
      i += 1;
    }
    if(i == pointNum){
      count = false;
    }
  }
  points[0] = new Point(0, start, PVector.sub(start, goal).mag());
  points[pointNum-1] = new Point(pointNum-1, goal, 0);
}

void draw() {
  background(200, 200, 200);
  updateBoidsPosition();
  drawBoids();
  updateObstacle();
  drawobstacle();
  drawUI();
  if(pointsGenerated == true) {
    drawPoints();
  }
}

void updateBoidsPosition() {
  for(Boid boid : boids) {
    updateAcceleration(boid);
    boid.velocity.add(boid.acceleration);
    PVector nextPos = new PVector(boid.position.x, boid.position.y);
    nextPos.add(boid.velocity);
    for(Obstacle obstacle: obstacles){
      // Handle direct collision
      if(PVector.sub(nextPos, obstacle.pos).mag() <= obstacle.radius+2){
        boid.velocity = new PVector(-boid.velocity.x, -boid.velocity.y);
      }
    }
    boid.position.add(boid.velocity);
  }
}

void updateAcceleration(Boid currentBoid) {
  int boidsInRadius = 0;
  int colorBoids = 0;
  // For cohesion
  PVector averagePosition = new PVector(0, 0);
  // For alignment
  PVector averageVelocity = new PVector(0, 0);
  // For seperation
  PVector seperation = new PVector(0, 0);
  for(Boid boid : boids) {
    PVector distanceBetween = PVector.sub(currentBoid.position, boid.position);
    float distance = distanceBetween.mag();
    if(boid != currentBoid && distance < currentBoid.effectRadius) {
      averagePosition.add(boid.position);
      averageVelocity.add(boid.velocity);
      boidsInRadius++;
      if(distance < currentBoid.effectRadius-10) {
        PVector currentForce = new PVector(0, 0);
        currentForce.add(currentBoid.position);
        currentForce.sub(boid.position);
        currentForce.normalize();
        currentForce.div(PVector.dist(currentBoid.position, boid.position));
        seperation.add(currentForce);
      }
    }
    
    if(boid != currentBoid && distance < currentBoid.effectRadius*3) {
      colorBoids++;
    }
  }
  
  if(boidsInRadius != 0) {
    currentBoid.acceleration = new PVector(0,0);
    // cohesion
    averagePosition.div(boidsInRadius);
    averagePosition.sub(currentBoid.position);
    averagePosition.div(100);
    currentBoid.acceleration.add(averagePosition);
    
    // alignment
    averageVelocity.div(boidsInRadius);
    averageVelocity.normalize();
    averageVelocity.mult(currentBoid.speed);
    averageVelocity.sub(currentBoid.velocity);
    averageVelocity.div(8);
    currentBoid.acceleration.add(averageVelocity);
    
    // seperation
    currentBoid.acceleration.add(seperation);
  }
  collisionCheck(currentBoid);
  // For color change only!
  currentBoid.colorBoids = colorBoids;
}

void collisionCheck(Boid boid) {
    if(boid.position.x > screenX-50){
      boid.acceleration.add(new PVector(-0.5, 0));
    } else if (boid.position.x < 50) {
      boid.acceleration.add(new PVector(0.5, 0));
    }
    
    if(boid.position.y  > screenY-50) {
      boid.acceleration.add(new PVector(0, -0.5));
    } else if (boid.position.y < 50) {
      boid.acceleration.add(new PVector(0, 0.5));
    }
}

void drawBoids() {
  for(Boid boid : boids) {
    PVector position = boid.position;
    fill((boid.colorBoids*5), 100, (255 - (5 *boid.colorBoids)));
    pushMatrix();
    translate(position.x, position.y);
    circle(0, 0, boidRadius);
    popMatrix();
  }
}

void drawobstacle(){
  for(Obstacle obstacle: obstacles){
    fill(200, 0, 0);
    circle(obstacle.pos.x, obstacle.pos.y, obstacle.radius*2);
  }
}

void drawPoints(){
  for(Point point: points) {
    pushMatrix();
    translate(point.pos.x, point.pos.y);
    if(point.id == 0){
      fill(50, 50, 200);
      square(0, 0, 20);
    } else if(point.id == pointNum-1) {
      fill(250, 200, 50);
      square(0, 0, 20);
    } else {
      fill(50, 200, 50);
      square(0, 0, 20);
    }
    popMatrix();
  }
}

void drawConnection(Connection connection) {
  PVector pos1 = connection.firstPoint.pos;
  PVector pos2 = connection.secondPoint.pos;
  if(connection.visited) {
    strokeWeight(4);
    fill(100,0,200);
  } else {
    strokeWeight(1);
    fill(0,0,0);
  }
  line(pos1.x,199,pos1.z,
        pos2.x,199,pos2.z);
  strokeWeight(1);
}

void drawUI() {
  switch(mode) {
   case "obstacles" :
      fill(200, 0, 0);
      break;
   case "boids" :
      fill(50, 100, 255);
      break;
   default :
      fill(255, 255, 255);
  }
  textSize(16);
  text(modeText, 20, screenY- 30);
  
  if(mode.equals("obstacles")){
    fill(200, 100, 100);
    circle(mouseX, mouseY, obstacleRadius * 2);
  } else if (mode.equals("boids")) {
    fill(50, 100, 255);
    circle(mouseX, mouseY, boidRadius);
  }
}

void keyPressed(){
  if (key == 'g' || key ==  'G'){
    goal = new PVector(mouseX,mouseY,0);  
  } else if(key == 's' || key == 'S') {
    modeText = "Spawn Boids";
    mode = "boids";
    // if users hold s key, boids are continously spawned
    boids.add(new Boid());
  } else if(key == 'p' || key == 'P'){
    modeText = "Spawn Obstacles";
    mode = "obstacles";
  } else if(key == 'o' || key == 'O') {
    generateRandomPoints();
    pointsGenerated = true;
  }
}

void mousePressed() {
  if (mode.equals("obstacles")) {
    obstacles.add(new Obstacle());
  } else if (mode.equals("boids")) {
    boids.add(new Boid());
  } 
}

void keyReleased(){
}

void updateObstacle(){
  if(keyPressed == true && mode.equals("obstacles")){
      if (key == 'm' || key == 'M'){
        obstacleRadius++;
      }
      if (key == 'n' || key == 'N') {
        obstacleRadius--;
      }
    }
  for(Obstacle obstacle: obstacles){
    if(keyPressed == true){
      if (keyCode == UP){
        obstacle.pos.add(0,-3,0);
      }
      if (keyCode == DOWN){
        obstacle.pos.add(0,3,0);
      }
      if (keyCode == LEFT){
        obstacle.pos.add(-3,0,0);
      }
      if (keyCode == RIGHT){
        obstacle.pos.add(3,0,0);
      }
    }
  }
}
