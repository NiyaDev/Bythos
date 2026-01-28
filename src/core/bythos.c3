
module bythos;
import std::math;
import sdl3;
import opengl::gl;


const String BYTHOS_VERSION @export("version") = "0.1.0-Foundation";
Bythos core;

struct Bythos {
  struct window {
    SDL_Window* sdl;
    SDL_GLContext* context;
    SDL_Event event;

    Vec2i screen, render;
    uint framebuffer, renderbuffer;
    Mesh quad;
  }
  struct time {
    double deltaTime, lastFrame;
  }

  Shader def_2d, def_3d;
  Texture def_tex;

  struct input {
    //struct keyboard {}
    struct mouse {
      Vec2f position, delta;
      float currentWheel, previousWheel;
      bool[5] currentState, previousState;

      bool isHidden;
      bool isLocked;
      bool isOnscreen;
    }
    //struct touch {}
    //struct gamepad {}
  }
}


fn void init() @export("bythos_init") {
  debug::info("Initializing Bythos", BYTHOS_VERSION);

  // Defaults
  core.window.screen = {1280, 720};
  core.window.render = {1280, 720};

  // Init SDL3
  debug::info("Initializing SDL3.");
  if (!sdl3::init(sdl3::INIT_VIDEO | sdl3::INIT_AUDIO))
    { debug::fatal("Failed to initialize SDL3.", sdl3::get_error()); }
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MAJOR_VERSION, 4);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MINOR_VERSION, 1);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_PROFILE_MASK, sdl3::CONTEXT_PROFILE_CORE);

  // Create window
  core.window.sdl = sdl3::create_window(
    "BYTHOS",
    core.window.screen.x, core.window.screen.y,
    sdl3::WINDOW_OPENGL);
  if (core.window.sdl == null)
    { debug::fatal("Failed to create SDL3 window.", sdl3::get_error()); }

  // Create OpenGL context
  debug::info("Initializing OpenGL.");
  core.window.context = sdl3::gl_create_context(core.window.sdl);
  if (core.window.context == null)
    { debug::fatal("Failed to create OpenGL context.", sdl3::get_error()); }
  if (!sdl3::gl_make_current(core.window.sdl, core.window.context))
    { debug::fatal("Failed to make GLcontext current.", sdl3::get_error()); }
  int? result = opengl::init((gl::GLLoadFn)&sdl3::gl_get_proc_address);
  if (catch result)
    { debug::fatal("Failed to initialize OpenGL functions."); }

  // Enable depth testing
  gl::enable(gl::GL_DEPTH_TEST);
  gl::enable(gl::GL_BLEND);
  gl::blendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

  // Default shaders
  debug::info("Compiling default shaders.");
  core.def_2d = shader::compile(shader::DEFAULT_VERTEX_2D, shader::DEFAULT_FRAGMENT_2D);
  core.def_2d.set_uniform("screensize", &&(Vec2f)core.window.render);
  core.def_3d = shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D);
  core.def_3d.set_uniform("projection", &&matrix::perspective{float}(
    70 * (math::PI / 180), core.window.render.ratio(), 0.1, 100).transpose());

  // Default Texture
  debug::info("loading default textures.");
  core.def_tex = texture::load_from_memory(texture::def, PPM);
  //core.def_tex = texture::load("resources/texture.png");

  // Framebuffer
  debug::info("Generating framebuffer.");
  core.window.quad = mesh::new(PLANE);
  core.window.quad.material.shader = shader::compile(shader::FB_VERTEX, shader::FB_FRAGMENT);
  core.window.quad.material.shader.set_uniform("screenTexture", &&0);

  gl::genFramebuffers(1, &core.window.framebuffer);
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.window.framebuffer);

  core.window.quad.material.texture = texture::new(core.window.render.x, core.window.render.y);
  gl::framebufferTexture2D(
    gl::GL_FRAMEBUFFER, gl::GL_COLOR_ATTACHMENT0, gl::GL_TEXTURE_2D,
    core.window.quad.material.texture.id, 0);

  gl::genRenderbuffers(1, &core.window.renderbuffer);
  gl::bindRenderbuffer(gl::GL_RENDERBUFFER, core.window.renderbuffer);
  gl::renderbufferStorage(
    gl::GL_RENDERBUFFER, gl::GL_DEPTH24_STENCIL8,
    core.window.render.x, core.window.render.y);
  gl::framebufferRenderbuffer(
    gl::GL_FRAMEBUFFER, gl::GL_DEPTH_STENCIL_ATTACHMENT,
    gl::GL_RENDERBUFFER, core.window.renderbuffer);
  if (gl::checkFramebufferStatus(gl::GL_FRAMEBUFFER) != gl::GL_FRAMEBUFFER_COMPLETE)
    { debug::fatal("Failed to initialize framebuffer."); }
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);

  // Load defaults
  // Keybinds

  debug::info("Reached end");
}
fn void clean() @export("bythos_clean") {
  debug::info("Cleaning up Bythos.");

  sdl3::gl_destroy_context(core.window.context);
  core.window.context = null;
  sdl3::destroy_window(core.window.sdl);
  core.window.sdl = null;
  core.window.event = {};
}
fn void draw() @export("bythos_draw") {
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.window.framebuffer);
  gl::enable(gl::GL_DEPTH_TEST);
  gl::viewport(0,0, core.window.render.x, core.window.render.y);

  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

  core.input.mouse.previousWheel = core.input.mouse.currentWheel;
  core.input.mouse.currentWheel = 0;
}
