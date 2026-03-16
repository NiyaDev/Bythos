
module bythos;

//* -- Structures -- *//
struct Material {
  Shader shader;
  MaterialMap[12] maps;
}
struct MaterialMap {
  Texture texture;
  Vec3f value;
}


module bythos::material;
import bythos;

//* -- Constants -- *//
const usz DIFFUSE    = 0;
const usz METALNESS  = 1;
const usz NORMAL     = 2;
const usz ROUGHNESS  = 3;
const usz OCCLUSION  = 4;
const usz EMISSION   = 5;
const usz HEIGHT     = 6;
const usz CUBEMAP    = 7;
const usz IRRADIANCE = 8;
const usz PREFILTER  = 9;
const usz BRDF       = 10;

//* -- Functions -- *//
fn Material new() @export("material_new") {
  Material output;
  output.shader = bythos::core.defaultShader3d;
  output.maps[DIFFUSE].texture = bythos::core.defaultTexture;
  return output;
}
fn void Material.clean(&self) @export("material_clean") {
  if (self.shader.id > 4) self.shader.clean();

  for (int i; i < self.maps.len; i++) {
    if (self.maps[i].texture.id > 1) self.maps[i].texture.clean();
  }
}
fn bool Material.is_valid(&self) @export("material_valid")
  => self.shader.id != 0;

