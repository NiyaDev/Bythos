
module bythos;
import std::collections, std::io;
import sdl3;
import opengl::gl;

// Constants
const String VERSION @export("version") = "0.1.0-Foundation";
const usz MAX_MOUSE_BUTTONS =   8;
const usz MAX_KEYBOARD_KEYS = 512;
const usz MAX_KEY_QUEUE     =  16;

// Globals
Bythos core;

// Struct
struct Bythos {
  sdl3::Window* window;
  sdl3::GLContext* context;

  Vec2i display, screen, render;
  uint framebuffer, renderbuffer;
  //Mesh quad;

  Shader defaultShader2d, defaultShader3d;

  struct time {
    double deltaTime, lastFrame;
  }
  struct input {
    struct keyboard {
      int exitKey;

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

// Functions
fn void init() @export("bythos_init") {
  debug::info("Initializing Bythos version", VERSION);

  //* -- Loading options -- *//
  HashMap{String, Option} options = load_all_options("resources/options.toml") ?? {};
  // Screen resolution
  if (options.has_key("screen_width") && options.has_key("screen_height"))
    { core.screen = {options.as_uint("screen_width"), options.as_uint("screen_height")}; }
  else { core.screen = {1280, 720}; }
  // Render resolution
  if (options.has_key("render_resolution")) {
    float res = options.as_float("render_resolution");
    core.render = {(int)(core.screen.x * res), (int)(core.screen.y * res)};
  } else { core.screen = {1280, 720}; }
  // Keybinds
  keybinds = mem::new(HashMap{String, Keybind});
  keybinds.set("test", {Scancode.A, Scancode.UNKNOWN});
  
  //* -- SDL3 -- *//
  if (!sdl3::init({.video = true, .audio = true}))
    { debug::fatal("Failed to initialize SDL3", sdl3::getError()); }
  sdlgl::setAttribute(GLAttr.CONTEXT_MAJOR_VERSION, 4);
  sdlgl::setAttribute(GLAttr.CONTEXT_MINOR_VERSION, 1);
  sdlgl::setAttribute(GLAttr.CONTEXT_PROFILE_MASK, sdlgl::CONTEXT_PROFILE_CORE);
  // Window
  core.window = sdl3::createWindow("BYTHOS", core.screen.x, core.screen.y, {.opengl = true});
  if (!core.window) debug::fatal("Failed to create SDL3 window", sdl3::getError());
  Rect r;
  sdl3::getDisplayBounds(sdl3::getDisplayForWindow(core.window), &r);
  core.display = {r.w, r.h};

  //* -- OpenGL -- *//
  core.context = sdlgl::createContext(core.window);
  if (!core.context) debug::fatal("Failed to create OpenGL context", sdl3::getError());
  if (!sdlgl::makeCurrent(core.window, core.context)) debug::fatal("Failed to make GLContext current", sdl3::getError());
  int? result = opengl::init((gl::GLLoadFn)&sdlgl::getProcAddress);
  if (catch result) debug::fatal("Failed to load OpenGL functions");
  gl::enable(gl::GL_DEPTH_TEST);
  gl::enable(gl::GL_BLEND);
  gl::blendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

  //* -- Screen Info -- *//
  debug::info("Display device initialized successfully");
  debug::info(string::tformat("  > Display resolution: %d x %d", core.display.x, core.display.y));
  debug::info(string::tformat("  > Screen resolution:  %d x %d", core.screen.x, core.screen.y));
  debug::info(string::tformat("  > Render resolution:  %d x %d", core.render.x, core.render.y));

  //* -- Defaults -- *//
  // Shaders
  //int supported;
  //gl::getIntegerv(gl::GL_NUM_PROGRAM_BINARY_FORMATS, &supported);
  
  //if (!file::exists("resources/shader_2d")) {
    set_default_shader2d(shader::compile(shader::DEFAULT_VERTEX_2D, shader::DEFAULT_FRAGMENT_2D));

  //  int length;
  //  int format;
  //  gl::getProgramiv(core.defaultShader2d.id, gl::GL_PROGRAM_BINARY_LENGTH, &length);
  //  char[] data = mem::new_array(char, length);
  //  gl::getProgramBinary(core.defaultShader2d.id, length, null, (GLenum*)&format, data);
  //  File f = file::open("resources/shader_2d", "wb")!!;
  //  f.write(data)!!;
  //  f.close()!!;
  //  io::printfn("%d",format);
  //}
  //if (!file::exists("resources/shader_3d"))
    { set_default_shader3d(shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D)); }
}
fn void clean() @export("bythos_clean") {
  debug::info("Cleaning up Bythos");

  //* -- Defaults -- *//
  // Keybindings
  keybinds.free();
  free(keybinds);
  // Shaders
  core.defaultShader2d.clean();
  core.defaultShader3d.clean();

  //* -- SDL3 and OpenGL -- *//
  sdlgl::destroyContext(core.context);
  core.context = null;
  sdl3::destroyWindow(core.window);
  core.window = null;
  sdl3::quit();
}

