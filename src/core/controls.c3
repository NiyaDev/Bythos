
module bythos;
import sdl3;

//* -- Functions -- *//
fn void set_resolution(uint width = core.screen.x, uint height = core.screen.y) @export("bythos_setresolution") {
  core.screen.x = width;
  core.screen.y = width;

  sdl3::setWindowSize(core.window, width, height);
}

