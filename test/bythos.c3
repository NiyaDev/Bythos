
//import bythos;
import std::io;
import sdl3;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  Mesh m = mesh::new(CUBE);
  m.material.shader = shader::compile();
  io::printfn("%d",m.material.shader.id);

  while (!bythos::should_close()) {
    bythos::draw();

    m.draw();

    sdl3::gl_swap_window(bythos.window);
  }
  assert(false, "reached end");
}
