
//import bythos;
import sdl3;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  Mesh m = mesh::new(CUBE);

  while (!bythos::should_close()) {
    bythos::draw();

    m.draw();

    sdl3::gl_swap_window(bythos.window);
  }
  assert(false, "reached end");
}
