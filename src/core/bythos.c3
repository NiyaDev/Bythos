
module bythos;
import std::collections, std::io;
import sdl3;
import opengl::gl;

//* -- Constants -- *//
const String VERSION @export("version") = "0.1.0-Foundation";
const usz MAX_MOUSE_BUTTONS =   8;
const usz MAX_KEYBOARD_KEYS = 512;
const usz MAX_KEY_QUEUE     =  16;

//* -- Globals -- *//
Bythos core;

//* -- Structs -- *//
struct Bythos {
  Window* window;
  GLContext* context;

  Vec2i display, screen, render;

  struct time {
    double deltaTime, lastFrame;
  }
  struct gpu {
    String vendor, renderer, version, glsl;
    int shaderBinaries;
  }
}

//* -- Functions -- *//
fn void init() @export("bythos_init") {
  //debug::info("Initializing Bythos version", VERSION);

  //* -- Loading Options -- *//
  // TEMP
  core.screen = {1280,720};
  core.render = {1280,720};

  //* -- SDL3 -- *//
  if (!sdl3::init({.video = true, .audio = true}))
    { debug::fatal("Failed to initialize SDL3", sdl3::getError()); }
  sdlgl::setAttribute(GLAttr.CONTEXT_MAJOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_MINOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_PROFILE_MASK, sdlgl::CONTEXT_PROFILE_CORE);
  core.window = sdl3::createWindow("BYTHOS", core.screen.x, core.screen.y, {.opengl = true});
  if (!core.window) debug::fatal("Failed to create SDL3 window", sdl3::getError());
  //Rect r;
  //sdl3::getDisplayBounds(sdl3::getDisplayForWindow(core.window), &r);
  //core.display = {r.w, r.h};

  //* -- OpenGL -- *//
  core.context = sdlgl::createContext(core.window);
  if (!core.context) debug::fatal("Failed to create OpenGL context", sdl3::getError());
  if (!sdlgl::makeCurrent(core.window, core.context)) debug::fatal("Failed to make GLContext current", sdl3::getError());
  int? result = opengl::init((gl::GLLoadFn)&sdlgl::getProcAddress);
  if (catch result) debug::fatal("Failed to load OpenGL functions");
  //gl::enable(gl::GL_DEPTH_TEST);
  //gl::enable(gl::GL_BLEND);
  //gl::blendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

  //* -- Screen Info -- *//
  //debug::info("Display device initialized successfully");
  //debug::info(string::tformat("  > Display resolution: %d x %d", core.display.x, core.display.y));
  //debug::info(string::tformat("  > Screen resolution:  %d x %d", core.screen.x, core.screen.y));
  //debug::info(string::tformat("  > Render resolution:  %d x %d", core.render.x, core.render.y));

  //* -- Display Driver Info -- *//
  //core.gpu.vendor   = ((ZString)gl::getString(gl::GL_VENDOR)).str_view();
  //core.gpu.renderer = ((ZString)gl::getString(gl::GL_RENDERER)).str_view();
  //core.gpu.version  = ((ZString)gl::getString(gl::GL_VERSION)).str_view();
  //core.gpu.glsl     = ((ZString)gl::getString(gl::GL_SHADING_LANGUAGE_VERSION)).str_view();
  //gl::getIntegerv(gl::GL_NUM_PROGRAM_BINARY_FORMATS, &core.gpu.shaderBinaries);

  //debug::info("OpenGL device information");
  //debug::info(string::tformat("  > Vendor:    %s", core.gpu.vendor));
  //debug::info(string::tformat("  > Renderer:  %s", core.gpu.renderer));
  //debug::info(string::tformat("  > Version:   %s", core.gpu.version));
  //debug::info(string::tformat("  > GLSL:      %s", core.gpu.glsl));
  //if (core.gpu.shaderBinaries) { debug::info("  > Compiled Shader binaries supported"); }
}
fn void clean() @export("bythos_clean") {
  //* -- Freeing defaults -- *//
  //* -- SDL3 and OpenGL -- *//
  sdlgl::destroyContext(core.context);
  core.context = null;
  sdl3::destroyWindow(core.window);
  core.window = null;
  sdl3::quit();
}

//* -- Benchmarks -- *//
fn void initialization() @benchmark {
  debug::set_log_level(NONE);

  bythos::init();
  bythos::clean();
}

