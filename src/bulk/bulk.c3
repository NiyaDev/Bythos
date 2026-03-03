
module bythos::bulk;
import std::collections, std::io;
import bythos, utility;

// Types
alias BulkTable = HashMap{String, BulkEntry};

// Structs
struct BulkEntry {
  String name, type;
  usz length, pointer;
  CompressionType compression;
  BulkData data;
}
union BulkData {
  char[] raw;
  String str;
  struct shaderBinary {
    char[] binary;
    String vendor, renderer, version, glsl;
    uint format;
  }
}

// Enums
enum CompressionType : short {
  NONE,
  DEFLATE,
}

// Loading Functions
fn BulkTable get_table(String filename) @export("bulk_gettable") {
  BulkTable output;

  File? file = file::open(filename, "rb");
  if (catch file) { debug::error("Failed to open file", filename); return {}; }

  long? count = file.read_long();
  if (catch count) { debug::error("Failed to read entry count from file", filename); return {}; }

  for (int i; i < count; i++) {
    String? name = file.read_string();
    if (catch name) { debug::error("Failed to read entry name from file" , filename); continue; }
    long? length = file.read_long();
    if (catch length) { debug::error("Failed to read entry length from file" , filename); continue; }
    long? pointer = file.read_long();
    if (catch pointer) { debug::error("Failed to read entry pointer from file" , filename); continue; }
    String? type = file.read_string();
    if (catch type) { debug::error("Failed to read entry file type from file" , filename); continue; }
    short? compression = file.read_short();
    if (catch compression) { debug::error("Failed to read compression type from file" , filename); continue; }

    output.set(name, {
      name, type,
      length, pointer,
      (CompressionType)compression,
      {},
    });
  }

  file.close()!!;
  return output;
}
fn BulkEntry get_entry(String filename, String dataname) @export("bulk_getentry") {
  BulkTable table = get_table(filename);
  if (!table.has_key(dataname)) { debug::error("Entry does not exist in bulk file"); return {}; }

  return table[dataname]!!;
}

// Saving Functions

