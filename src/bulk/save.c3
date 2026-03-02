
module bythos::bulk;
import std::collections, std::io;
import bythos, utility;

// Functions
fn void BulkTable.save(&self, String filename) @export("bulk_save") {
  File? file = file::open(filename, "wb");
  if (catch file) { debug::error("Failed to open file", filename); return; }

  debug::info("Saving bulk file");

  file.write_long(self.len())!!;
  
  self.@each(; String key, BulkEntry ent) {
    //if (ent.data.raw.len == 0) continue;
    // Write info
    file.write_string(ent.name)!!;
    file.write_string(ent.type)!!;
    file.write_ulong(ent.data.raw.len)!!;

    usz headerPosition = file.seek(0, Seek.CURSOR)!!;

  };
}

