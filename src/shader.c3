
module bythos::shader;
import std::collections;


struct Shader {
  uint id;
  HashMap{String, uint} locs;
}

