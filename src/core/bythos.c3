
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
  Mesh quad;

  Shader defaultShader2d, defaultShader3d;
  Texture defaultTexture;
  Mesh defaultMesh, textureMesh;

  struct time {
    double deltaTime, lastFrame;
  }
  struct gpu {
    String vendor, renderer, version, glsl;
    int shaderBinaries;
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
  } else { core.render = core.screen; }
  options.free();
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

  //* -- Display Driver Info -- *//
  core.gpu.vendor   = ((ZString)gl::getString(gl::GL_VENDOR)).str_view();
  core.gpu.renderer = ((ZString)gl::getString(gl::GL_RENDERER)).str_view();
  core.gpu.version  = ((ZString)gl::getString(gl::GL_VERSION)).str_view();
  core.gpu.glsl     = ((ZString)gl::getString(gl::GL_SHADING_LANGUAGE_VERSION)).str_view();
  gl::getIntegerv(gl::GL_NUM_PROGRAM_BINARY_FORMATS, &core.gpu.shaderBinaries);

  debug::info("OpenGL device information");
  debug::info(string::tformat("  > Vendor:    %s", core.gpu.vendor));
  debug::info(string::tformat("  > Renderer:  %s", core.gpu.renderer));
  debug::info(string::tformat("  > Version:   %s", core.gpu.version));
  debug::info(string::tformat("  > GLSL:      %s", core.gpu.glsl));
  if (core.gpu.shaderBinaries) { debug::info("  > Compiled Shader binaries supported"); }

  //* -- Defaults -- *//
  // Texture
  set_default_texture(texture::load_from_memory(texture::def, "PPM"));
  // Shaders
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
  // Meshes
  core.quad = mesh::new(PLANE);
  core.quad.material.shader = shader::compile(shader::FB_VERTEX, shader::FB_FRAGMENT);
  core.quad.material.shader.set_uniform("screenTexture", &&0);
  //set_default_quad(quad);
  Mesh cube = mesh::new(CUBE);
  cube.material.shader = core.defaultShader3d;
  set_default_mesh(cube);
  Mesh textureMesh = mesh::new(PLANE);
  cube.material.shader = core.defaultShader2d;
  set_default_texturemesh(textureMesh);

  //* -- Framebuffer -- *//
  gl::genFramebuffers(1, &core.framebuffer);
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.framebuffer);

  core.quad.material.maps[material::DIFFUSE].texture = texture::new(core.render.x, core.render.y);
  gl::framebufferTexture2D(gl::GL_FRAMEBUFFER, gl::GL_COLOR_ATTACHMENT0, gl::GL_TEXTURE_2D,
                           core.quad.material.maps[material::DIFFUSE].texture.id, 0);
  gl::genRenderbuffers(1, &core.renderbuffer);
  gl::bindRenderbuffer(gl::GL_RENDERBUFFER, core.renderbuffer);
  gl::renderbufferStorage(gl::GL_RENDERBUFFER, gl::GL_DEPTH24_STENCIL8,
                          core.render.x, core.render.y);
  gl::framebufferRenderbuffer(gl::GL_FRAMEBUFFER,  gl::GL_DEPTH_STENCIL_ATTACHMENT,
                              gl::GL_RENDERBUFFER, core.renderbuffer);
  if (gl::checkFramebufferStatus(gl::GL_FRAMEBUFFER) != gl::GL_FRAMEBUFFER_COMPLETE)
    { debug::fatal("Failed to initialize framebuffer"); }
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
}
fn void clean() @export("bythos_clean") {
  debug::info("Cleaning up Bythos");

  //* -- Defaults -- *//
  // Keybindings
  keybinds.free();
  free(keybinds);
  // Textures
  core.defaultTexture.clean();
  // Shaders
  core.defaultShader2d.clean();
  core.defaultShader3d.clean();
  // Meshes
  core.defaultMesh.clean(false);
  core.textureMesh.clean(false);
  core.quad.clean();

  //* -- SDL3 and OpenGL -- *//
  sdlgl::destroyContext(core.context);
  core.context = null;
  sdl3::destroyWindow(core.window);
  core.window = null;
  sdl3::quit();
}

