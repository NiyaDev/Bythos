
module bythos::material;
import bythos::texture;
import bythos::color;
import bythos::shader;


struct Material {
  Shader shader;
  Texture texture;
  Color color;
}

