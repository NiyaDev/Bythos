
module bythos;

struct Mesh {
  Vertex[] vertices;
  Indices[] indices;

  uint vao, vbo, ebo;

  Material material;
}
struct Vertex {
  Vec3f position;
  Vec3f normal;
  Vec2f texCoords;
  Vec4f color;
}
alias Indices = uint[<3>];


module bythos::mesh;
import std::collections, std::io;
import opengl::gl;
import bythos, utility;

enum MeshType {
  TRI,
  PLANE,
  CUBE,
}

const void* VERTEX_POSITION = null;
const void* VERTEX_NORMAL   = (void*)(Vec3f.sizeof);
const void* VERTEX_TEXCOORD = (void*)((long)VERTEX_NORMAL * 2);
const void* VERTEX_COLOR    = (void*)((long)VERTEX_TEXCOORD + Vec2f.sizeof);

fn HashMap{String, Mesh} load(String filename) @export("mesh_load") {
  File? f = file::open(filename, "rb");
  if (catch f) { debug::warning("Failed to open mesh file.", filename); return {}; }
  
  usz? size = file::get_size(filename);
  if (catch size) { debug::warning("Failed to open mesh file.", filename); return {}; }

  char[] data = mem::new_array(char, size);
  defer free(data);
  f.read(data)!!;

  return load_from_memory((String)data, filename.to_pathobj());
}
fn HashMap{String, Mesh} load_from_memory(String data, PathObject path) @export("mesh_loadfrommem") {
  HashMap{String, Mesh} output;
  String[] lines = data.tsplit("\n");

  HashMap{String, Material} materials;

  for (int i; i < lines.len; i++) {
    String name = "";
    Mesh m;

    String[] line = lines[i].tsplit(" ");
    switch (line[0]) {
      default:
      case "#": // Comment
        continue;

      case "mtllib": // Material file
        if (materials.is_initialized())
          { debug::warning("Model file contains multiple Material files.", path.full()); continue; }
        materials = material::load(string::tformat("%s%s", path.dir, line[1]));
      case "usemtl": // Mesh material
        Material? mat = materials.get(line[1]);
        if (catch mat)
          { debug::warning("Attempted to use a mesh before loading it.", path.full()); continue; }
        m.material = mat;
      case "o": // Mesh name
        if (name != "") {
          output.set(name, m);
          name = "";
          m = {};
        } else {
          name = line[1];
        }
      case "v": // Vertex
      case "vn": // Normal
      case "vt": // Texcoord
      case "f": // Index
        continue;
    }
    debug::info(string::tformat("MESH: [ID %d] Mesh loaded successfully", m.vao));
  }
  return output;
}
fn Mesh new(MeshType type) @export("mesh_new") {
  Mesh output;

  switch (type) {
    case TRI:
      output.vertices = mem::new_array(Vertex, BASIC_TRI.len);
      for (int i; i < BASIC_TRI.len; i++) { output.vertices[i] = BASIC_TRI[i]; }
    case PLANE:
      output.vertices = mem::new_array(Vertex, BASIC_QUAD.len);
      for (int i; i < BASIC_QUAD.len; i++) { output.vertices[i] = BASIC_QUAD[i]; }
    case CUBE:
      output.vertices = mem::new_array(Vertex, BASIC_CUBE.len);
      for (int i; i < BASIC_CUBE.len; i++) { output.vertices[i] = BASIC_CUBE[i]; }
  }

  output.material = material::new();
  output.upload();

  debug::info(string::tformat("MESH: [ID %d] Mesh loaded successfully", output.vao));

  return output;
}
fn void Mesh.clean(&self, String name = "") @export("mesh_cleanmesh") {
  debug::info("Cleaning up mesh", name);
  if (self.vertices.len > 0)
    { free(self.vertices); }
  if (self.indices.len > 0)
    { free(self.indices); }
  self.delete();

  self.material.clean();
}

fn void Mesh.upload(&self) {
  gl::genVertexArrays(1, &self.vao);
  gl::genBuffers(1, &self.vbo);

  gl::bindVertexArray(self.vao);
  gl::bindBuffer(gl::GL_ARRAY_BUFFER, self.vbo);
  gl::bufferData(gl::GL_ARRAY_BUFFER, self.vertices.len * Vertex.sizeof, self.vertices, gl::GL_STATIC_DRAW);

  gl::genBuffers(1, &self.ebo);
  gl::bindBuffer(gl::GL_ELEMENT_ARRAY_BUFFER, self.ebo);
  gl::bufferData(gl::GL_ELEMENT_ARRAY_BUFFER, self.indices.len * Indices.sizeof, self.indices, gl::GL_STATIC_DRAW);
  
  gl::vertexAttribPointer(0, 3, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, VERTEX_POSITION);
  gl::enableVertexAttribArray(0);
  gl::vertexAttribPointer(1, 3, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, VERTEX_NORMAL);
  gl::enableVertexAttribArray(1);
  gl::vertexAttribPointer(2, 2, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, VERTEX_TEXCOORD);
  gl::enableVertexAttribArray(2);
  gl::vertexAttribPointer(3, 4, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, VERTEX_COLOR);
  gl::enableVertexAttribArray(3);

  gl::bindBuffer(gl::GL_ARRAY_BUFFER, 0);
  gl::bindVertexArray(0);
}
fn void Mesh.delete(&self) {
  gl::deleteVertexArrays(1, &self.vao);
  gl::deleteBuffers(1, &self.vbo);
  gl::deleteBuffers(1, &self.ebo);
}


fn void Mesh.update_positions(&self, Vec3f[] new) @export("mesh_updatepositions") {
  if (self.vertices.len != new.len)
    { debug::warning("Attempted to update mesh positions with the wrong number of values."); return; }
  for (int i; i < new.len; i++)
    { self.vertices[i].position = new[i]; }

  self.delete();
  self.upload();
}
fn void Mesh.update_normals(&self, Vec3f[] new) @export("mesh_updatenormals") {
  if (self.vertices.len != new.len)
    { debug::warning("Attempted to update mesh normals with the wrong number of values."); return; }
  for (int i; i < new.len; i++)
    { self.vertices[i].normal = new[i]; }

  self.delete();
  self.upload();
}
fn void Mesh.update_texcoords(&self, Vec2f[] new) @export("mesh_updatetexcoords") {
  if (self.vertices.len != new.len)
    { debug::warning("Attempted to update mesh texcoords with the wrong number of values."); return; }
  for (int i; i < new.len; i++)
    { self.vertices[i].texCoords = new[i]; }

  self.delete();
  self.upload();
}
fn void Mesh.update_colors(&self, Vec4f[] new) @export("mesh_updatecolors") {
  if (self.vertices.len != new.len)
    { debug::warning("Attempted to update mesh colors with the wrong number of values."); return; }
  for (int i; i < new.len; i++)
    { self.vertices[i].color = new[i]; }

  self.delete();
  self.upload();
}


const Vertex[] BASIC_TRI = {
  {{ 0.0,  0.5, 0.0}, {0,0,1}, {1,1}, {0,0,0,1}},
  {{-0.5, -0.5, 0.0}, {0,0,1}, {1,0}, {0,0,0,1}},
  {{ 0.5, -0.5, 0.0}, {0,0,1}, {0,1}, {0,0,0,1}},
};
const Vertex[] BASIC_QUAD = {
  {{-1, 1, 0}, {}, {0,1}, {0,0,0,0}},
  {{-1,-1, 0}, {}, {0,0}, {0,0,0,0}},
  {{ 1,-1, 0}, {}, {1,0}, {0,0,0,0}},

  {{-1, 1, 0}, {}, {0,1}, {0,0,0,0}},
  {{ 1,-1, 0}, {}, {1,0}, {0,0,0,0}},
  {{ 1, 1, 0}, {}, {1,1}, {0,0,0,0}},
};
const Vertex[] BASIC_CUBE = {
  // Back
  {{-0.5, -0.5, -0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{ 0.5, -0.5, -0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{ 0.5,  0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{ 0.5,  0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{-0.5,  0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{-0.5, -0.5, -0.5},{0,0,1},{0,0},{0,0,0,1}},
  // Front
  {{-0.5, -0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{ 0.5, -0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{-0.5,  0.5,  0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{-0.5, -0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  // Left
  {{-0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{-0.5,  0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{-0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{-0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{-0.5, -0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{-0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  // Right
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{ 0.5,  0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{ 0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{ 0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{ 0.5, -0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  // Bottom
  {{-0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{ 0.5, -0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{ 0.5, -0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{ 0.5, -0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{-0.5, -0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{-0.5, -0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  // Top
  {{-0.5,  0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
  {{ 0.5,  0.5, -0.5},{0,0,1},{1,1},{0,0,0,1}},
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{ 0.5,  0.5,  0.5},{0,0,1},{1,0},{0,0,0,1}},
  {{-0.5,  0.5,  0.5},{0,0,1},{0,0},{0,0,0,1}},
  {{-0.5,  0.5, -0.5},{0,0,1},{0,1},{0,0,0,1}},
};


