
module bythos;
import std::collections;
import sdl3;


struct Keybind {
  Scancode key;
  Scancode mod;
}
HashMap{String, Keybind}* keybinds;


module bythos::keybinds;
import std::io;
import bythos;

fn bool is_pressed(String key) @export("keybinds_keypressed") {
  Keybind? bind = bythos::keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == true
      && bythos::core.input.keyboard.repeatKeyState[(int)bind.key]  == false;
}
fn bool is_down(String key) @export("keybinds_keydown") {
  Keybind? bind = bythos::keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == true
      && bythos::core.input.keyboard.repeatKeyState[(int)bind.key]  == true;
}
fn bool is_up(String key) @export("keybinds_keyup") {
  Keybind? bind = bythos::keybinds.get(key);
  if (catch bind) {
    debug::warning("Attempted to use uninitiated keybind.");
    return false;
  }

  return bythos::core.input.keyboard.currentKeyState[(int)bind.key] == false
      && bythos::core.input.keyboard.previousKeyState[(int)bind.key] == true;
}

