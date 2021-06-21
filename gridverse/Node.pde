class Edge {
  PVector connection;
  Node to;
  
  Edge(PVector _connection, Node node) {
    connection = _connection;
    to = node;
  }
}

class Node {
  
  Edge[] edges;
  
  PVector displayPos;
  
  Node(float x, float y) {
    displayPos = new PVector(x, y);
    edges = new Edge[0];
  }
  
  Node(float x, float y, float z) {
    displayPos = new PVector(x, y, z);
    edges = new Edge[0];
  }
  
  void addEdge(PVector connection, Node node) {
    Edge[] newEdges = new Edge[edges.length + 1];
    newEdges[0] = new Edge(connection, node);
    for (int i = 0; i < edges.length; i++) {
      newEdges[i + 1] = edges[i];
    }
    
    edges = newEdges;
  } 
  
  void displayNode() {
    noStroke();
    fill(200, 10, 40);
    // circle(displayPos.x, displayPos.y, displayDis/2);
    pushMatrix();
    translate(displayPos.x, displayPos.y, displayPos.z);
    sphere(displayDis / 4);
    popMatrix();
  }
  
  void displayEdges() {
    stroke(150);
    strokeWeight(1);
    for (int i = 0; i < edges.length; i++) {
      // line(displayPos.x, displayPos.y, edges[i].to.displayPos.x, edges[i].to.displayPos.y);
      line(displayPos.x, displayPos.y, displayPos.z, edges[i].to.displayPos.x, edges[i].to.displayPos.y, edges[i].to.displayPos.z);
    }
  }
}