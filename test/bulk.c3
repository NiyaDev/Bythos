
import bythos;

fn void saving() @test {
  BulkTable tbl;
  tbl.set("test", {"test", "String", 0, 0, NONE, {.str="TESTONE"}}); // String
  // Keybind
  // Localization
  // Animation
  // Texture
  // Font
  // Shader (Text)
  // Shader (Binary)
  // Mesh
  // Material

  tbl.save("resources/test_bulk");
  assert(false);
}
fn void sloading() @test {}

