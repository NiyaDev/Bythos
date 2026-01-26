
module bythos::mesh;
import std::io;
import std::collections;
import std::math;
import opengl::gl;
import bythos::vector;
import bythos::material;
import bythos::camera;
import bythos::debug;


struct Mesh {
  Vertex[] vertices;
  Indices[] indices;

  uint vao, vbo;

  Material material;
}
struct Vertex {
  Vec3f position;
  Vec3f normal;
  Vec2f texCoords;
  Vec4f color;
  //Vec4f tangents;
  //Vector2 texCoords2;
}
alias Indices = uint[<3>];
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
  if (catch f) {
    debug::error("Failed to open mesh file.", filename);
    return {};
  }
  
  usz? size = file::get_size(filename);
  if (catch size) {
    debug::error("Failed to open mesh file.", filename);
    return {};
  }

  char[] data = mem::new_array(char, size);
  return load_from_memory((String)data);
}
fn HashMap{String, Mesh} load_from_memory(String data) @export("mesh_loadfrommem") {
  HashMap{String, Mesh} list;
  String[] lines = data.tsplit("\n");

  String lastMember;
  usz lastVertexPos, lastVertexNor, lastVertexTex, lastIndices;
  usz  maxVertexPos,  maxVertexNor,  maxVertexTex;
  String materialName;
  List{Vertex} vertices;
  List{Indices} indices;

  for (int i; i < lines.len; i++) {
    String[] line = lines[i].tsplit(" ");
    switch (line[0]) {
      case "#": continue;
      case "mtllib": // Material file
        break;
      case "usemtl": // Material info
        Mesh* temp = list.get_ref(lastMember)!!;
        //temp.material.texture = line[1];
      case "o":  // Object
        // If this isn't the first object, save vertices
        if (list.len() > 0) {
          Mesh* temp = list.get_ref(lastMember)!!;
          temp.vertices = vertices.to_array(mem);
          vertices.free();
          maxVertexPos += lastVertexPos;
          maxVertexNor += lastVertexNor;
          maxVertexTex += lastVertexTex;
          lastVertexPos = 0;
          lastVertexNor = 0;
          lastVertexTex = 0;
          temp.indices = indices.to_array(mem);
          indices.free();
          lastIndices = 0;
          temp.upload();
        }
        // Create new mesh
        Mesh newMesh;
        list.set(line[1],newMesh);
        lastMember = line[1];
      case "v":  // Vertex
        if (vertices.len() <= lastVertexPos) vertices.push({{},{},{0,1},{0,0,0,1}});

        float x = line[1].to_float()!!;
        float y = line[2].to_float()!!;
        float z = line[3].to_float()!!;
        vertices[lastVertexPos].position = (Vec3f){x,y,z};
        lastVertexPos++;
      case "vn": // Normal
        if (vertices.len() <= lastVertexNor) vertices.push({{},{},{0,1},{0,0,0,1}});

        float x = line[1].to_float()!!;
        float y = line[2].to_float()!!;
        float z = line[3].to_float()!!;
        vertices[lastVertexNor].normal = (Vec3f){x,y,z};
        lastVertexNor++;
      case "vt": // TextureCoord
        if (vertices.len() <= lastVertexTex) vertices.push({{},{},{0,1},{0,0,0,1}});

        float x = line[1].to_float()!!;
        float y = line[2].to_float()!!;
        vertices[lastVertexTex].texCoords = (Vec2f){x,y};
        lastVertexTex++;
      case "f": // Indices
        if (indices.len() <= lastIndices) indices.push({});
        String[] anotherSplit1 = line[1].tsplit("/");
        String[] anotherSplit2 = line[2].tsplit("/");
        String[] anotherSplit3 = line[3].tsplit("/");
        int x = anotherSplit1[0].to_int()!! - (int)maxVertexPos - 1;
        int y = anotherSplit2[0].to_int()!! - (int)maxVertexPos - 1;
        int z = anotherSplit3[0].to_int()!! - (int)maxVertexPos - 1;

        indices[lastIndices] = {x,y,z};
        lastIndices++;
    }
  }
  Mesh* temp = list.get_ref(lastMember)!!;
  temp.vertices = vertices.to_array(mem);
  vertices.free();
  temp.indices = indices.to_array(mem);
  indices.free();
  temp.upload();

  return list;
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
  return output;
}
fn void Mesh.clean(&self) @export("mesh_cleanmesh") {
  self.delete();
  free(self.vertices);
  free(self.indices);

  // self.material.clean();
}

fn void Mesh.upload(&self) {
  gl::genVertexArrays(1, &self.vao);
  gl::genBuffers(1, &self.vbo);

  gl::bindVertexArray(self.vao);
  gl::bindBuffer(gl::GL_ARRAY_BUFFER, self.vbo);
  gl::bufferData(gl::GL_ARRAY_BUFFER, self.vertices.len * Vertex.sizeof, self.vertices, gl::GL_STATIC_DRAW);
  
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
}

fn void Mesh.draw(&self,
    Vec3f position = {},
    Vec3f scale = {1,1,1},
    Vec3f rotation = {0,0,0}) @export("mesh_draw") {
  if (self.material.shader.id != 0) {
    gl::useProgram(self.material.shader.id);
    gl::bindTexture(gl::GL_TEXTURE_2D, self.material.texture.id);

    // Set uniforms
    Matrix4f view = camera::get_matrix();
    self.material.shader.set_uniform("view", &view);
    Matrix4f model = MATRIX4F_IDENTITY
        .translate(position)
        .rotate_z(rotation.z)
        .rotate_y(rotation.y)
        .rotate_x(rotation.x)
        .scale(scale)
        .transpose();

    self.material.shader.set_uniform("model",&model);
  }

  // Draw
  gl::bindVertexArray(self.vao);
  gl::drawArrays(gl::GL_TRIANGLES, 0, self.vertices.len);
  gl::bindVertexArray(0);
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

