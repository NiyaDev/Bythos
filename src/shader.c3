
module bythos;
import std::collections, std::io, std::math;

struct Shader {
  uint id;
  List{uint} locs;
}

module bythos::shader;
import std::io;
import opengl::gl;
import bythos::debug;

fn Shader load(String v, String f) @export("shader_load") {
  char[] vs;
  char[] fs;
  if (file::exists(v)) vs = file::load_temp(v)!!;
  if (file::exists(f)) fs = file::load_temp(f)!!; 

  return compile(vs, fs);
}
fn Shader compile(char[] v = {}, char[] f = {}) @export("shader_compile") {
  int result;
  uint program = gl::createProgram();

  //* -- Vertex -- *//
  uint vertexShader = gl::createShader(gl::GL_VERTEX_SHADER);
  gl::shaderSource(vertexShader, 1, v.len > 0 ? &&((char*)v) : &&((char*)FB_VERTEX), null);
  gl::compileShader(vertexShader);
  gl::getShaderiv(vertexShader, gl::GL_COMPILE_STATUS, &result);
  if (!result) {
    char[] log = mem::new_array(char, 512);
    gl::getShaderInfoLog(vertexShader, 512, null, (char*)log);
    debug::error("SHADER: Failed to compile vertex shader\n", log);
    free(log);
  } else
    { gl::attachShader(program, vertexShader); }

  //* -- Fragment -- *//
  uint fragmentShader = gl::createShader(gl::GL_FRAGMENT_SHADER);
  gl::shaderSource(fragmentShader, 1, f.len > 0 ? &&((char*)f) : &&((char*)FB_FRAGMENT), null);
  gl::compileShader(fragmentShader);
  gl::getShaderiv(fragmentShader, gl::GL_COMPILE_STATUS, &result);
  if (!result) {
    char[] log = mem::new_array(char, 512);
    gl::getShaderInfoLog(fragmentShader, 512, null, (char*)log);
    debug::error("SHADER: Failed to compile fragment shader\n", log);
    free(log);
  } else
    { gl::attachShader(program, fragmentShader); }

  //* -- Program -- *//
  gl::linkProgram(program);
  gl::getProgramiv(program, gl::GL_LINK_STATUS, &result);
  if (!result) {
    char[] log = mem::new_array(char, 512);
    gl::getProgramInfoLog(program, 512, null, (char*)log);
    debug::error("SHADER: Failed to link shader\n", log);
    free(log);
  }
  debug::info(string::tformat("SHADER: [ID %d] Shader loaded successfully", program));

  //* -- Cleanup -- *//
  gl::deleteShader(vertexShader);
  gl::deleteShader(fragmentShader);

  return {program, {}};
}
fn void Shader.clean(&self) @export("shader_clean") {
  gl::deleteProgram(self.id);
  self.locs.free();

  debug::info(string::tformat("SHADER: [ID %s] Cleaned up", self.id));
  self.id = 0;
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
  "  vec2 pixelPos = aPos.xy * scale + position;\n"
  "  vec2 ndc = (pixelPos / screensize) * 2.0 + 1.0;\n"
  "  ndc.y = -ndc.y;\n"
  "  gl_Position = vec4(ndc, 0.0, 1.0);\n"
  "  fragUV = (aTexCoord * texScale) + texOffset;\n"
  "  Color = texColor;\n"
  "}\n";
const char[] DEFAULT_FRAGMENT_2D = 
  "#version 330 core\n"
  "out vec4 FragColor;\n\n"
  "in vec2 TexCoord;\n"
  "in vec2 fragUV;"
  "in vec4 Color;\n\n"
  "uniform sampler2D texture1;\n\n"
  "void main() {\n"
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

