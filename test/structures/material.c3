
import std::collections;
import std::io;
import bythos;

fn void loading() @test {
  bythos::init();

  MaterialList list;
  debug::@benchmark("Loading materials") {list = material::load("resources/tests/material.mtl");};
  assert(list.len() == 4, "Failed to create all materials. %s != 4", list.len());

  foreach (pair : list) {
    switch (pair.first) {
      case "material_0":
        assert(pair.second.maps[material::DIFFUSE].texture.id == 3, "%s diffuse texture incorrect.", pair.first);
      case "material_1":
        assert(pair.second.maps[material::DIFFUSE].texture.id == 4, "%s diffuse texture incorrect.", pair.first);
      case "material_2":
        assert(pair.second.maps[material::DIFFUSE].texture.id == 5, "%s diffuse texture incorrect.", pair.first);
      case "material_3":
        assert(pair.second.maps[material::DIFFUSE].texture.id == 6, "%s diffuse texture incorrect.", pair.first);
    }
  };

  foreach (pair : list) pair.second.clean();
  bythos::clean();
}

