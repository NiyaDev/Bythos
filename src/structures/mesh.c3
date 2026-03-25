
module bythos;

//* -- Structures -- *//
struct Mesh {
  Vertex[]  vertices;
  Indices[] indices;

  uint vao, vbo, ebo;
}
struct Vertex {
  Vec3f position;
  Vec3f normal;
  Vec2f texCoord;
  Vec4f color;
}
alias Indices = uint[<3>];


module bythos::mesh;
import std::math, std::io;
import opengl::gl;
import bythos;

//* -- Enums -- *//
enum MeshType {
  TRI,
  PLANE,
  CUBE,
}

//* -- Functions -- *//
fn Mesh new(MeshType type) @export("mesh_new") {
  Mesh output;

  switch (type) {
    case TRI:
      output.vertices = mem::new_array(Vertex, BASIC_TRI.len);
      for (int i; i < BASIC_TRI.len; i++) output.vertices[i] = BASIC_TRI[i];
    case PLANE:
      output.vertices = mem::new_array(Vertex, BASIC_QUAD.len);
      for (int i; i < BASIC_QUAD.len; i++) output.vertices[i] = BASIC_QUAD[i];
    case CUBE:
      output.vertices = mem::new_array(Vertex, BASIC_CUBE.len);
      for (int i; i < BASIC_CUBE.len; i++) output.vertices[i] = BASIC_CUBE[i];
  }

  output.upload();
  debug::info(string::tformat("MESH: [ID %d] Mesh loaded successfully", output.vao));
  return output;
}
fn void Mesh.clean(&self) @export("mesh_cleanmesh") {
  debug::info(string::tformat("MESH: [ID %d] Cleaned up", self.vao));

  if (self.vertices.len > 0)
    { free(self.vertices); }
  if (self.indices.len > 0)
    { free(self.indices); }
  self.delete();
}
fn bool Mesh.is_valid(&self) @export("mesh_valid")
  => self.vao != 0;

fn void Mesh.upload(&self) {
  gl::genVertexArrays(1, &self.vao);
  gl::genBuffers(1, &self.vbo);

  gl::bindVertexArray(self.vao);
  gl::bindBuffer((GLenum)gl::GL_ARRAY_BUFFER, self.vbo);
  gl::bufferData((GLenum)gl::GL_ARRAY_BUFFER, self.vertices.len * Vertex.sizeof, self.vertices, (GLenum)gl::GL_STATIC_DRAW);
  
  gl::vertexAttribPointer(0, 3, (GLenum)gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)0);
  gl::enableVertexAttribArray(0);
  gl::vertexAttribPointer(1, 3, (GLenum)gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)12);
  gl::enableVertexAttribArray(1);
  gl::vertexAttribPointer(2, 2, (GLenum)gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)24);
  gl::enableVertexAttribArray(2);
  gl::vertexAttribPointer(3, 4, (GLenum)gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)32);
  gl::enableVertexAttribArray(3);

  if (self.indices.len > 0) {
    gl::genBuffers(1, &self.ebo);
    gl::bindBuffer((GLenum)gl::GL_ELEMENT_ARRAY_BUFFER, self.ebo);
    gl::bufferData((GLenum)gl::GL_ELEMENT_ARRAY_BUFFER, self.indices.len * Indices.sizeof, self.indices, (GLenum)gl::GL_STATIC_DRAW);
  }

  gl::bindBuffer((GLenum)gl::GL_ARRAY_BUFFER, 0);
  gl::bindVertexArray(0);
}
fn void Mesh.delete(&self) {
  gl::deleteVertexArrays(1, &self.vao);
  gl::deleteBuffers(1, &self.vbo);
  gl::deleteBuffers(1, &self.ebo);
}

fn void Mesh.draw(&self = &&bythos::get_default_mesh(), Material mat = bythos::get_default_material(), Vec3f position = {}, Vec3f scale = {1,1,1}, Vec3f rotation = {0,0,0}) @export("mesh_draw") {
  gl::useProgram(mat.shader.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, mat.maps[material::DIFFUSE].texture.id);
  mat.shader.set_matrix("view",  Camera.get_matrix());
  mat.shader.set_matrix("model", MATRIX4F_IDENTITY.translate(position).rotate_z(rotation.z).rotate_y(rotation.y).rotate_x(rotation.x).scale(scale).transpose());

  //* -- Draw -- *//
  gl::bindVertexArray(self.vao);
  if (self.indices.len == 0) {
    gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, self.vertices.len);
  } else {
    gl::bindBuffer((GLenum)gl::GL_ELEMENT_ARRAY_BUFFER, self.ebo);
    gl::drawElements((GLenum)gl::GL_TRIANGLES, self.indices.len * 3, (GLenum)gl::GL_UNSIGNED_INT, null);
  }
  gl::bindVertexArray(0);
}
fn void Mesh.draw_instanced(&self = &&bythos::get_default_mesh(), Matrix4f[] mats, Material mat = bythos::get_default_material()) @export("mesh_drawinstanced") {
  gl::useProgram(mat.shader.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, mat.maps[material::DIFFUSE].texture.id);
  mat.shader.set_matrix("view", Camera.get_matrix());

  //* -- Draw -- *//
  gl::bindVertexArray(self.vao);
  for (int i; i < mats.len; i++) {
    mat.shader.set_matrix("model", mats[i]);
    gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, self.vertices.len);
  }
  gl::bindVertexArray(0);
}

//* -- Constants -- *//
const void* VERTEX_POSITION = null;
const void* VERTEX_NORMAL   = (void*)(Vec3f.sizeof);
const void* VERTEX_TEXCOORD = (void*)((long)VERTEX_NORMAL * 2);
const void* VERTEX_COLOR    = (void*)((long)VERTEX_TEXCOORD + Vec2f.sizeof);

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

