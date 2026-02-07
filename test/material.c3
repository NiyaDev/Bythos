
import std::collections;
import std::io;
import bythos;


fn void loading() @test {
  HashMap{String, Material} mats = material::load("resources/test_mat.mtl");
  assert(mats.len() == 6, "Failed to create all materials.");

  mats.@each(; String key, Material mat) {
    io::printfn("Material [%s]", key);
  };
}
