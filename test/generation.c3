
import std::io;
import bythos::color;


fn void defaults() @test {
  File f = file::open("resources/texture.ppm", "wb")!!;

  f.write("P6\n2 2\n255\n")!!;
  f.write(&&color::PURPLE.rgb)!!;
  f.write(&&color::BLACK.rgb)!!;
  f.write(&&color::BLACK.rgb)!!;
  f.write(&&color::PURPLE.rgb)!!;

  f.close()!!;
}

