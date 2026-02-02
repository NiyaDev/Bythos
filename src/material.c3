
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
    bythos::core.def_tex,
    color::WHITE,
  };
}

fn void Material.clean(&self) @export("material_clean") {
  self.texture.clean();
  self.shader.clean();
}

