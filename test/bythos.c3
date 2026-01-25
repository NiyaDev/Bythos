
import std::math;
import std::io;
import sdl3;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  Mesh m = mesh::new(TRI);
  m.material.shader = shader::compile(shader::DEFAULT_VERTEX_3D,shader::DEFAULT_FRAGMENT_3D);
  Matrix4f mat = matrix::perspective{float}(
      70 * math::PI / 180,
      1280 / 720, 0.1, 100).transpose();
  m.material.shader.set_uniform("projection", &mat);

  float y = 1;
  Vec3f pos;

  while (!bythos::should_close()) {
    bythos::draw();

    m.draw(position:pos, rotation:{0,y,0});

    y += 0.01;
    if (y > 6.28318530718) {
      y = 0;
      io::printfn("reset");
    }

    sdl3::gl_swap_window(bythos.window);
  }
  assert(false, "reached end");
}


