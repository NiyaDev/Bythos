
module bythos;
import std::io;
import std::collections;
import std::math;
import sdl3;
import spng;
import opengl::gl;


const String BYTHOS_VERSION @export("version") = "0.1.0-Foundation";
const usz MAX_MOUSE_BUTTONS =   8;
const usz MAX_KEYBOARD_KEYS = 512;
const usz MAX_KEY_QUEUE     =  16;
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
  //Texture def_tex;

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
      Vec2f currentPosition;
      Vec2f previousPosition;
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

  struct storage {
    HashMap{String, Texture} textures;
    HashMap{String, Mesh} meshes;
  }
}


fn void init() @export("bythos_init") {
  debug::info("Initializing Bythos", BYTHOS_VERSION);

  // Defaults
  core.window.screen = {1280, 720};
  core.window.render = {1280, 720};
  core.input.keyboard.exitKey = (int)sdl3::Scancode.ESCAPE;
  keybinds::keybinds.set("test",{sdl3::Scancode.A,sdl3::Scancode.UNKNOWN});

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

  // Load defaults
  debug::info("Creating defaults.");
  core.storage.textures.set("default", texture::load_from_memory(texture::def, PPM));
  core.storage.meshes.set("default", mesh::new(CUBE));
  Mesh textureMesh = mesh::new(PLANE);
  textureMesh.material.shader = core.def_2d;
  core.storage.meshes.set("texture", textureMesh);

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

  // Keybinds
}
fn void clean() @export("bythos_clean") {
  debug::info("Cleaning up Bythos.");

  core.window.quad.clean();

  core.storage.textures.@each(; String key, Texture tex)
    { tex.clean(); };
  core.storage.meshes.@each(; String key, Mesh mesh)
    { mesh.clean(); };

  sdl3::gl_destroy_context(core.window.context);
  core.window.context = null;
  sdl3::destroy_window(core.window.sdl);
  core.window.sdl = null;
  core.window.event = {};
}

fn void draw_start() @export("bythos_drawstart") {
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.window.framebuffer);
  gl::enable(gl::GL_DEPTH_TEST);
  gl::viewport(0,0, core.window.render.x, core.window.render.y);

  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);
}
fn void draw_end() @export("bythos_drawend") {
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
  gl::disable(gl::GL_DEPTH_TEST);
  gl::clearColor(0,0.5,0,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT);
  gl::viewport(0, 0, 1280, 720);
  
  core.window.quad.draw();
  sdl3::gl_swap_window(core.window.sdl);
}
fn void draw() @export("bythos_draw") {
  // Start drawing
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.window.framebuffer);
  gl::enable(gl::GL_DEPTH_TEST);
  gl::viewport(0,0, core.window.render.x, core.window.render.y);

  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

  // Render pipeline
  render::render3d();
  render::render2d();
  core.storage.textures["default"]!!.draw(dst:{10,10,32,32});

  // End drawing
  gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
  gl::disable(gl::GL_DEPTH_TEST);
  gl::clearColor(0,0.5,0,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT);
  gl::viewport(0, 0, 1280, 720);
  
  core.window.quad.draw();
  sdl3::gl_swap_window(core.window.sdl);
}

fn void screenshot(String filename) @export("bythos_screenshot") {
  char[] data;
  switch (texture::to_type(filename)) {
    case PPM:
      data = mem::new_array(char, 3 * (usz)(core.window.quad.material.texture.width * core.window.quad.material.texture.height));
      defer free(data);
      gl::readPixels(
        0, 0, core.window.quad.material.texture.width, core.window.quad.material.texture.height,
        gl::GL_RGB, gl::GL_UNSIGNED_BYTE, data);

      data.reverse(core.window.render.x, core.window.render.y, 3);

      File f = file::open(filename, "wb")!!;
      String ppmInfo = string::tformat(
        "P6\n%d %d\n%s\n",
        core.window.quad.material.texture.width,
        core.window.quad.material.texture.height, 255);
      f.write(ppmInfo)!!;
      f.write(data)!!;
      f.close()!!;

      debug::info("Outputting screenshot as PPM to", filename);

    case PNG:
      int result;
      Ctx* ctx = spng::ctx_new((int)CTXFlags.ENCODER);
      defer spng::ctx_free(ctx);

      result = spng::set_option(ctx, Option.ENCODE_TO_BUFFER, 1);
      if (result != 0)
        { debug::error("Failed to set PNG options.", spng::strerror(result)); return; }

      Ihdr ihdr = {
        core.window.render.x,
        core.window.render.y,
        8, (char)ColorType.TRUECOLOR_ALPHA,
        0, 0, 0,
      };
      result = spng::set_ihdr(ctx, &ihdr);
      if (result != 0)
        { debug::error("Failed to set ihdr.", spng::strerror(result)); return; }

      data = mem::new_array(char, 4 * (usz)(core.window.quad.material.texture.width * core.window.quad.material.texture.height));
      defer free(data);
      gl::readPixels(
        0, 0, core.window.quad.material.texture.width, core.window.quad.material.texture.height,
        gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, data);

      data.reverse(core.window.render.x, core.window.render.y, 4);

      result = spng::encode_image(ctx, data, data.len, (int)Format.PNG, (int)EncodeFlags.FINALIZE);
      if (result != 0)
        { debug::error("Failed to encode image.", spng::strerror(result)); return; }

      usz size;
      void* png = spng::get_png_buffer(ctx, &size, &result);
      if (result != 0)
        { debug::error("Failed to get png buffer.", spng::strerror(result)); return; }

      file::save(filename, ((char*)png)[:size])!!;

      debug::info("Outputting screenshot as PNG to", filename);

    default:
      debug::error("Attempted to save screenshot as unknown file type.");
      return;
  }
}

fn Vec2f get_mouse_delta() @export("bythos_mousedelta")
  => core.input.mouse.delta;

