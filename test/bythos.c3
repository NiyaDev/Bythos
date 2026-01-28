
import std::math;
import std::io;
import sdl3;
import opengl::gl;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  Mesh m = mesh::new(CUBE);

  float y = 1;
  Vec3f pos;

  while (!bythos::should_close()) {
    bythos::draw();

    m.draw(position:pos, rotation:{0,y,0});

    y += 0.01;
    if (y > 6.28318530718) {
      y = 0;
    }

    gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
    gl::disable(gl::GL_DEPTH_TEST);
    gl::clearColor(0,0.5,0,1);
    gl::clear(gl::GL_COLOR_BUFFER_BIT);
    gl::viewport(0, 0, bythos::core.window.screen.x, bythos::core.window.screen.y);

    bythos::core.window.quad.draw();

    sdl3::gl_swap_window(bythos::core.window.sdl);
  }
  assert(false, "reached end");
}


