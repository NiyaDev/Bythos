
module bythos::shader;
import std::io;
import std::collections;
import std::math;
import opengl::gl;
import bythos::debug;
import bythos::vector;
import bythos::texture;


struct Shader {
  uint id;
  HashMap{String, uint} locs;
}

fn Shader load(String v, String f) @export("shader_load") {
  char[] vs = file::load_temp(v)!!;
  char[] fs = file::load_temp(f)!!;

  return compile(vs,fs);
}
fn Shader compile(char[] v = {}, char[] f = {}) @export("shader_compile") {
  int res;
  uint program = gl::createProgram();

  // Vertex
  uint vertexShader = gl::createShader(gl::GL_VERTEX_SHADER);
  gl::shaderSource(
    vertexShader, 1,
    v.len > 0 ? &&((char*)v) : &&((char*)FB_VERTEX),
    null,
  );
  gl::compileShader(vertexShader);
  gl::getShaderiv(vertexShader, gl::GL_COMPILE_STATUS, &res);
  if (res == 0) {
    char[] log = mem::new_array(char, 512);
    gl::getShaderInfoLog(vertexShader, 512, null, (char*)log);
    debug::error("Failed to compile vertex shader.\n", log);
    free(log);
  } else {
    gl::attachShader(program, vertexShader);
  }

  // Fragment
  uint fragmentShader = gl::createShader(gl::GL_FRAGMENT_SHADER);
  gl::shaderSource(
    fragmentShader, 1,
    v.len > 0 ? &&((char*)f) : &&((char*)FB_FRAGMENT),
    null,
  );
  gl::compileShader(fragmentShader);
  gl::getShaderiv(fragmentShader, gl::GL_COMPILE_STATUS, &res);
  if (res == 0) {
    char[] log = mem::new_array(char, 512);
    gl::getShaderInfoLog(fragmentShader, 512, null, (char*)log);
    debug::error("Failed to compile fragment shader.\n", log);
    free(log);
  } else {
    gl::attachShader(program, fragmentShader);
  }

  // Linking
  gl::linkProgram(program);
  gl::getProgramiv(program, gl::GL_LINK_STATUS, &res);
  if (res == 0) {
    char[] log = mem::new_array(char, 512);
    gl::getProgramInfoLog(program, 512, null, (char*)log);
    debug::error("Failed to link shader.\n", log);
    free(log);
  }

  // Cleanup
  gl::deleteShader(vertexShader);
  gl::deleteShader(fragmentShader);

  return {program, {}};
}
fn void Shader.clean(&self) @export("shader_clean") {
  gl::deleteProgram(self.id);
  self.locs.free();
}
fn void Shader.set_uniform(&self, String key, any v) @export("shader_setuniform") {
  uint loc;
  if (self.locs.has_key(key)) {
    loc = self.locs[key]!!;
  } else {
    loc = gl::getUniformLocation(self.id, key);
    self.locs[key] = loc;
  }

  switch (v.type) {
    case int:
      gl::programUniform1i(self.id, loc, *(int*)v);
    case float:
      gl::programUniform1f(self.id, loc, *(float*)v);
    case Vec2f:
      Vec2f v2 = *(Vec2f*)v;
      gl::programUniform2f(self.id, loc, v2.x, v2.y);
    case Vec3f:
      Vec3f v2 = *(Vec3f*)v;
      gl::programUniform3f(self.id, loc, v2.x, v2.y, v2.z);
    case Vec4f:
      Vec4f v2 = *(Vec4f*)v;
      gl::programUniform4f(self.id, loc, v2.x, v2.y, v2.z, v2.w);
    case Matrix4f:
      gl::programUniformMatrix4fv(self.id, loc, 1, gl::GL_FALSE, (float*)v);
    case Texture:
      gl::programUniform1i(self.id, loc, ((Texture*)v).id);
    default:
      debug::error("Attempted to set uniform with unimplemented type.", v.type);
  }
}


const char[] DEFAULT_VERTEX_3D = 
  "#version 330 core\n"
  "layout (location = 0) in vec3 aPos;\n"
  "layout (location = 1) in vec3 norm;\n"
  "layout (location = 2) in vec2 aTexCoord;\n\n"
  "out vec2 TexCoord;\n\n"
  "uniform mat4 model;\n"
  "uniform mat4 view;\n"
  "uniform mat4 projection;\n\n"
  "void main() {\n"
  "  gl_Position = projection * view * model * vec4(aPos, 1.0f);\n"
  "  TexCoord = vec2(aTexCoord.x, aTexCoord.y);\n"
  "}\n";
const char[] DEFAULT_FRAGMENT_3D = 
  "#version 330 core\n"
  "out vec4 FragColor;\n\n"
  "in vec2 TexCoord;\n\n"
  "uniform sampler2D texture1;\n\n"
  "void main() {\n"
  "  FragColor = texture(texture1, TexCoord);\n"
  "}\n";

const char[] DEFAULT_VERTEX_2D = 
  "#version 330 core\n"
  "layout (location = 0) in vec3 aPos;\n"
  "layout (location = 2) in vec2 aTexCoord;\n"
  //"layout (location = 3) in vec4 aColor;\n\n"
  "out vec2 TexCoord;\n"
  "out vec2 fragUV;\n"
  "out vec4 Color;\n\n"
  "uniform vec2 screensize;\n"
  "uniform vec2 position;\n"
  "uniform vec2 scale;\n"
  "uniform vec2 texOffset;\n"
  "uniform vec2 texScale;\n"
  "uniform vec4 texColor;\n"
  "void main() {\n"
  "  vec4 scaled = (vec4(aPos, 1.0f) * vec4(scale.x, scale.y, 1.0f, 1.0f));\n"
  "  vec4 pixel_pos = (vec4(position.x, -position.y, 0.0f, 0.0f) / vec4(screensize, 1.0f, 1.0f));\n"
  "  gl_Position = scaled + pixel_pos;\n"
  "  TexCoord = vec2(aTexCoord.x, aTexCoord.y);\n"
  //"  Color = aColor;"
  "  Color = texColor;\n"
  "  fragUV = (aTexCoord * texScale) + texOffset;\n"
  "}\n";
const char[] DEFAULT_FRAGMENT_2D = 
  "#version 330 core\n"
  "out vec4 FragColor;\n\n"
  "in vec2 TexCoord;\n"
  "in vec2 fragUV;"
  "in vec4 Color;\n\n"
  "uniform sampler2D texture1;\n\n"
  "void main() {\n"
  //"  FragColor = mix(texture(texture1, fragUV), Color, 0.75);\n"
  //"  FragColor = texture(texture1, TexCoord) * Color;\n"
  "  FragColor = texture(texture1, fragUV) * Color;\n"
  "}\n";

const char[] FB_VERTEX =
  "#version 330 core\n"
  "layout (location = 0) in vec3 aPos;\n"
  "layout (location = 1) in vec3 normals;\n"
  "layout (location = 2) in vec2 aTexCoords;\n\n"
  "out vec2 TexCoords;\n\n"
  "void main() {\n"
  "  TexCoords = vec2(aTexCoords.x, aTexCoords.y);\n"
  "  gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0);\n"
  "}\n";
const char[] FB_FRAGMENT =
  "#version 330 core\n"
  "out vec4 FragColor;\n\n"
  "in vec2 TexCoords;\n\n"
  "uniform sampler2D texture0;\n\n"
  "void main() {\n"
  "  FragColor = texture(texture0, TexCoords);\n"
  "}\n";


