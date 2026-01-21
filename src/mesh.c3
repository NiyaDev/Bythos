
module bythos::mesh;
import bythos::material;


struct Mesh {
  //Vertex[] vertices;
  //Indices[] indices;

  uint vao, vbo;

  Material material;
}
