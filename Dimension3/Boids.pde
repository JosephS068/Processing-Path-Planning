// VARIABLES
ArrayList<Boid> boids = new ArrayList<Boid>();
int boidRadius = 5;

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
float obstacleRadius = 60;

//
// CLASSES RELATED TO BOIDS AND OBSTACLES
//
class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  int effectRadius = 20;
  int speed = 1;
  //For graph traversing
  int pathPos = 0;
  Point destination;
  boolean fromFirst = true;
  // Not used for actual calculations, just for color changing
  int colorBoids;
  float angle = 0;
  
  Boid() {
    this.position = new PVector(startPos.x+random(10,25), startPos.y+random(10,25), startPos.z+random(10,25));
    this.velocity = new PVector(0, 0, 0);
    this.acceleration = new PVector(0, 0, 0);
    if(points.size() != 0) {
      this.destination = points.get(0);
    }
  }
}

class Obstacle{
  PVector pos;
  float radius;
  
  float modelAngle = 0;
  Obstacle(){
    float x = random(200, screenX - 300);
    float y = random(200, screenY - 300);
    float z = random(200, screenZ - 300);
    this.pos = new PVector(x,y,z);
    this.radius = obstacleRadius * random(1,3);
    modelAngle = random(2*PI);
  }
  Obstacle(PVector pos,float radius){
    this.pos = pos;
    this.radius = radius;
    modelAngle = random(2*PI);
  }
}

//
// UTILITY METHODS FOR BOIDS/OBSTACLES
//
void UpdateBoidsPosition() {
  for(Boid boid : boids) {
    UpdateAcceleration(boid);
    PVector goalDirection = GoalForce(boid); // Position updated based on graph followed
    boid.velocity.add(boid.acceleration);
    PVector nextPos = new PVector(boid.position.x, boid.position.y, boid.position.z);
    nextPos.add(boid.velocity);
    nextPos.sub(goalDirection);
    boolean collided = false;
    for(Obstacle obstacle: obstacles){
      // Handle direct collision
      if(PVector.sub(nextPos, obstacle.pos).mag() <= obstacle.radius+4){
        PVector normal = nextPos.sub(obstacle.pos);
        normal.normalize();
        normal.mult(1.1);
        boid.velocity.add(normal);
        //boid.velocity = new PVector(normal.x, normal.y);
        collided = true;
      }
    }
    // Adding boid velocity
    boid.position.add(boid.velocity);
    // Adding goal velocity
    if (!collided) {
      boid.position.sub(goalDirection);
    }
  }
}

void UpdateAcceleration(Boid currentBoid) {
  int boidsInRadius = 0;
  int colorBoids = 0;
  // For cohesion
  PVector averagePosition = new PVector(0, 0, 0);
  // For alignment
  PVector averageVelocity = new PVector(0, 0, 0);
  // For seperation
  PVector seperation = new PVector(0, 0, 0);
  for(Boid boid : boids) {
    PVector distanceBetween = PVector.sub(currentBoid.position, boid.position);
    float distance = distanceBetween.mag();
    if(boid != currentBoid && distance < currentBoid.effectRadius) {
      averagePosition.add(boid.position);
      averageVelocity.add(boid.velocity);
      boidsInRadius++;
      if(distance < currentBoid.effectRadius-10) {
        PVector currentForce = new PVector(0, 0, 0);
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
    currentBoid.acceleration = new PVector(0,0,0);
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
  // For color change only!
  currentBoid.colorBoids = colorBoids;
}

PVector GoalForce(Boid boid) {
  // No goal created yet
  if(globalPath == null) {
    return new PVector(0,0,0);
  }
  // Reached goal
  if(PVector.sub(boid.position, points.get(pointNum-1).pos).mag() < 25 && boid.destination.id == pointNum-1){
    boid.velocity = new PVector(0,0,0);
    boid.acceleration = new PVector(0,0,0);
    return new PVector(0,0,0);
  }
  
  if(PVector.sub(boid.position, boid.destination.pos).mag() < 25) {
    if(boid.destination != points.get(0)) {
      boid.pathPos++;
    }
    Connection nextConnection = globalPath.connections.get(boid.pathPos);
    if(nextConnection.firstPoint == boid.destination) {
      boid.destination = nextConnection.secondPoint;
      boid.fromFirst = true;
    } else {
      boid.destination = nextConnection.firstPoint;
      boid.fromFirst = false;
    }
  }
  
  PVector result;
  result = PVector.sub(boid.position, boid.destination.pos);

  result.normalize();
  result.mult(5);
  PVector xUnit = new PVector(1,0);
  PVector xzVector = new PVector(result.x, result.y);
  boid.angle = PVector.angleBetween(xUnit, xzVector);
  return result;
}

//
// METHODS FOR DRAWING CLASSES ON UI
//
void DrawBoids() {
  for(Boid boid : boids) {
    PVector position = boid.position;
    //fill((boid.colorBoids*5), 100, (255 - (5 *boid.colorBoids)));
    //pushMatrix();
    //translate(0, 0, position.z);
    //circle(position.x, position.y, boidRadius);
    //popMatrix();
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateX(PI);
    rotateY(boid.angle-(PI/2));
    scale(3);
    shape(wasp);
    popMatrix();
  }
}

void DrawObstacle(){
  for(Obstacle obstacle: obstacles){
    fill(200, 0, 0);
    pushMatrix();
    translate(obstacle.pos.x, obstacle.pos.y, obstacle.pos.z);
    sphere(obstacle.radius);
    popMatrix();
  }
}
