
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

  String[] split = filename.tsplit("/");
  String path = filename.trim_right(split[split.len-1]);

  return load_from_memory((String)data, path);
}
fn HashMap{String, Material} load_from_memory(String data, String path = "") @export("material_loadfrommemory") {
  HashMap{String, Material} output;
  String[] lines = data.tsplit("\n");
  usz start, end;

  while (true) {
    if (start >= lines.len || end >= lines.len) break;
    for (; start < lines.len; start++)
      { if (lines[start].first_word() == "newmtl") break; }
    end = start;
    for (; end < lines.len; end++)
      { if (lines[end].len == 0) break; }

    // Iterate through each line
    for (usz i = start; i < end; i++) {
      String name;
      Material mat;

      String[] entries = lines[i].tsplit(" ");
      switch (entries[0]) {
        case "newmtl":
          name = entries[1];
        case "Ns":      // SPECULAR_HIGHLIGHT
        case "Ka":      // AMBIENT
          break;
        case "Kd":      // DIFFUSE
          mat.maps[DIFFUSE].value = (Vec3f){
            entries[1].to_float()!!,
            entries[2].to_float()!!,
            entries[3].to_float()!!,
          };
        case "Ks":      // SPECULAR
        case "Ke":      // EMISSION
        case "Ni":      // OPTICAL DENSITY
        case "d":       // DISSOLVE
        case "illum":   // ILLUMINATION
          break;
        case "map_Kd":  // TEXTURE
          mat.maps[DIFFUSE].texture = texture::load(string::tformat("%s%s",path,entries[1]));
      }
      start++;

      if (name != "") output.set(name, mat);
    }
  }

  return output;
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
  for (int i; i < self.maps.len; i++)
    { if (self.maps[i].texture.id != 0) self.maps[i].texture.clean(); }
}

fn bool Material.is_valid(&self) @export("material_isvalid")
  => self.shader.id != 0 && self.maps[material::DIFFUSE].texture.id != 0;


fn String String.first_word(&self) {
  String[] words = self.tsplit(" ");
  return words[0];
}
