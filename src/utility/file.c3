
module utility;
import std::collections, std::io;

// Reading Functions
fn short? File.read_short(&self)
  => ((short)self.read_byte()!) + ((short)self.read_byte()! << 8);
fn ushort? File.read_ushort(&self)
  => ((ushort)self.read_byte()!) + ((ushort)self.read_byte()! << 8);

fn int? File.read_int(&self)
  => ((int)self.read_byte()!)       + ((int)self.read_byte()! <<  8) +
     ((int)self.read_byte()! << 16) + ((int)self.read_byte()! << 24);
fn uint? File.read_uint(&self)
  => ((uint)self.read_byte()!)       + ((uint)self.read_byte()! <<  8) +
     ((uint)self.read_byte()! << 16) + ((uint)self.read_byte()! << 24);

fn long? File.read_long(&self)
  => ((long)self.read_byte()!)       + ((long)self.read_byte()! <<  8) +
     ((long)self.read_byte()! << 16) + ((long)self.read_byte()! << 24) +
     ((long)self.read_byte()! << 32) + ((long)self.read_byte()! << 40) +
     ((long)self.read_byte()! << 48) + ((long)self.read_byte()! << 56);
fn ulong? File.read_ulong(&self)
  => ((ulong)self.read_byte()!)       + ((ulong)self.read_byte()! <<  8) +
     ((ulong)self.read_byte()! << 16) + ((ulong)self.read_byte()! << 24) +
     ((ulong)self.read_byte()! << 32) + ((ulong)self.read_byte()! << 40) +
     ((ulong)self.read_byte()! << 48) + ((ulong)self.read_byte()! << 56);

fn float? File.read_float(&self) {
  float output;
  char[] arr = mem::new_array(char, float.sizeof);

  self.read(arr)!;
  mem::copy(&output, (char*)arr, float.sizeof);
  free(arr);

  return output;
}
fn double? File.read_double(&self) {
  double output;
  char[] arr = mem::new_array(char, double.sizeof);

  self.read(arr)!;
  mem::copy(&output, (char*)arr, double.sizeof);
  free(arr);

  return output;
}

fn String? File.read_string(&self) {
  List{char} constr;

  char currentChar = 'X';
  //for (int i; currentChar != '\0'; i++) {
  while (true) {
    currentChar = self.read_byte()!;
    if (currentChar == '\0') break;
    constr.push(currentChar);
  }

  String output = (String)constr.to_tarray();
  constr.free();

  return output;
}

// Writing Functions
fn void? File.write_short(&self, short val) {
  self.write_byte((char)(val >> 0))!;
  self.write_byte((char)(val >> 8))!;
}
fn void? File.write_ushort(&self, ushort val) {
  self.write_byte((char)(val >> 0))!;
  self.write_byte((char)(val >> 8))!;
}

fn void? File.write_int(&self, int val) {
  self.write_byte((char)(val >>  0))!;
  self.write_byte((char)(val >>  8))!;
  self.write_byte((char)(val >> 16))!;
  self.write_byte((char)(val >> 24))!;
}
fn void? File.write_uint(&self, uint val) {
  self.write_byte((char)(val >>  0))!;
  self.write_byte((char)(val >>  8))!;
  self.write_byte((char)(val >> 16))!;
  self.write_byte((char)(val >> 24))!;
}

fn void? File.write_long(&self, long val) {
  self.write_byte((char)(val >>  0))!;
  self.write_byte((char)(val >>  8))!;
  self.write_byte((char)(val >> 16))!;
  self.write_byte((char)(val >> 24))!;
  self.write_byte((char)(val >> 32))!;
  self.write_byte((char)(val >> 40))!;
  self.write_byte((char)(val >> 48))!;
  self.write_byte((char)(val >> 56))!;
}
fn void? File.write_ulong(&self, ulong val) {
  self.write_byte((char)(val >>  0))!;
  self.write_byte((char)(val >>  8))!;
  self.write_byte((char)(val >> 16))!;
  self.write_byte((char)(val >> 24))!;
  self.write_byte((char)(val >> 32))!;
  self.write_byte((char)(val >> 40))!;
  self.write_byte((char)(val >> 48))!;
  self.write_byte((char)(val >> 56))!;
}

fn void? File.write_float(&self, float val) {
  char[] data = mem::new_array(char, float.sizeof);
  mem::copy(data, &val, float.sizeof);
  self.write(data)!;
  free(data);
}
fn void? File.write_double(&self, double val) {
  char[] data = mem::new_array(char, double.sizeof);
  mem::copy(data, &val, double.sizeof);
  self.write(data)!;
  free(data);
}

fn void? File.write_string(&self, String val) {
  for (int i; i < val.len; i++) self.write_byte(val[i])!;
  self.write_byte('\0')!;
}

