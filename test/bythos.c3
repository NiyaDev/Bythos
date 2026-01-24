
//import bythos;
import std::io;
import sdl3;


/*
fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  Mesh m = mesh::new(CUBE);
  m.material.shader = shader::compile();
  io::printfn("%d",m.material.shader.id);

  while (!bythos::should_close()) {
    bythos::draw();

    m.draw(scale:{2,1.5,1});

    sdl3::gl_swap_window(bythos.window);
  }
  assert(false, "reached end");
}
*/


//import bythos;
import std::math;
import opengl::gl;

fn void raw_gl() @test {
  int res;

  // Init SDL3
  if (!sdl3::init(sdl3::INIT_VIDEO | sdl3::INIT_AUDIO))
    { debug::fatal("Failed to initialize SDL3.", sdl3::get_error()); }
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MAJOR_VERSION, 4);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MINOR_VERSION, 1);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_PROFILE_MASK, sdl3::CONTEXT_PROFILE_CORE);

  // Create window
  SDL_Window* window = sdl3::create_window("BYTHOS", 1280, 720, sdl3::WINDOW_OPENGL);
  if (window == null)
    { debug::fatal("Failed to create SDL3 window.", sdl3::get_error()); }

  // Create OpenGL context
  SDL_GLContext* context = sdl3::gl_create_context(window);
  if (context == null)
    { debug::fatal("Failed to create OpenGL context.", sdl3::get_error()); }
  if (!sdl3::gl_make_current(window, context))
    { debug::fatal("Failed to make GLcontext current.", sdl3::get_error()); }
  int? result = opengl::init((gl::GLLoadFn)&sdl3::gl_get_proc_address);
  if (catch result)
    { debug::fatal("Failed to initialize OpenGL functions."); }

  // Enable depth testing
  gl::enable(gl::GL_DEPTH_TEST);
  gl::enable(gl::GL_BLEND);
  gl::blendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

  Shader ourShader = shader::compile(VS,FS);
  Vertex[] vert = {
    {{ 0.5, 0.5, 0.0}, {}, {1,1}, {}},
    {{ 0.5,-0.5, 0.0}, {}, {1,0}, {}},
    {{-0.5,-0.5, 0.0}, {}, {0,0}, {}},
    {{-0.5, 0.5, 0.0}, {}, {0,1}, {}},
  };
  Indices[] inds = {
    {0,1,3},
    {1,2,3},
  };
  uint vbo, vao, ebo;
  gl::genVertexArrays(1, &vao);
  gl::genBuffers(1, &vbo);
  gl::genBuffers(1, &ebo);

  gl::bindVertexArray(vao);
  gl::bindBuffer(gl::GL_ARRAY_BUFFER, vbo);
  gl::bufferData(gl::GL_ARRAY_BUFFER, vert.len * Vertex.sizeof, vert, gl::GL_STATIC_DRAW);
  
  gl::bindVertexArray(ebo);
  gl::bindBuffer(gl::GL_ELEMENT_ARRAY_BUFFER, vbo);
  gl::bufferData(gl::GL_ELEMENT_ARRAY_BUFFER, inds.len * Indices.sizeof, inds, gl::GL_STATIC_DRAW);
  
  gl::vertexAttribPointer(0, 3, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, mesh::VERTEX_POSITION);
  gl::enableVertexAttribArray(0);
  gl::vertexAttribPointer(1, 3, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, mesh::VERTEX_NORMAL);
  gl::enableVertexAttribArray(1);
  gl::vertexAttribPointer(2, 2, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, mesh::VERTEX_TEXCOORD);
  gl::enableVertexAttribArray(2);
  gl::vertexAttribPointer(3, 4, gl::GL_FLOAT, gl::GL_FALSE, Vertex.sizeof, mesh::VERTEX_COLOR);
  gl::enableVertexAttribArray(3);

  while (true) {
    SDL_Event event;
    sdl3::poll_event(&event);
    if (event.type == QUIT) return;

    gl::clearColor(0.2, 0.3, 0.3, 1);
    gl::clear(gl::GL_COLOR_BUFFER_BIT);

    gl::useProgram(ourShader.id);
    //ourShader.set_uniform("view", &&camera::get_matrix());
    //ourShader.set_uniform("model", &&MATRIX4F_IDENTITY);
    Matrix4f mat = MATRIX4F_IDENTITY;
    ourShader.set_uniform("transform", &mat);

    gl::bindVertexArray(vao);
    gl::drawElements(gl::GL_TRIANGLES, 6, gl::GL_UNSIGNED_INT, null);

    sdl3::gl_swap_window(window);
  } 
}

const char[] VS =
  "#version 330 core\n"
  "layout (location = 0) in vec3 aPos;\n"
  "layout (location = 1) in vec2 aTexCoord;\n\n"
  "out vec2 TexCoord;\n\n"
  "uniform mat4 transform;\n\n"
  "void main() {\n"
  "	 gl_Position = transform * vec4(aPos, 1.0);\n"
  "  TexCoord = vec2(aTexCoord.x, aTexCoord.y);\n"
  "}\n";

const char[] FS =
  "#version 330 core\n"
  "out vec4 FragColor;\n\n"

  "in vec2 TexCoord;\n\n"

  "uniform sampler2D texture1;\n"
  "uniform sampler2D texture2;\n\n"

  "void main() {\n"
	"  FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);\null"
  "}\n";

