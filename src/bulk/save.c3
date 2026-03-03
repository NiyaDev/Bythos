
module bythos::bulk;
import std::collections, std::io;
import bythos, utility;

// Functions
fn void BulkTable.save(&self, String filename) @export("bulk_save") {
  File? file = file::open(filename, "wb");
  if (catch file) { debug::error("Failed to open file", filename); return; }

  List{BulkEntry} entries;
  self.@each(; String key, BulkEntry ent) { entries.push(ent); };
  usz dataPointer = entries.get_total_size();
  usz lastHeader = 0;

  debug::info("Saving bulk file");

  file.write_long(self.len())!!;
  for (int i; i < entries.len(); i++) {
    if (entries[i].data.raw.len == 0) continue;

    // Write info
    file.write_string(entries[i].name)!!;               // Name
    file.write_string(entries[i].type)!!;               // Type
    file.write_ulong(entries[i].data.raw.len)!!;        // Length
    file.write_ulong(dataPointer)!!;                    // Pointer
    file.write_short(entries[i].compression.ordinal)!!; // Compression type

    lastHeader = file.seek(0, Seek.CURSOR)!!;
    file.seek(dataPointer)!!;

    switch (entries[i].type) {
      default:
      case "raw":
      case "String":
        for (int j; j < entries[i].data.raw.len; j++) file.write_byte(entries[i].data.raw[j])!!;

      case "ShaderBinary":
        file.write_string(entries[i].data.shaderBinary.vendor)!!;
        file.write_string(entries[i].data.shaderBinary.renderer)!!;
        file.write_string(entries[i].data.shaderBinary.version)!!;
        file.write_string(entries[i].data.shaderBinary.glsl)!!;
        file.write_uint(entries[i].data.shaderBinary.format)!!;
        for (int j; j < entries[i].data.shaderBinary.binary.len; j++) file.write_byte(entries[i].data.shaderBinary.binary[j])!!;
    }
    
    dataPointer = file.seek(0, Seek.CURSOR)!!;
    file.seek(lastHeader)!!;
  }

  file.close()!!;
  entries.free();
}

fn usz List{BulkEntry}.get_total_size(&self) {
  usz output = 8;
  for (int i; i < self.len(); i++) {
    output += self.get(i).name.len+1; // Name
    output += self.get(i).type.len+1; // Type
    output += ulong.sizeof;           // Length
    output += ulong.sizeof;           // Pointer
    output += short.sizeof;           // Compression
  }
  return output;
}

