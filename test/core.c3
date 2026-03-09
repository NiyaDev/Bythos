
import bythos;

//* -- Tests -- *//
fn void window() @test {
  bythos::init();

  bythos::@loop() {};

  bythos::clean();
  assert(false);
}



