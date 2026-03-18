
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
  Window* window;
  GLContext* context;
  Renderer* renderer;

  Vec2i display, screen, render;

  uint framebuffer, renderbuffer;
  Mesh quad;
  Material quadMat;

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
  sdlgl::setAttribute(GLAttr.CONTEXT_MAJOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_MINOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_PROFILE_MASK, sdlgl::CONTEXT_PROFILE_CORE);
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

  //* -- Defualts -- *//
  core.defaultShader2d = shader::compile(shader::DEFAULT_VERTEX_2D, shader::DEFAULT_FRAGMENT_2D);
  core.defaultShader2d.set_vec2("screensize", (Vec2f){(float)core.render.x, (float)core.render.y});
  core.defaultShader3d = shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D);
  core.defaultShader3d.set_matrix("projection", matrix::perspective{float}(70 * (math::PI / 180), (float)core.render.x / (float)core.render.y, 0.1, 100).transpose());
  core.quad = mesh::new(PLANE);
  core.quadMat = {shader::compile(shader::FB_VERTEX, shader::FB_FRAGMENT), {}};
  core.quadMat.shader.set_int("screenTexture", 0);
  core.defaultMesh = mesh::new(CUBE);
  core.textureMesh = mesh::new(PLANE);
  core.defaultTexture = texture::load_from_memory(texture::def, "ppm");
  core.defaultMaterial = {core.defaultShader3d, {}};
  core.defaultMaterial.maps[material::DIFFUSE].texture = core.defaultTexture;

  //* -- Framebuffer -- *//
  gl::genFramebuffers(1, &core.framebuffer);
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.framebuffer);
  core.quadMat.maps[material::DIFFUSE].texture = texture::new(core.render.x, core.render.y);
  gl::framebufferTexture2D(gl::GL_FRAMEBUFFER, gl::GL_COLOR_ATTACHMENT0, gl::GL_TEXTURE_2D,
                           core.quadMat.maps[material::DIFFUSE].texture.id, 0);
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
  //* -- Freeing defaults -- *//
  core.defaultShader2d.clean();
  core.defaultShader3d.clean();
  core.quad.clean();
  core.quadMat.clean();
  core.defaultMesh.clean();
  core.textureMesh.clean();
  core.defaultMaterial.clean();
  core.defaultTexture.clean();
  core.quadMat.clean();

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

