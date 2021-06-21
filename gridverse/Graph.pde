

// might be a bit off, need to test plane and projection code
void generateEdgesFor3DEmbedding(float radius) {

  for (int i = 0; i < nodes.length; i++) {
    for (int j = 0; j < nodes[i].length; j++) {
      
      
      // get all nodes nearby
      ArrayList<Node> nearNodes = new ArrayList<Node>();

      for (int k = 0; k < nodes.length; k++) {
        for (int l = 0; l < nodes[k].length; l++) {
          boolean inRadius = PVector.dist(nodes[i][j].displayPos, nodes[k][l].displayPos) < radius;
          if ((i != k || j != l) && inRadius) {
            nearNodes.add(nodes[k][l]);
          }
        }
      }

      // then find plane
      PVector[] plane = bestFitPlane(nodes[i][j], nearNodes);
      // generate edges by projecting onto the plane
      // https://math.stackexchange.com/questions/3763054/projecting-3d-points-onto-2d-coordinate-system-of-a-plane
      // https://stackoverflow.com/questions/9605556/how-to-project-a-point-onto-a-plane-in-3d
      // first find basis vectors of plane
      
      // for first basis vector, get random and cross product it with our normal
      PVector random = PVector.random3D();
      while (plane[1].cross(random).mag() == 0) {
        random = PVector.random3D();
      }
      
      // mobius strip showcases issue, at some point the plane must flip its 'z' axis.
      // do we need a rotation for each edge as well?
      PVector basisx = plane[1].cross(random).normalize(); // how to stay consistnt?
      PVector basisy = plane[1].cross(basisx).normalize();

      for (Node node : nearNodes) {
        // project onto 3d plane
        PVector delta = PVector.sub(node.displayPos, plane[0]);
        float dist = PVector.dot(delta, plane[1]);
        PVector rp = PVector.sub(delta, PVector.mult(plane[1],dist));
        
        // left multiply rp by projection matrix to get 2d vector
        // M =  [  bx.x  bx.y  bx.z ]
        //      [  by.x  by.y  by.z ]

        PVector projVec = new PVector(PVector.dot(basisx, rp), PVector.dot(basisy, rp));
        nodes[i][j].addEdge(projVec.normalize(),node);
      }
    }
  }
}

// [0] = origin of the plane, [1] = normal of the plane
PVector[] bestFitPlane(Node center, ArrayList<Node> nodes) {
  PVector[] plane = new PVector[2];
  PVector centroid = center.displayPos;
  plane[0] = centroid;
  plane[1] = new PVector(0, 1);

  if (nodes.size() == 0) {
    return plane;
  }
  if (nodes.size() == 1) {
    plane[1] = PVector.sub(nodes.get(0).displayPos, center.displayPos).normalize();
    return plane;
  }

  // Calc full 3x3 covariance matrix, excluding symmetries:
  float xx = 0.0; 
  float xy = 0.0; 
  float xz = 0.0;
  float yy = 0.0; 
  float yz = 0.0; 
  float zz = 0.0;

  for (Node node : nodes) {
    PVector r = PVector.sub(node.displayPos, centroid);
    xx += r.x * r.x;
    xy += r.x * r.y;
    xz += r.x * r.z;
    yy += r.y * r.y;
    yz += r.y * r.z;
    zz += r.z * r.z;
  }

  float det_x = yy*zz - yz*yz;
  float det_y = xx*zz - xz*xz;
  float det_z = xx*yy - xy*xy;

  float det_max = max(det_x, det_y, det_z);
  if (det_max <= 0.0) {
    println("could not find plane of best fit, determinate 0");
    return plane; // The points don't span a plane
  }

  PVector dir = new PVector(det_x, xz*yz - xy*zz, xy*yz - xz*yy);
  if (det_max == det_y) {
    dir = new PVector(xz*yz - xy*zz, det_y, xy*xz - yz*xx);
  }
  if (det_max == det_z) {
    dir = new PVector( xy*yz - xz*yy, xy*xz - yz*xx, det_z);
  }

  plane[1] = dir.normalize();

  return plane;
}