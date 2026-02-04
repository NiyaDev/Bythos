
import std::math;
import std::io;
import sdl3;
import opengl::gl;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  //camera::main.target = {0,0,30};
  //camera::main.distance = {0,30,30};

  //Mesh m = mesh::new(CUBE);
  //defer m.clean();

  float y = 1;
  Vec3f pos;

  while (!bythos::should_close()) {
    //if (keybinds::is_pressed("test")) io::printfn("Pressed");
    //if (keybinds::is_down("test")) io::printfn("Down");
    //if (keybinds::is_up("test")) io::printfn("Up");
    if (keybinds::is_down("test")) camera::rotate(1);

    y += 0.01;
    if (y > 6.28318530718) {
      y = 0;
    }
    //render::draw_mesh(position:{}, rotation:{0,0,0});
    //render::draw_mesh(position:{1,0,0}, rotation:{0,y,0});
    //render::draw_mesh(position:{-1,0,0}, rotation:{0,-y,0});
    //for (int i; i < 10; i++) {
      render::draw_texture(
        dst:{100*(float)1,100,64,64},
        src:{0,0,2,2},
      );
    //  render::draw_mesh(
    //    position:{(float)(i/100)-50,0,(float)(i%100)-50},
    //    rotation:i/100 < 50 ? {0,-y,0} : (i/100 > 50 ? {0,y,0} : {}),
    //  );
    //}

    bythos::draw();

    //m.draw(position:pos, rotation:{0,y,0});
    //bythos::core.storage.meshes["default"]!!.draw(position:pos, rotation:{0,y,0});

    //gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
    //gl::disable(gl::GL_DEPTH_TEST);
    //gl::clearColor(0,0.5,0,1);
    //gl::clear(gl::GL_COLOR_BUFFER_BIT);
    //gl::viewport(0, 0, bythos::core.window.screen.x, bythos::core.window.screen.y);

    //bythos::core.window.quad.draw();

    //sdl3::gl_swap_window(bythos::core.window.sdl);
  }
  assert(false, "reached end");
}


