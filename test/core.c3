
import bythos;
import std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Tests -- *//
fn void window() @test {
  debug::@benchmark("Initialization") { bythos::init(); };

  float rotation;
  bythos::@loop() {
    rotation += 0.01;
    Mesh.draw(rotation:{0,rotation,0});
  };

  bythos::clean();
  assert(false);
}

