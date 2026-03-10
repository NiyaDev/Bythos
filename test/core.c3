
import bythos;
import std::io;
import sdl3;

//* -- Tests -- *//
fn void window() @test {
  debug::@benchmark("Initialization")
    { bythos::init(); };

  Mesh m = mesh::new(TRI);

  bythos::@loop() {
    m.draw();
  };

  bythos::clean();
  assert(false);
}



