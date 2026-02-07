
module bythos::material;
import std::collections;
import std::io;
import bythos;


struct Material {
  Shader shader;
  MaterialMap[12] maps;
  //Texture texture;
  //Vec3f[12] values;
  //Color color;
}
struct MaterialMap {
  Texture texture;
  Vec3f value;
}
//enum MaterialValues : usz {
const usz DIFFUSE = 0;
const usz METALNESS = 1;
const usz NORMAL = 2;
const usz ROUGHNESS = 3;
const usz OCCLUSION = 4;
const usz EMISSION = 5;
const usz HEIGHT = 6;
const usz CUBEMAP = 7;
const usz IRRADIANCE = 8;
const usz PREFILTER = 9;
const usz BRDF = 10;
//}

fn HashMap{String, Material} load(String filename) @export("material_load") {
  File? f = file::open(filename, "rb");
  if (catch f)
    { debug::warning("Failed to open material file.", filename); return {}; }

  usz? size = file::get_size(filename);
  if (catch size)
    { debug::warning("Failed to open material file.", filename); return {}; }

  char[] data = mem::new_array(char, size);
  defer free(data);
  f.read(data)!!;

  return load_from_memory((String)data);
}
fn HashMap{String, Material} load_from_memory(String data) @export("material_loadfrommemory") {
  HashMap{String, Material} output;
  String[] lines = data.tsplit("\n");

  // Get index of first material
  usz index = 0;
  while (lines[index].len < 6 || lines[index][:6] != "newmtl")
    { index++; }
  io::printfn("%d",index);

  return {};
}
fn Material new() @export("material_new") {
  Material output = {
    bythos::core.def_3d,
    {},
  };
  output.maps[material::DIFFUSE] = {bythos::core.storage.textures.get("default")!!, {}};

  return output;
}
fn void Material.clean(&self) @export("material_clean") {
  if (self.shader.id != 0)
    { self.shader.clean(); }
}

fn bool Material.is_valid(&self) @export("material_isvalid")
  => self.shader.id != 0 && self.maps[material::DIFFUSE].texture.id != 0;

