
module bythos::material;
import bythos;


struct Material {
  Shader shader;
  Texture texture;
  Color color;
}

fn Material new() {
  return {
    bythos::core.def_3d,
    bythos::core.storage.textures.get("default")!!,
    color::WHITE,
  };
}

fn void Material.clean(&self) @export("material_clean") {
  if (self.shader.id != 0)
    { self.shader.clean(); }
}

