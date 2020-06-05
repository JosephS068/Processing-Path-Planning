import java.util.PriorityQueue;
Path globalPath;

// VARIABLES
ArrayList<Point> points = new ArrayList<Point>();
int pointNum = 150;

ArrayList<Connection> connections = new ArrayList<Connection>();
int maxConnectionRadius = 200;

PVector startPos = new PVector(800,500,0);
PVector goalPos = new PVector(400,500,0);

boolean useAStar = false;
int aStarAmount = 0;
int ufcAmount = 0;

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
    if(useAStar == true) {
      if((totalCost+nextPointToGoal)==(path.totalCost+path.nextPointToGoal)){
        return 0;  
      } else if((totalCost+currentPoint.distanceToGoal) > (path.totalCost+path.currentPoint.distanceToGoal)){
        return 1;  
      } else {  
        return -1;  
      } 
    } else {
      if(totalCost==path.totalCost){
        return 0;  
      } else if(totalCost>path.totalCost) {
        return 1;  
      } else {  
        return -1;  
      } 
    } 
  }
}

//
// UTILITY METHODS FOR GRAPH
//
void GenerateRandomPoints() {
  points = new ArrayList<Point>();
  points.add(new Point(0, new PVector(startPos.x, startPos.y), PVector.sub(startPos, goalPos).mag()));
  int i=1;
  while(i<pointNum-1){
    float x = random(100, screenX - 100);
    float y = random(100, screenY - 100);
    PVector pos = new PVector(x,y);
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
  points.add(new Point(pointNum-1, new PVector(goalPos.x, goalPos.y), 0));
  
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
    float vx,vy;
    vx = x2 - x1;
    vy = y2 - y1;
    float lenv = sqrt(vx*vx + vy*vy);
    vx /= lenv;
    vy /= lenv;
    
    //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle      
    float cx = obstacle.pos.x;
    float cy = obstacle.pos.y;
    float r = obstacle.radius;
    float wx,wy;      
    wx = cx - x1;
    wy = cy - y1;
    
    //Step 3: Solve quadratic equation for intersection point (in terms of V and W)
    float a = 1;
    float b = -2*(vx*wx + vy*wy);
    float c = wx*wx + wy*wy - r*r;
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
  // UNIFROM COST SEARCH Search
  ufcAmount = 0;
  PriorityQueue<Path> paths = new PriorityQueue<Path>();
  Point start = points.get(0);
  for(Connection connection : start.connections) {
    Path newPath = new Path();
    newPath.currentPoint = start;
    newPath.addConnection(connection);
    paths.add(newPath);
  }
  useAStar = false;
  globalPath = Search(paths);
  for(Connection connection : globalPath.connections) {
    connection.visited = true;
  }
  
  // A STAR SEARCH
  aStarAmount = 0;
  paths = new PriorityQueue<Path>();
  start = points.get(0);
  for(Connection connection : start.connections) {
    Path newPath = new Path();
    newPath.currentPoint = start;
    newPath.addConnection(connection);
    paths.add(newPath);
  }
  
  useAStar = true;
  globalPath = Search(paths);
  for(Connection connection : globalPath.connections) {
    connection.visited = true;
  }
  //println("---------------");
  //println(aStarAmount);
  //println(ufcAmount);
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
      if (useAStar == true) {
        aStarAmount++;
      } else {
        ufcAmount++;
      }
    }
  }
}

//
// METHODS FOR DRAWING GRAPH ON DISPLAY
//
void DrawPoints(){
  for(Point point: points) {
    pushMatrix();
    translate(point.pos.x, point.pos.y);
    rotateX(PI/2);
    if(point.id == 0){
      //fill(50, 50, 200);
      //square(0, 0, 20);
      scale(40);
      shape(tree);
    } else if(point.id == pointNum-1) {
      //fill(250, 200, 50);
      //square(0, 0, 20);
      scale(40);
      shape(chest);
    } else {
      //fill(50, 200, 50);
      //square(0, 0, 20);
      shape(tower);
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
    line(pos1.x, pos1.y, pos2.x, pos2.y);
    strokeWeight(1);
  }
}
