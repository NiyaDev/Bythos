
module bythos;
import std::collections, std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Constants -- *//
const String VERSION @export("version") = "0.1.0-Foundation";
const usz MAX_MOUSE_BUTTONS =   8;
const usz MAX_KEYBOARD_KEYS = 512;
const usz MAX_KEY_QUEUE     =  16;

//* -- Globals -- *//
Bythos core @export("core");

//* -- Structs -- *//
struct Bythos {
  SdlWindow* window;
  SdlGLContext context;

  Vec2i display, screen, render;

  //* -- Framebuffer -- *//
  uint framebuffer, renderbuffer;
  Mesh quad;
  Texture frameTexture;
  Shader frameShader;

  Shader defaultShader2d, defaultShader3d;
  Texture defaultTexture;
  Mesh defaultMesh, textureMesh;
  Material defaultMaterial;

  struct time {
    double deltaTime, lastFrame;
    double targetFrametime;
  }
  struct gpu {
    String vendor, renderer, version, glsl;
    int shaderBinaries;
  }
  struct input {
    struct keyboard {
      Keybind exitKey;

      bool[MAX_KEYBOARD_KEYS] currentKeyState;
      bool[MAX_KEYBOARD_KEYS] previousKeyState;
      bool[MAX_KEYBOARD_KEYS] repeatKeyState;

      int[MAX_KEY_QUEUE] keyPressedQueue;
      int[MAX_KEY_QUEUE] charPressedQueue;
    }
    struct mouse {
      Vec2f currentPosition, previousPosition;
      Vec2f delta;
      float currentWheel, previousWheel;
      bool[MAX_MOUSE_BUTTONS] currentState;
      bool[MAX_MOUSE_BUTTONS] previousState;

      bool isHidden;
      bool isLocked;
      bool isOnscreen;
    }
    //struct touch {}
    //struct gamepad {}
  }
  //struct storage {}
}

//* -- Functions -- *//
fn void init() @export("bythos_init") {
  debug::info("Initializing Bythos version", VERSION);

  //* -- Loading Options -- *//
  OptionsList options = options::load_all("resources/options.toml");
  core.screen = {
    options.has_key("screen_width")  ? (int)options["screen_width"]!!.i  : 1280,
    options.has_key("screen_height") ? (int)options["screen_height"]!!.i :  720,
  };
  if (options.has_key("render_resolution"))
    { core.render = (Vec2i)((Vec2f)core.screen * (float)options["render_resolution"]!!.f); }
  else { core.render = core.screen; }
  core.time.targetFrametime = 1000 / (double)(options.has_key("framespersecond") ? options["framespersecond"]!!.i : 60);

  //* -- SDL3 -- *//
  if (!sdl3::init({.video = true, .audio = true})) 
    { debug::fatal("Failed to initialize SDL3", sdl3::getError()); }
  sdlgl::setAttribute(CONTEXT_MAJOR_VERSION, 3);
  sdlgl::setAttribute(CONTEXT_MINOR_VERSION, 3);
  sdlgl::setAttribute(CONTEXT_PROFILE_MASK, (int)sdlgl::CONTEXT_PROFILE_CORE);
  core.window = sdl3::createWindow("BYTHOS", core.screen.x, core.screen.y, {.opengl = true});
  if (!core.window) debug::fatal("Failed to create SDL3 window", sdl3::getError());
  SdlRect r;
  sdl3::getDisplayBounds(sdl3::getDisplayForWindow(core.window), &r);
  core.display = {r.w, r.h};

  //* -- OpenGL -- *//
  core.context = sdlgl::createContext(core.window);
  if (!core.context) debug::fatal("Failed to create OpenGL context", sdl3::getError());
  if (!sdlgl::makeCurrent(core.window, core.context)) debug::fatal("Failed to make GLContext current", sdl3::getError());
  int? result = opengl::init((gl::GLLoadFn)&sdlgl::getProcAddress);
  if (catch result) debug::fatal("Failed to load OpenGL functions");
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
  gl::enable((GLenum)gl::GL_BLEND);
  gl::blendFunc((GLenum)gl::GL_SRC_ALPHA, (GLenum)gl::GL_ONE_MINUS_SRC_ALPHA);

  //* -- Screen Info -- *//
  debug::info("Display device initialized successfully");
  debug::info(string::tformat("  > Display resolution: %d x %d", core.display.x, core.display.y));
  debug::info(string::tformat("  > Screen resolution:  %d x %d", core.screen.x, core.screen.y));
  debug::info(string::tformat("  > Render resolution:  %d x %d", core.render.x, core.render.y));

  //* -- Display Driver Info -- *//
  core.gpu.vendor   = ((ZString)gl::getString((GLenum)gl::GL_VENDOR)).str_view();
  core.gpu.renderer = ((ZString)gl::getString((GLenum)gl::GL_RENDERER)).str_view();
  core.gpu.version  = ((ZString)gl::getString((GLenum)gl::GL_VERSION)).str_view();
  core.gpu.glsl     = ((ZString)gl::getString((GLenum)gl::GL_SHADING_LANGUAGE_VERSION)).str_view();
  gl::getIntegerv((GLenum)gl::GL_NUM_PROGRAM_BINARY_FORMATS, &core.gpu.shaderBinaries);

  debug::info("OpenGL device information");
  debug::info(string::tformat("  > Vendor:    %s", core.gpu.vendor));
  debug::info(string::tformat("  > Renderer:  %s", core.gpu.renderer));
  debug::info(string::tformat("  > Version:   %s", core.gpu.version));
  debug::info(string::tformat("  > GLSL:      %s", core.gpu.glsl));
  if (core.gpu.shaderBinaries) { debug::info("  > Compiled Shader binaries supported"); }

  //* -- Defaults -- *//
  core.defaultShader2d = shader::compile(shader::DEFAULT_VERTEX_2D, shader::DEFAULT_FRAGMENT_2D);
  core.defaultShader2d.set_vec2("screensize", (Vec2f){(float)core.render.x, (float)core.render.y});
  core.defaultShader3d = shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D);
  core.defaultShader3d.set_matrix("projection", matrix::perspective{float}(70 * (math::PI / 180), (float)core.render.x / (float)core.render.y, 0.1, 100).transpose());
  core.defaultMesh = mesh::new(CUBE);
  core.textureMesh = mesh::new(PLANE);
  core.defaultTexture = texture::load_from_memory(texture::def, "ppm");
  core.defaultMaterial = {core.defaultShader3d, {}};
  core.defaultMaterial.maps[material::DIFFUSE].texture = core.defaultTexture;
  core.input.keyboard.exitKey = {ESCAPE, UNKNOWN};
  keybinds = mem::new(HashMap{String, Keybind});
  keybinds.set("test", {K, UNKNOWN});

  //* -- Framebuffer -- *//
  core.quad = mesh::new(PLANE);
  core.frameShader = shader::compile(shader::FB_VERTEX, shader::FB_FRAGMENT);
  core.frameShader.set_int("screenTexture", 0);
  core.frameTexture = texture::new(core.render.x, core.render.y);

  gl::genFramebuffers(1, &core.framebuffer);
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, core.framebuffer);
  gl::framebufferTexture2D((GLenum)gl::GL_FRAMEBUFFER, (GLenum)gl::GL_COLOR_ATTACHMENT0, (GLenum)gl::GL_TEXTURE_2D,
                           core.frameTexture.id, 0);
  gl::genRenderbuffers(1, &core.renderbuffer);
  gl::bindRenderbuffer((GLenum)gl::GL_RENDERBUFFER, core.renderbuffer);
  gl::renderbufferStorage((GLenum)gl::GL_RENDERBUFFER, (GLenum)gl::GL_DEPTH24_STENCIL8,
                          core.render.x, core.render.y);
  gl::framebufferRenderbuffer((GLenum)gl::GL_FRAMEBUFFER,  (GLenum)gl::GL_DEPTH_STENCIL_ATTACHMENT,
                              (GLenum)gl::GL_RENDERBUFFER, core.renderbuffer);
  if (gl::checkFramebufferStatus((GLenum)gl::GL_FRAMEBUFFER) != (GLenum)gl::GL_FRAMEBUFFER_COMPLETE)
    { debug::fatal("Failed to initialize framebuffer"); }
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, 0);
}
fn void clean() @export("bythos_clean") {
  //* -- Freeing defaults -- *//
  core.defaultShader2d.clean();
  core.defaultShader3d.clean();
  core.frameShader.clean();
  core.quad.clean();
  core.frameTexture.clean();
  core.defaultMesh.clean();
  core.textureMesh.clean();
  core.defaultTexture.clean();
  core.defaultMaterial.clean();
  free(keybinds);

  //* -- SDL3 and OpenGL -- *//
  sdlgl::destroyContext(core.context);
  core.context = null;
  sdl3::destroyWindow(core.window);
  core.window = null;
  sdl3::quit();
}

fn void screenshot(String filename = "screenshot.ppm") @export("bythos_screenshot")
  => core.frameTexture.save(filename);

//* -- Benchmarks -- *//
fn void initialization() @benchmark {
  debug::set_log_level(NONE);

  bythos::init();
  bythos::clean();
}

