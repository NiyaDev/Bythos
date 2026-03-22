
import std::collections;
import std::io;
import bythos;

/*
fn void loading() @test {
  bythos::init();

  HashMap{String, Material} mats = material::load("resources/Puffmin.mtl");
  assert(mats.len() == 4, "Failed to create all materials. %s != 4", mats.len());

  mats.@each(; String key, Material mat) {
    switch (key) {
      case "material_0":
        assert(mat.maps[material::DIFFUSE].texture.width ==  1, "%s diffuse texture incorrect.", key);
      case "material_1":
        assert(mat.maps[material::DIFFUSE].texture.width ==  1, "%s diffuse texture incorrect.", key);
      case "material_2":
        assert(mat.maps[material::DIFFUSE].texture.width == 32, "%s diffuse texture incorrect.", key);
      case "material_3":
        assert(mat.maps[material::DIFFUSE].texture.width == 16, "%s diffuse texture incorrect.", key);
    }
  };

  bythos::clean();
}
*/

