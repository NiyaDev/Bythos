
import std::collections;
import std::io;
import bythos;

fn void loading() @test {
  bythos::init();

  //* -- Loading materials from a file -- *//
  MaterialList list;
  debug::@benchmark("Loading materials") {list = material::load("resources/tests/material.mtl");};
  assert(list.len() == 4, "Failed to create all materials. %s != 4", list.len());
  foreach (pair : list) assert(pair.second.is_valid(), "Material %s is not valid", pair.first);

  foreach (pair : list) {
    assert(pair.second.shader.id == bythos::get_default_3dshader().id, "Shader incorrect");
    switch (pair.first) {
      case "material_0": assert(pair.second.maps[material::DIFFUSE].texture.id == 3, "%s diffuse texture incorrect.", pair.first);
      case "material_1": assert(pair.second.maps[material::DIFFUSE].texture.id == 4, "%s diffuse texture incorrect.", pair.first);
      case "material_2": assert(pair.second.maps[material::DIFFUSE].texture.id == 5, "%s diffuse texture incorrect.", pair.first);
      case "material_3": assert(pair.second.maps[material::DIFFUSE].texture.id == 6, "%s diffuse texture incorrect.", pair.first);
    }
  };

  //* -- Creating a new material -- *//
  Material mat = material::new();
  assert(mat.shader.id == bythos::get_default_3dshader().id, "Shader incorrect [%d]", mat.shader.id);
  assert(mat.maps[material::DIFFUSE].texture.id == bythos::get_default_texture().id, "New material diffuse texture incorrect [%d]", mat.maps[material::DIFFUSE].texture.id);
  mat.clean();
  assert(mat.shader.id == 0, "Shader not cleaned [%d]", mat.shader.id);
  assert(mat.maps[material::DIFFUSE].texture.id == 0, "Diffuse texture not cleaned [%d]", mat.maps[material::DIFFUSE].texture.id);

  list.clean();
  bythos::clean();
}

