
module bythos;
import sdl3;

//* -- Structures -- *//
struct Keybind {
  SdlScancode key, mod;
}

//* -- Functions -- *//
fn Keybind make_binding(String key, String mod) @export("keybinds_makebinding") {
  
}
fn SdlScancode String.to_scancode(&self) {
  String[] names = sdl3::SdlScancode.names;
  for (int i; i < names.len; i++) {
    if (self == names[i]) return (SdlScancode)i;
  }
}
fn void Bythos.set_keybind(&self, String key, Keybind keybind) @export("keybinds_setkeybind") {}

