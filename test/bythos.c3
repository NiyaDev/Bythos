
import std::math;
import std::io;
import std::collections;
import sdl3;
import opengl::gl;


//*
fn void basic() @test {
  //debug::logLevel = NONE;
  bythos::init();

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
    for (int i; i < 10000; i++) {
      render::draw_texture(
        dst:{(float)(i/100)*10,(float)(i%100)*10,10,10},
        src:{0,0,2,2},
      );
      render::draw_mesh(
        position:{(float)(i/100)-50,0,(float)(i%100)-50},
        rotation:i/100 < 50 ? {0,-y,0} : (i/100 > 50 ? {0,y,0} : {}),
      );
    }

    bythos::draw();
  }
  bythos::clean();
  //assert(false, "reached end");
}
//*/

