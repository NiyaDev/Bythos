
module bythos;
import std::collections;
import sdl3;

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

  Vec2i screen, render;
  uint framebuffer, renderbuffer;
  //Mesh quad;

  //Shader def_2d, def_3d;

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
fn Bythos init() @export("bythos_init") {
  debug::info("Initializing Bythos version", VERSION);
  Bythos core;

  HashMap{String, Option}? options = load_all_options("resources/toml_test.toml");
  if (try options) {
    core.screen = {options.as_uint("screen_width"), options.as_uint("screen_height")};
  } else { // Defaults
    core.screen = {1280, 720};
  }

  return core;
}

