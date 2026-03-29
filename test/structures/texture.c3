
import std::io;
import bythos;

fn void loading() @test {
  bythos::init();

  Texture t1 = texture::load("resources/tests/texture.ppm");
  assert(t1.id != 0, "Texture is not uploaded correctly. [%d]", t1.id);
  assert(t1.id == 3, "Texture is not the next texture uploaded. [%d]", t1.id);
  assert(t1.w == 2, "Texture width incorrect. [%s]", t1.w);
  assert(t1.h == 2, "Texture width incorrect. [%s]", t1.h);
  assert(t1.is_valid(), "Texture is claiming it isn't loaded.");
  t1.clean();
  assert(!t1.is_valid(), "Texture is claiming it is loaded.");

  Texture t2 = texture::load_from_memory(texture::def, "ppm");
  assert(t2.id != 0, "Texture is not uploaded correctly. [%d]", t2.id);
  assert(t2.id == 3, "Texture is not the next texture uploaded. [%d]", t2.id);
  assert(t2.w == 2, "Texture width incorrect. [%s]", t2.w);
  assert(t2.h == 2, "Texture width incorrect. [%s]", t2.h);
  assert(t2.is_valid(), "Texture is claiming it isn't loaded.");
  t2.clean();
  assert(!t2.is_valid(), "Texture is claiming it is loaded.");

  Texture t3 = texture::new(100,100);
  assert(t3.id != 0, "Texture is not uploaded correctly. [%d]", t3.id);
  assert(t3.id == 3, "Texture is not the next texture uploaded. [%d]", t3.id);
  assert(t3.w == 100, "Texture width incorrect. [%s]", t3.w);
  assert(t3.h == 100, "Texture width incorrect. [%s]", t3.h);
  assert(t3.is_valid(), "Texture is claiming it isn't loaded.");
  t3.clean();
  assert(!t3.is_valid(), "Texture is claiming it is loaded.");

  bythos::clean();
}

fn void drawing() @test {
  bythos::init();

  uint frame;
  bythos::@loop() {
    switch (frame) {
      case 0: // Draw
        Texture.draw(dst:{32,32,32,32});
        //bythos::screenshot();
        
      case 1: // Draw instanced
      case 2: // Billboard
      case 3: // Billboard instanced
      default: bythos::quit(0);
    }
    frame++;
  };

  bythos::clean();
}

/*
fn void drawing() @test {
  bythos::init();
  int count;

  while (!bythos::should_close()) {
    render::draw_texture(dst:{0,0,10,10},src:{0,0,2,2});

    bythos::draw();

    count++;
    if (count == 10) break;
  }

  // Compare
  //bythos::screenshot("resources/test_results/textures/texture_drawing.png");
  char[] data = bythos::screenshot();
  char[] comp = mem::new_array(char, file::get_size("resources/test_results/textures/texture_drawing.png")!!);
  File f = file::open("resources/test_results/textures/texture_drawing.png", "rb")!!;
  f.read(comp)!!;
  f.close()!!;
  assert(data.len == comp.len, "Current screenshot length [%d] is different then desired [%d]", data.len, comp.len);

  for (int i; i < data.len; i++)
    { assert(data[i] == comp[i], "Byte %d is screenshot is incorrect.", i); }

  free(comp);

  bythos::clean();
}
*/

