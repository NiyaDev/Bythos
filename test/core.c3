
import bythos;
import std::io;
import sdl3;

//* -- Tests -- *//
fn void window() @test {
  debug::@benchmark("Initialization")
    { bythos::init(); };

  bythos::@loop() {
  };

  bythos::clean();
  assert(false);
}



