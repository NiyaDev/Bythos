
module bythos;
import std::collections;

//* -- Types -- *//
alias OptionsList = HashMap{String, Option};

//* -- Structures -- *//
struct Option {
  typeid type;
  union {
    bool b;
    uint128 i;
    double f;
    String s;
    void* other;
  }
}


module bythos::options;
import std::collections;
import toml;
import bythos;

//* -- Faults -- *//
faultdef PARSE_ERROR, EMPTY_ERROR;

//* -- Functions -- *//
fn OptionsList load_all(String filename) @export("options_loadall") {
  TomlData? cfg = toml::from_file(filename, tmem);
  if (catch cfg) { debug::warning("Failed to parse string to TOML", filename); return {}; }

  OptionsList output;
  iterate(cfg.table, "base", &output);

  cfg.free();
  return output;
}
fn void OptionsList.clean(&self) @export("options_clean") {
  self.@each(; String key, Option val)
    { if (val.type == void*) free(val.other); };
  self.free();
}

fn void iterate(Object* data, String name, OptionsList* map) {
  Option opt;

  switch (true) {
    case data.is_int():
      opt.type = uint128;
      opt.i = data.i;
    case data.is_float():
      opt.type = double;
      opt.f = data.f;
    case data.is_bool():
      opt.type = bool;
      opt.b = data.b;
    case data.is_string():
      opt.type = String;
      opt.s = data.s;
    case data.is_map():
      data.map.@each(; String key, Object* val)
        { iterate(val, key, map); };
      return;
    default:
      debug::warning("Invalid type in options file.", data.type);
  }
  map.set(name, opt);
}

fn char HashMap{String,Option}.as_char(self, String key)
  => (char)self[key]!!.i;
fn ushort HashMap{String,Option}.as_ushort(self, String key)
  => (ushort)self[key]!!.i;
fn uint HashMap{String,Option}.as_uint(self, String key)
  => (uint)self[key]!!.i;
fn ulong HashMap{String,Option}.as_ulong(self, String key)
  => (ulong)self[key]!!.i;
fn ichar HashMap{String,Option}.as_ichar(self, String key)
  => (ichar)self[key]!!.i;
fn short HashMap{String,Option}.as_short(self, String key)
  => (short)self[key]!!.i;
fn int HashMap{String,Option}.as_int(self, String key)
  => (int)self[key]!!.i;
fn long HashMap{String,Option}.as_long(self, String key)
  => (long)self[key]!!.i;
fn float HashMap{String,Option}.as_float(self, String key)
  => (float)self[key]!!.f;
fn double HashMap{String,Option}.as_double(self, String key)
  => self[key]!!.f;
fn bool HashMap{String,Option}.as_bool(self, String key)
  => self[key]!!.b;
fn String HashMap{String,Option}.as_string(self, String key)
  => self[key]!!.s;

