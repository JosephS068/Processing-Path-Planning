import java.util.PriorityQueue;

PVector obstacleLocation = new PVector(0, 199, 0);
int obstacleRadius = 20;

int pointNum = 35;
Point[] points = new Point[pointNum];

PVector start = new PVector(-90,0,-90);
PVector goal = new PVector(90,0,90);

ArrayList<Connection> connections = new ArrayList<Connection>();

int maxConnectionRadius = 100;

int yValue = 200;

Agent agent;

void setup() {
  size(1000, 1000, P3D);
  camera = new Camera();
  agent = new Agent();
  generateRandomPoints();
  for(Point point : points) {
    generateConnections(point);
  }
  searchGraph();
}

void generateRandomPoints() {
  int i=1;
  while(i<pointNum-1){
    float x = random(-100,100);
    float z = random(-100,100);
    PVector pos = new PVector(x,0,z);
    float distanceFromCenter = pos.mag();
    if(distanceFromCenter > float(obstacleRadius+agent.radius)) {
      points[i] = new Point(i, pos, PVector.sub(pos, goal).mag());
      i += 1;
    }
  }
  points[0] = new Point(0, start, PVector.sub(start, goal).mag());
  points[pointNum-1] = new Point(pointNum-1, goal, 0);
}

void generateConnections(Point currentPoint) {
  for(Point point : points) {
    if (currentPoint != point) {
      float distance = PVector.sub(currentPoint.pos, point.pos).mag();
      if(distance < maxConnectionRadius && !connectionExists(currentPoint, point)) {
        Connection newConnection = new Connection(currentPoint, point, distance);
        if(validConnection(newConnection)) {
          connections.add(newConnection);
          currentPoint.connections.add(newConnection);
          point.connections.add(newConnection);
        }
      }
    }
  }
}

boolean connectionExists(Point currentPoint, Point point) {
  for(Connection connection : connections) {
    if (connection.firstPoint == point && connection.secondPoint == currentPoint){
      return true;
    }
  }
  return false;
}

boolean validConnection(Connection connection) {
  Point point1 = connection.firstPoint;
  Point point2 = connection.secondPoint;
  PVector halfPos = PVector.add(point1.pos, point2.pos);
  halfPos.mult(0.5);
  connection.alongLine.add(halfPos);
  pointsAlongLine(connection, halfPos, 2);
  for(PVector pos : connection.alongLine) {
    float distanceFromCenter = pos.mag();
    if(distanceFromCenter < float(obstacleRadius+agent.radius)) {
      return false;
    }
  }
  return true;
}

void pointsAlongLine(Connection connection, PVector halfPos, int depth) {
  if (depth != 0) {
    Point point1 = connection.firstPoint;
    Point point2 = connection.secondPoint;
    PVector pos1 = PVector.add(point1.pos, halfPos);
    PVector pos2 = PVector.add(point2.pos, halfPos);
    pos1.mult(0.5);
    pos2.mult(0.5);
    connection.alongLine.add(pos1);
    connection.alongLine.add(pos2);
    pointsAlongLine(connection, pos1, depth-1);
    pointsAlongLine(connection, pos2, depth-1);
  }
}

void searchGraph() {
  PriorityQueue<Path> paths = new PriorityQueue<Path>();
  Point start = points[0];
  for(Connection connection : start.connections) {
    if(validConnection(connection)) {
      Path newPath = new Path();
      newPath.currentPoint = start;
      newPath.addConnection(connection);
      paths.add(newPath);
    }
  }
  
  // Search
  Path toGoal = uniformCost(paths);
  agent.path = toGoal;
  agent.destination = toGoal.connections.get(0).secondPoint;
  print("Found path");
  for(Connection connection : toGoal.connections) {
    connection.visited = true;
  }
}

Path uniformCost(PriorityQueue<Path> paths) {
  while(true) {
    Path currentPath = paths.poll();
    for(Connection connection : currentPath.currentPoint.connections) {
      Path newPath = new Path(currentPath);
      newPath.addConnection(connection);
      paths.add(newPath);
      if(connection.secondPoint.id == pointNum-1 || connection.firstPoint.id == pointNum-1 ) {
        return newPath;
      }
    }
  }
}

void draw() {
  background(0, 0, 0); 
  noFill();
  updateKeyPressed();
  drawEnvironment();
  drawObstacle();
  drawAgent();
  drawPoints();
  for(Connection connection : connections){
    drawConnection(connection);
    validConnection(connection);
  }
  camera.Update(1/frameRate);
}

void drawEnvironment() {
  // Draw floor
  fill(255,255,255);
  beginShape(QUADS);
  vertex(100, 200, 100);
  vertex(100, 200, -100);
  vertex(-100, 200, -100);
  vertex(-100, 200, 100);
  endShape();
}

void drawObstacle(){
  pushMatrix();
  translate(0, obstacleLocation.y, 0);
  rotateX(PI/2);
  fill(200,50,50);
  circle(obstacleLocation.x, obstacleLocation.z, obstacleRadius*2);
  popMatrix();
  
  // Draws the distance a point cannot spawn, comment out for demo
  //pushMatrix();
  //translate(0, obstacleLocation.y+1, 0);
  //rotateX(PI/2);
  //fill(200,100,100);
  //circle(obstacleLocation.x, obstacleLocation.z, (obstacleRadius+agentRadius)*2);
  //popMatrix();
}

void drawAgent() {
  // Draw Top
  pushMatrix();
  fill(100,100,100);
  translate(0, yValue, 0);
  rotateX(PI/2);
  circle(agent.pos.x, agent.pos.z, agent.radius*2);
  popMatrix();
  
  // Draw Bottom
  pushMatrix();
  fill(100,100,100);
  translate(0, yValue-10, 0);
  rotateX(PI/2);
  circle(agent.pos.x, agent.pos.z, agent.radius*2);
  popMatrix();
  
  int sidePoints = 150;
  pushMatrix();
  translate(agent.pos.x, 0, agent.pos.z);
  for(int i=0; i<sidePoints; i++){
    float degree = 2*PI*i/sidePoints;
    float x = agent.radius * cos(degree);
    float z = agent.radius * sin(degree);
    
    float nextDegree = 2*PI*(i+1)/sidePoints;
    float xNext = agent.radius * cos(nextDegree);
    float zNext = agent.radius * sin(nextDegree);
    
    beginShape(QUADS);
    vertex(x, yValue-10, z);
    vertex(x, yValue, z);
    vertex(xNext, yValue, zNext);
    vertex(xNext, yValue-10, zNext);
    endShape();
  }
  popMatrix();
}

void drawPoints(){
  for(Point point: points) {
    pushMatrix();
    translate(point.pos.x, 200, point.pos.z);
    if(point.id == 0){
      fill(50, 50, 200);
      box(5);
    } else if(point.id == pointNum-1) {
      fill(250, 200, 50);
      box(5);
    } else {
      fill(50, 200, 50);
      box(2);
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

class Point {
  int id;
  PVector pos;
  float distanceToGoal;
  ArrayList<Connection> connections = new ArrayList<Connection>();
  
  Point (int id, PVector pos, float distanceToGoal) {
    this.id = id;
    this.pos = pos;
    this.distanceToGoal = distanceToGoal;
  } 
}

class Connection {
  Point firstPoint;
  Point secondPoint;
  ArrayList<PVector> alongLine = new ArrayList<PVector>();
  float distance;
  boolean visited;
  
  Connection (Point firstPoint, Point secondPoint, float distance) {
    this.firstPoint = firstPoint;
    this.secondPoint = secondPoint;
    this.distance = distance;
    this.visited = false;
  } 
}

class Path implements Comparable<Path>{
  ArrayList<Connection> connections = new ArrayList<Connection>();
  Point currentPoint;
  float totalCost = 0;
  Path(){}
  
  Path(Path path) {
    this.connections = new ArrayList<Connection>(path.connections);
    totalCost = path.totalCost;
    currentPoint = path.currentPoint;
  }
  
  void addConnection(Connection connection) {
    totalCost += connection.distance;
    connections.add(connection);
    if(connection.firstPoint == currentPoint) {
      currentPoint = connection.secondPoint;
    } else {
      currentPoint = connection.firstPoint;
    }
  }
  
  int compareTo(Path path) {
    if(totalCost==path.totalCost){
      return 0;  
    } else if(totalCost>path.totalCost) {
      return 1;  
    } else {  
      return -1;  
    }  
  }
}

class Agent{
  Path path;
  int connectionPos = 0;
  Point destination;
  PVector pos = new PVector(-90, 0, -90);
  int radius = 5;
  boolean fromFirst = true;
  Agent(){}
  
  void updatePosition() {
    if(PVector.sub(pos, destination.pos).mag() < 4 && destination.id == (pointNum-1)){
      return;
    }
    if(PVector.sub(pos, destination.pos).mag() < 1) {
      connectionPos++;
      Connection nextConnection = path.connections.get(connectionPos);
      if(nextConnection.firstPoint == destination) {
        destination = nextConnection.secondPoint;
        fromFirst = true;
      } else {
        destination = nextConnection.firstPoint;
        fromFirst = false;
      }
    }
    Connection connection = path.connections.get(connectionPos);
    Point firstPoint = connection.firstPoint;
    Point secondPoint = connection.secondPoint;
    PVector result;
    if(fromFirst) {
      result = PVector.sub(secondPoint.pos, firstPoint.pos);
    } else {
      result = PVector.sub(firstPoint.pos, secondPoint.pos);
    }
  
    result.normalize();
    result.mult(0.5);
    pos.add(result);
    println(PVector.sub(destination.pos, pos).mag());
    
    result.normalize();
    result.mult(0.5);
    pos.add(result);
    println(PVector.sub(destination.pos, pos).mag());
  }
}

void updateKeyPressed(){
  if(keyCode == 'p' || keyCode == 'P'){
    agent.updatePosition(); 
  }
}

void keyPressed() {
  camera.HandleKeyPressed();
}

void keyReleased() {
  camera.HandleKeyReleased();
}
