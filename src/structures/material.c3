
module bythos;
import std::collections;

//* -- Types -- *//
alias MaterialList = List{Pair{String, Material}};

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
import std::io, std::collections;
import bythos;

//* -- Functions -- *//
fn MaterialList load(String filename) @export("material_load") {
  File? f = file::open(filename, "rb");
  if (catch f) { debug::warning("Failed to open material file.", filename); return {}; }

  usz? size = file::get_size(filename);
  if (catch size) { debug::warning("Failed to open material file.", filename); return {}; }

  char[] data = mem::temp_array(char, size);
  f.read(data)!!;

  return load_from_memory((String)data, filename.path_tdirname()!!);
}
fn MaterialList load_from_memory(String data, String path = "") @export("material_loadfrommem") {
  MaterialList output;
  String[] lines = data.tsplit("\n");
  usz lineNum;

  String name;
  Material mat = {bythos::get_default_3dshader(), {}};
  while (lineNum < lines.len) {
    String[] line = lines[lineNum].tsplit(" ");
    switch (line[0]) {
      case "newmtl":
        if (name != "") output.push({name, mat});
        name = line[1];
      case "Ns": // SPECULAR_HIGLIGHTS
      case "Ka": // AMBIENT
        break;
      case "Kd": // DIFFUSE
        mat.maps[DIFFUSE].value = (Vec3f){
          line[1].to_float()!!,
          line[2].to_float()!!,
          line[3].to_float()!!,
        };
      case "Ks":      // SPECULAR
      case "Ke":      // EMISSION
      case "Ni":      // OPTICAL DENSITY
      case "d":       // DISSOLVE
      case "illum":   // ILLUMINATION
        break;
      case "map_Kd":  // TEXTURE
        mat.maps[DIFFUSE].texture = texture::load(string::tformat("%s/%s", path, line[1]));
    }

    lineNum++;
  }
  output.push({name, mat});

  debug::info(string::tformat("MATERIAL: %d Materials loaded successfully", output.len()));
  foreach (pair : output)
    { debug::info(string::tformat("    %s with texture [ID %d]", pair.first, pair.second.maps[DIFFUSE].texture.id)); }

  return output;
}
fn Material new() @export("material_new") {
  Material output;
  output.shader = bythos::core.defaultShader3d;
  output.maps[DIFFUSE].texture = bythos::core.defaultTexture;
  return output;
}
fn void Material.clean(&self) @export("material_clean") {
  if (self.shader.id > 7) { self.shader.clean(); }
  else { self.shader = {0,{}}; }

  for (int i; i < self.maps.len; i++) {
    if (self.maps[i].texture.id > 2) { self.maps[i].texture.clean(); }
    else { self.maps[i].texture = {0,0,0}; }
  }
}
fn bool Material.is_valid(&self) @export("material_valid")
  => self.shader.id != 0;

fn void MaterialList.clean(&self) @export("material_listclean") {
  foreach (pair : self) pair.second.clean();
  self.free();
}

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

