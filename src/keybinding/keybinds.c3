
module bythos::keybindings;
import std::collections;
import bythos;
import sdl3;

//* -- Globals -- *//
HashMap{String, Keybind}* keybinds;

//* -- Structures -- *//
struct Keybind {
  SdlScancode key, mod;
}

//* -- Functions -- *//
fn void init_defaults() {
  keybinds = mem::new(HashMap{String, Keybind});

  //* -- Defaults -- *//
  keybinds.set("up",    {W, UNKNOWN});
  keybinds.set("down",  {S, UNKNOWN});
  keybinds.set("left",  {A, UNKNOWN});
  keybinds.set("right", {D, UNKNOWN});
  keybinds.set("test",  {P, UNKNOWN});
}
fn void init_file(String filename) @export("keybinds_initfile") {} // TODO: 
fn void clean() @export("keybinds_clean") {
  keybinds.free();
  free(keybinds);
}
fn void set_keybind(String key, Keybind k) @export("keybinds_setkeybind")
  => keybinds.set(key, k);

fn bool is_pressed(String key) @export("keybinds_keypressed") {
  Keybind? bind = keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == true
      && bythos::core.input.keyboard.repeatKeyState[(int)bind.key]  == false;
}
fn bool is_down(String key) @export("keybinds_keydown") {
  Keybind? bind = keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == true
      && bythos::core.input.keyboard.repeatKeyState[(int)bind.key]  == true;
}
fn bool is_up(String key) @export("keybinds_keyup") {
  Keybind? bind = keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == false
      && bythos::core.input.keyboard.previousKeyState[(int)bind.key] == true;
}

