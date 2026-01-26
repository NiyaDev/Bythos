
module bythos::material;
import bythos;


struct Material {
  Shader shader;
  Texture texture;
  Color color;
}

fn Material new() {
  return {
    bythos::bythos.def_3d,
    {},
    color::WHITE,
  };
}

