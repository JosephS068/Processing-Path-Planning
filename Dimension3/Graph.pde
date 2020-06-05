import java.util.PriorityQueue;
Path globalPath;

// VARIABLES
ArrayList<Point> points = new ArrayList<Point>();
int pointNum = 50;

ArrayList<Connection> connections = new ArrayList<Connection>();
int maxConnectionRadius = 500;

PVector startPos = new PVector(200,200,200);
PVector goalPos = new PVector(800,800,800);

boolean colliding; //Are the cicle and line colliding
//
// CLASSES RELATED TO POITS AND CONNECTIONS
//
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
  float nextPointToGoal;
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
      nextPointToGoal = connection.firstPoint.distanceToGoal;
    } else {
      currentPoint = connection.firstPoint;
      nextPointToGoal = connection.secondPoint.distanceToGoal;
    }
  }
  
  int compareTo(Path path) {
    if((totalCost+nextPointToGoal)==(path.totalCost+path.nextPointToGoal)){
      return 0;  
    } else if((totalCost+currentPoint.distanceToGoal) > (path.totalCost+path.currentPoint.distanceToGoal)){
      return 1;  
    } else {  
      return -1;  
    }
  }
}

//
// UTILITY METHODS FOR GRAPH
//
void GenerateRandomPoints() {
  points = new ArrayList<Point>();
  points.add(new Point(0, new PVector(startPos.x, startPos.y, startPos.z), PVector.sub(startPos, goalPos).mag()));
  int i=1;
  while(i<pointNum-1){
    float x = random(100, screenX - 100);
    float y = random(100, screenY - 100);
    float z = random(100, screenZ - 100);
    PVector pos = new PVector(x,y,z);
    boolean validPoint = true;
    for(Obstacle obstacle: obstacles){
        if(PVector.sub(pos,obstacle.pos).mag() < obstacle.radius+10){
            validPoint = false;
        }
    }
    if(validPoint == true) {
      points.add(new Point(i, pos, PVector.sub(pos, goalPos).mag()));
      i += 1;
    }
  }
  points.add(new Point(pointNum-1, new PVector(goalPos.x, goalPos.y, goalPos.z), 0));
  
  // Update boids to start over
  for(Boid boid : boids) {
    boid.destination = points.get(0);
    boid.pathPos = 0;
  }
}

void GenerateConnections(Point currentPoint) {
  for(Point point : points) {
    if (currentPoint != point) {
      float distance = PVector.sub(currentPoint.pos, point.pos).mag();
      if(distance < maxConnectionRadius && !ConnectionExists(currentPoint, point)) {
        Connection newConnection = new Connection(currentPoint, point, distance);
        if(checkValidation(newConnection) == false){
          connections.add(newConnection);
          currentPoint.connections.add(newConnection);
          point.connections.add(newConnection);
        }
      }
    }
  }
}

boolean ConnectionExists(Point currentPoint, Point point) {
  for(Connection connection : connections) {
    if (connection.firstPoint == point && connection.secondPoint == currentPoint){
      return true;
    }
  }
  return false;
}

boolean checkValidation(Connection connection){
  for(Obstacle obstacle: obstacles){
    //Step 1: Compute V - a normalized vector pointing from the start of the linesegment to the end of the line segment
    float x1 = connection.firstPoint.pos.x;
    float x2 = connection.secondPoint.pos.x;
    float y1 = connection.firstPoint.pos.y;
    float y2 = connection.secondPoint.pos.y;
    float z1 = connection.firstPoint.pos.z;
    float z2 = connection.secondPoint.pos.z;
    float vx,vy, vz;
    vx = x2 - x1;
    vy = y2 - y1;
    vz = z2 - z1;
    float lenv = sqrt(vx*vx + vy*vy + vz*vz);
    vx /= lenv;
    vy /= lenv;
    vz /= lenv;
    
    //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle      
    float cx = obstacle.pos.x;
    float cy = obstacle.pos.y;
    float cz = obstacle.pos.z;
    float r = obstacle.radius;
    float wx,wy,wz;      
    wx = cx - x1;
    wy = cy - y1;
    wz = cz - z1;
    
    //Step 3: Solve quadratic equation for intersection point (in terms of V and W)
    float a = 1;
    float b = -2*(vx*wx + vy*wy + vz*wz);
    float c = wx*wx + wy*wy + wz*wz - r*r;
    float d = b*b - 4*a*c;
    
    colliding = false;
    if (d >= 0){
      float t = (-b - sqrt(d))/(2*a);
      if (t>0 && t<lenv){
        return true;
      }
    }
  }
  return colliding;
}

//GRAPH SEARCH
void SearchGraph() {
  PriorityQueue<Path> paths = new PriorityQueue<Path>();
  Point start = points.get(0);
  for(Connection connection : start.connections) {
    Path newPath = new Path();
    newPath.currentPoint = start;
    newPath.addConnection(connection);
    paths.add(newPath);
  }

  globalPath = Search(paths);
  for(Connection connection : globalPath.connections) {
    connection.visited = true;
  }
}

Path Search(PriorityQueue<Path> paths) {
  while(true) {
    Path currentPath = paths.poll();
    if(currentPath.currentPoint.id == pointNum-1) {
      return currentPath;
    }
    for(Connection connection : currentPath.currentPoint.connections) {
      Path newPath = new Path(currentPath);
      newPath.addConnection(connection);
      paths.add(newPath);
    }
  }
}

//
// METHODS FOR DRAWING GRAPH ON DISPLAY
//
void DrawPoints(){
  for(Point point: points) {
    pushMatrix();
    translate(point.pos.x, point.pos.y, point.pos.z);
    if(point.id == 0){
      if(mechanicDraw == true) {
        fill(50, 50, 200);
        box(20, 20, 20);
      }
      pushMatrix();
      translate(0, 800, -175);
      rotateZ(PI);
      scale(200);
      shape(tree);
      popMatrix();
    } else if(point.id == pointNum-1) {
      if(mechanicDraw == true) {
        fill(250, 200, 50);
        box(20, 20, 20);
      }
      pushMatrix();
      translate(-20, 100, 20);
      rotateZ(PI);
      scale(150);
      shape(flowers);
      popMatrix();
    } else {
      if(mechanicDraw == true) {
        fill(50, 200, 50);
        box(20, 20, 20);
      }
    }
    popMatrix();
  }
}

void DrawConnections() {
  for(Connection connection : connections) {
    PVector pos1 = connection.firstPoint.pos;
    PVector pos2 = connection.secondPoint.pos;
    if(connection.visited) {
      strokeWeight(4);
      fill(100,0,200);
    } else {
      strokeWeight(1);
      fill(0,0,0);
    }
    line(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z);
    strokeWeight(1);
  }
}
