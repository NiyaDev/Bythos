
module bythos;
import sdl3;
import opengl::gl;
import bythos::debug;


struct Bythos {
  SDL_Window* window;
  SDL_GLContext* context;
  SDL_Event event;

  double deltaTime, lastFrame;

  uint screenWidth, screenHeight;
  uint renderWidth, renderHeight;

  struct mouse {
    Vec2f position, delta;
    bool[5] buttons, buttonsHeld, buttonsUp;
    float scrollwheel;
  }
  struct framebuffer {
    uint fb, rb;
    Texture tex;
    //Mesh quad;
  }
}

Bythos bythos;

fn void init() @export("bythos_init") {
  int res;

  // Init SDL3
  if (!sdl3::init(sdl3::INIT_VIDEO | sdl3::INIT_AUDIO))
    { debug::fatal("Failed to initialize SDL3.", sdl3::get_error()); }
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MAJOR_VERSION, 3);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_MINOR_VERSION, 3);
  sdl3::gl_set_attribute(GLAttr.CONTEXT_PROFILE_MASK, sdl3::CONTEXT_PROFILE_CORE);

  // Create window
  bythos.window = sdl3::create_window("BYTHOS", 1280, 720, sdl3::WINDOW_OPENGL);
  if (bythos.window == null)
    { debug::fatal("Failed to create SDL3 window.", sdl3::get_error()); }

  // Create OpenGL context
  bythos.context = sdl3::gl_create_context(bythos.window);
  if (bythos.context == null)
    { debug::fatal("Failed to create OpenGL context.", sdl3::get_error()); }
  if (!sdl3::gl_make_current(bythos.window, bythos.context))
    { debug::fatal("Failed to make GLcontext current.", sdl3::get_error()); }
  int? result = opengl::init((gl::GLLoadFn)&sdl3::gl_get_proc_address);
  if (catch result)
    { debug::fatal("Failed to initialize OpenGL functions."); }

  // Enable depth testing
  gl::enable(gl::GL_DEPTH_TEST);
  gl::enable(gl::GL_BLEND);
  gl::blendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

  // Default shaders
  // Framebuffer
  // Load defaults
  // Keybinds
}
fn void clean() @export("bythos_clean") {
  sdl3::gl_destroy_context(bythos.context);
  bythos.context = null;
  sdl3::destroy_window(bythos.window);
  bythos.window = null;
  bythos.event = {};

  // Rest of cleanup
}
fn bool should_close() @export("bythos_shouldclose") {
  // Calculate deltatime
  double currentFrame = (double)sdl3::get_ticks() / 1000;
  bythos.deltaTime = currentFrame - bythos.lastFrame;
  bythos.lastFrame = currentFrame;

  // Update Keybinds
  // Poll events
  while (sdl3::poll_event(&bythos.event)) {
    switch (bythos.event.type) {
      case QUIT: return true;

      case KEY_DOWN:
      case KEY_UP:
        break;
      //  keybinds::add_queue(event.key);

      case WINDOW_SHOWN: break;
      case WINDOW_EXPOSED: break;
      case WINDOW_MOVED: break;
      case WINDOW_PIXEL_SIZE_CHANGED: break;
      case WINDOW_MINIMIZED: break;
      case WINDOW_RESTORED: break;
      case WINDOW_MOUSE_ENTER: break;
      case WINDOW_MOUSE_LEAVE: break;
      case WINDOW_FOCUS_GAINED: break;
      case WINDOW_FOCUS_LOST: break;
      case WINDOW_SAFE_AREA_CHANGED: break;
      case WINDOW_OCCLUDED: break;

      case MOUSE_MOTION:
        Vec2f temp = {bythos.event.motion.x, bythos.event.motion.y};
        bythos.mouse.delta = {bythos.event.motion.xrel, bythos.event.motion.yrel};
        bythos.mouse.position = temp;
      case MOUSE_BUTTON_DOWN:
        bythos.mouse.buttons[bythos.event.button.button-1] = true;
      case MOUSE_BUTTON_UP:
        bythos.mouse.buttonsUp[bythos.event.button.button-1] = true;
      case MOUSE_WHEEL:
        bythos.mouse.scrollwheel = bythos.event.wheel.y;

      case SENSOR_UPDATE: break;

      default: debug::info("Unhandled event.", bythos.event.type);
    }
  }

  // Default exit key

  return false;
}
fn void draw() @export("bythos_draw") {
  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

  bythos.mouse.scrollwheel = 0;

  // Debug

  sdl3::gl_swap_window(bythos.window);
}

