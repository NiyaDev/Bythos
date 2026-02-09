
import std::collections;
import std::io;
import bythos;


fn void loading() @test {
  bythos::init();

  HashMap{String, Material} mats = material::load("resources/Hati.mtl");
  assert(mats.len() == 6, "Failed to create all materials. %s != 6", mats.len());

  mats.@each(; String key, Material mat) {
    assert(mat.maps[material::DIFFUSE].value == {0.8,0.8,0.8}, "%s diffuse value incorrect.", key);
    switch (key) {
      case "MTI_Hati_Body":
        assert(mat.maps[material::DIFFUSE].texture.width == 1024, "%s diffuse texture incorrect.", key);
      case "MTI_Hati_Body02":
        assert(mat.maps[material::DIFFUSE].texture.width ==  512, "%s diffuse texture incorrect.", key);
      case "MTI_Hati_Dec":
        assert(mat.maps[material::DIFFUSE].texture.width ==  256, "%s diffuse texture incorrect.", key);
      case "MTI_Hati_Face":
        assert(mat.maps[material::DIFFUSE].texture.width ==  512, "%s diffuse texture incorrect.", key);
      case "MTI_Hati_Hair":
        assert(mat.maps[material::DIFFUSE].texture.width ==  512, "%s diffuse texture incorrect.", key);
    }
  };

  bythos::clean();
}
