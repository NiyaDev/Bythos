
module bythos;
import std::collections, std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Constants -- *//
const String VERSION @export("version") = "0.1.0-Foundations";
const usz MAX_MOUSE_BUTTONS =   8;
const usz MAX_KEYBOARD_KEYS = 512;
const usz MAX_KEY_QUEUE     =  16;

//* -- Structures -- *//
struct Bythos {
  SdlWindow* window;
  SdlGLContext context;
  bool shouldclose;

  Vec2i display, screen, render;

  struct framebuffer {
    uint fb, rb;
    Texture frameTexture;
    Shader frameShader;
  }
  struct defaults {
    Shader shader2d, shader3d;
    Texture texture;
    Font font;
    Mesh mesh, textureMesh;
    Material material;
  }
  struct time {
    double deltaTime, lastFrame;
    double targetFrametime;
  }
  struct gpu {
    String vendor, renderer, version, glsl;
    int shaderBinaries;
  }
  struct input {
    HashMap{String, Keybind}* keybinds;
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
fn Bythos init() @export("bythos_init") {
  debug::info("Initializing Bythos version", VERSION);
  Bythos output;

  //* -- Loading Options -- *//
  OptionsList options = options::load_all("resources/options.toml");
  output.screen = {
    options.has_key("screen_width")  ? (int)options["screen_width"]!!.i  : 1280,
    options.has_key("screen_height") ? (int)options["screen_height"]!!.i :  720,
  };
  if (options.has_key("render_resolution"))
    { output.render = (Vec2i)((Vec2f)core.screen * (float)options["render_resolution"]!!.f); }
  else { core.render = core.screen; }
  output.time.targetFrametime = 1000 / (double)(options.has_key("framespersecond") ? options["framespersecond"]!!.i : 60);

  //* -- SDL3 -- *//
  if (!sdl3::init({.video = true, .audio = true})) 
    { debug::fatal("Failed to initialize SDL3", ((ZString)sdl3::getError()).str_view()); }
  sdlgl::setAttribute(CONTEXT_MAJOR_VERSION, 3);
  sdlgl::setAttribute(CONTEXT_MINOR_VERSION, 3);
  sdlgl::setAttribute(CONTEXT_PROFILE_MASK, (int)sdlgl::CONTEXT_PROFILE_CORE);
  output.window = sdl3::createWindow("BYTHOS", output.screen.x, output.screen.y, {.opengl = true});
  if (!output.window) debug::fatal("Failed to create SDL3 window", ((ZString)sdl3::getError()).str_view());
  SdlRect r;
  sdl3::getDisplayBounds(sdl3::getDisplayForWindow(output.window), &r);
  output.display = {r.w, r.h};

  //* -- OpenGL -- *//
  output.context = sdlgl::createContext(output.window);
  if (!output.context) debug::fatal("Failed to create OpenGL context", sdl3::getError());
  if (!sdlgl::makeCurrent(output.window, output.context)) debug::fatal("Failed to make GLContext current", ((ZString)sdl3::getError()).str_view());
  int? result = opengl::init((gl::GLLoadFn)&sdlgl::getProcAddress);
  if (catch result) debug::fatal("Failed to load OpenGL functions");
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
  gl::enable((GLenum)gl::GL_BLEND);
  gl::blendFunc((GLenum)gl::GL_SRC_ALPHA, (GLenum)gl::GL_ONE_MINUS_SRC_ALPHA);

  //* -- Screen Info -- *//
  debug::info("Display device initialized successfully");
  debug::info(string::tformat("  > Display resolution: %d x %d", output.display.x, output.display.y));
  debug::info(string::tformat("  > Screen resolution:  %d x %d", output.screen.x, output.screen.y));
  debug::info(string::tformat("  > Render resolution:  %d x %d", output.render.x, output.render.y));

  //* -- Display Driver Info -- *//
  output.gpu.vendor   = ((ZString)gl::getString((GLenum)gl::GL_VENDOR)).str_view();
  output.gpu.renderer = ((ZString)gl::getString((GLenum)gl::GL_RENDERER)).str_view();
  output.gpu.version  = ((ZString)gl::getString((GLenum)gl::GL_VERSION)).str_view();
  output.gpu.glsl     = ((ZString)gl::getString((GLenum)gl::GL_SHADING_LANGUAGE_VERSION)).str_view();
  gl::getIntegerv((GLenum)gl::GL_NUM_PROGRAM_BINARY_FORMATS, &output.gpu.shaderBinaries);

  debug::info("OpenGL device information");
  debug::info(string::tformat("  > Vendor:    %s", output.gpu.vendor));
  debug::info(string::tformat("  > Renderer:  %s", output.gpu.renderer));
  debug::info(string::tformat("  > Version:   %s", output.gpu.version));
  debug::info(string::tformat("  > GLSL:      %s", output.gpu.glsl));
  if (output.gpu.shaderBinaries) { debug::info("  > Compiled Shader binaries supported"); }

  //* -- Defaults -- *//
  output.defaults.shader2d = shader::compile(shader::DEFAULT_VERTEX_2D, shader::DEFAULT_FRAGMENT_2D);
  output.defaults.shader2d.set_vec2("screensize", (Vec2f){(float)output.render.x, (float)output.render.y});
  output.defaults.shader3d = shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D);
  output.defaults.shader3d.set_matrix("projection", matrix::perspective{float}(70 * (math::PI / 180), (float)core.render.x / (float)core.render.y, 0.1, 100).transpose());
  output.defaults.mesh = mesh::new(CUBE);
  output.defaults.textureMesh = mesh::new(PLANE);
  output.defaults.texture = texture::load_from_memory(texture::def, "ppm");
  output.defaults.font = font::load_from_texturememory(font::def, {24,24});
  output.defaults.material = {core.defaultShader3d, {}};
  output.defaults.material.maps[material::DIFFUSE].texture = core.defaultTexture;
  output.input.keyboard.exitKey = {ESCAPE, UNKNOWN};
  output.input.keybinds = mem::new(HashMap{String, Keybind});
  output.input.keybinds.set("test", {K, UNKNOWN});

  //* -- Framebuffer -- *//
  output.quad = mesh::new(PLANE);
  output.frameShader = shader::compile(shader::FB_VERTEX, shader::FB_FRAGMENT);
  output.frameShader.set_int("screenTexture", 0);
  output.frameTexture = texture::new(output.render.x, output.render.y);

  gl::genFramebuffers(1, &output.framebuffer);
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, output.framebuffer);
  gl::framebufferTexture2D((GLenum)gl::GL_FRAMEBUFFER, (GLenum)gl::GL_COLOR_ATTACHMENT0, (GLenum)gl::GL_TEXTURE_2D,
                           output.frameTexture.id, 0);
  gl::genRenderbuffers(1, &output.renderbuffer);
  gl::bindRenderbuffer((GLenum)gl::GL_RENDERBUFFER, output.renderbuffer);
  gl::renderbufferStorage((GLenum)gl::GL_RENDERBUFFER, (GLenum)gl::GL_DEPTH24_STENCIL8,
                          output.render.x, output.render.y);
  gl::framebufferRenderbuffer((GLenum)gl::GL_FRAMEBUFFER,  (GLenum)gl::GL_DEPTH_STENCIL_ATTACHMENT,
                              (GLenum)gl::GL_RENDERBUFFER, output.renderbuffer);
  if (gl::checkFramebufferStatus((GLenum)gl::GL_FRAMEBUFFER) != (GLenum)gl::GL_FRAMEBUFFER_COMPLETE)
    { debug::fatal("Failed to initialize framebuffer"); }
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, 0);

  return output;
}

