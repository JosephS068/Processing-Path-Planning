//int screenX = 1400;
//int screenY = 1000;
//int numberOfBoids = 800;

//// obstacle
//PVector obstacleVector = new PVector(500,500,0);
//float obstacleRadius = 50;
//ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

//// start
//PVector start = new PVector(0,0,0);
//// goal
//PVector goal = new PVector(1000,900,0);

//ArrayList<Boid> boids = new ArrayList<Boid>();

//void setup() {
//  size(1400, 1000);
//}

//void spawnBoids() {
//  if(key == 's' || key == 's'){
//    boids.add(new Boid());
//  }
//}

//void spawnObstacles(){
//  if(key == 'p' || key == 'P'){
//    obstacles.add(new Obstacle());
//  }
//}

//void draw() {
//  background(200, 200, 200);
//  updateBoidsPosition();
//  drawBoids();
//  updateObstacle();
//  drawobstacle();
//}

//void updateBoidsPosition() {
//  for(Boid boid : boids) {
//    updateAcceleration(boid);
//    boid.velocity.add(boid.acceleration);
//    boid.position.add(boid.velocity);
//    for(Obstacle obstacle: obstacles){
//      if(PVector.sub(boid.position,obstacle.pos).mag() <= obstacle.radius+5){
//        if(boid.position.x > obstacle.pos.x ||boid.position.y > obstacle.pos.y){
//          boid.position = new PVector(obstacle.pos.x+obstacle.radius+5,obstacle.pos.y+obstacle.radius+5);
//        }
//        if(boid.position.x < obstacle.pos.x ||boid.position.y > obstacle.pos.y){
//          boid.position = new PVector(obstacle.pos.x-obstacle.radius-5,obstacle.pos.y+obstacle.radius+5);
//        }
//        if(boid.position.x > obstacle.pos.x ||boid.position.x < obstacle.pos.x){
//          boid.position = new PVector(obstacle.pos.x+obstacle.radius+5,obstacle.pos.y-obstacle.radius-5);
//        }
//        if(boid.position.x > obstacle.pos.x ||boid.position.x < obstacle.pos.x){
//          boid.position = new PVector(obstacle.pos.x+obstacle.radius+5,obstacle.pos.y-obstacle.radius-5);
//        }
//        boid.velocity = new PVector(-boid.velocity.x, -boid.velocity.y);
//      }
//    }
//  }
//}

//void updateAcceleration(Boid currentBoid) {
//  int boidsInRadius = 0;
//  int colorBoids = 0;
//  // For cohesion
//  PVector averagePosition = new PVector(0, 0);
//  // For alignment
//  PVector averageVelocity = new PVector(0, 0);
//  // For seperation
//  PVector seperation = new PVector(0, 0);
//  for(Boid boid : boids) {
//    PVector distanceBetween = PVector.sub(currentBoid.position, boid.position);
//    float distance = distanceBetween.mag();
//    if(boid != currentBoid && distance < currentBoid.effectRadius) {
//      averagePosition.add(boid.position);
//      averageVelocity.add(boid.velocity);
//      boidsInRadius++;
//      if(distance < currentBoid.effectRadius-10) {
//        PVector currentForce = new PVector(0, 0);
//        currentForce.add(currentBoid.position);
//        currentForce.sub(boid.position);
//        currentForce.normalize();
//        currentForce.div(PVector.dist(currentBoid.position, boid.position));
//        seperation.add(currentForce);
//      }
//    }
    
//    if(boid != currentBoid && distance < currentBoid.effectRadius*3) {
//      colorBoids++;
//    }
//  }
  
//  if(boidsInRadius != 0) {
//    currentBoid.acceleration = new PVector(0,0);
//    // cohesion
//    averagePosition.div(boidsInRadius);
//    averagePosition.sub(currentBoid.position);
//    averagePosition.div(100);
//    currentBoid.acceleration.add(averagePosition);
    
//    // alignment
//    averageVelocity.div(boidsInRadius);
//    averageVelocity.normalize();
//    averageVelocity.mult(currentBoid.speed);
//    averageVelocity.sub(currentBoid.velocity);
//    averageVelocity.div(8);
//    currentBoid.acceleration.add(averageVelocity);
    
//    // seperation
//    currentBoid.acceleration.add(seperation);
//  }
//  collisionCheck(currentBoid);
//  // For color change only!
//  currentBoid.colorBoids = colorBoids;
//}

//void collisionCheck(Boid boid) {
//    if(boid.position.x > screenX-50){
//      boid.acceleration.add(new PVector(-0.5, 0));
//    } else if (boid.position.x < 50) {
//      boid.acceleration.add(new PVector(0.5, 0));
//    }
    
//    if(boid.position.y  > screenY-50) {
//      boid.acceleration.add(new PVector(0, -0.5));
//    } else if (boid.position.y < 50) {
//      boid.acceleration.add(new PVector(0, 0.5));
//    }
//}

//void drawBoids() {
//  for(Boid boid : boids) {
//    PVector position = boid.position;
//    fill((boid.colorBoids*5), 100, (255 - (5 *boid.colorBoids)));
    
//    //PVector unitX = new PVector(1, 0);
//    pushMatrix();
//    translate(position.x, position.y);
//    circle(0, 0, 5);
//    //rotate(PVector.angleBetween(boid.velocity, unitX));
//    //triangle(0, -3, 0, 3, 10, 0);
//    popMatrix();
//  }
//}

//void drawobstacle(){
//  for(Obstacle obstacle: obstacles){
//    fill(200, 0, 0);
//    circle(obstacle.pos.x, obstacle.pos.y, obstacle.radius*2);
//  }
//}

//class Boid {
//  PVector position;
//  PVector velocity;
//  PVector acceleration;
//  int effectRadius = 20;
//  int speed = 1;
//  // Not used for actual calculations, just for color changing
//  int colorBoids;
  
//  Boid() {
//    this.position = new PVector(mouseX, mouseY);
//    this.velocity = new PVector(random(-2, 2), random(-2, 2));
//    this.acceleration = new PVector(0, 0);
//  }
  
//  Boid(PVector position, PVector velocity) {
//    this.position = position;
//    this.velocity = velocity;
//  }
//}

//class Obstacle{
//  PVector pos;
//  float radius;
//  Obstacle(){
//    this.pos = new PVector(mouseX,mouseY,0);
//    this.radius = 50;
//  }
//  Obstacle(PVector pos,float radius){
//    this.pos = pos;
//    this.radius = radius;
//  }
//}

//void keyPressed(){
//  spawnObstacles();
//  if (key == 'g' || key ==  'G'){
//    goal = new PVector(mouseX,mouseY,0);  
//  }
//  spawnBoids();

//}
//void keyReleased(){
//}

//void updateObstacle(){
//  for(Obstacle obstacle: obstacles){
//    if(keyPressed == true){
//      if (keyCode == UP){
//        obstacle.pos.add(0,-3,0);
//      }
//      if (keyCode == DOWN){
//        obstacle.pos.add(0,3,0);
//      }
//      if (keyCode == LEFT){
//        obstacle.pos.add(-3,0,0);
//      }
//      if (keyCode == RIGHT){
//        obstacle.pos.add(3,0,0);
//      }
//    }
//  }
//}
