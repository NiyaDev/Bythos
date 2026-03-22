
module bythos;

//* -- Structures -- *//
struct Texture {
  uint id;
  uint w, h;
}

//* -- Enums -- *//
enum TilingLayout {
  THREE_THREE,
  ONE_THREE,
  THREE_ONE,
}


module bythos::texture;
import std::collections, std::io;
import opengl::gl;
import spng;
import bythos;

//* -- Globals -- *//
char[] def = $embed("../../resources/texture.ppm");

//* -- Functions -- *//
fn Texture load(String filename) @export("texture_load") {
  File? file = file::open(filename, "rb");
  if (catch file) { debug::error("TEXTURE: Failed to open file", filename); return {}; }

  char[] data = mem::new_array(char, file::get_size(filename)!!);
  file.read(data)!!;

  Texture output = load_from_memory(data, filename.to_tpath().extension()!!);
  free(data);

  return output;
}
fn Texture load_from_memory(char[] data, String type = "png") @export("texture_loadfromme") {
  Texture output;
  int result;
  char[] img;

  switch (type) {
    case "png":
    case "PNG":
      //* -- Create context and get decoded size -- *//
      Ctx* ctx = spng::ctx_new(0);
      defer spng::ctx_free(ctx);
      usz imgSize;

      result = spng::set_png_buffer(ctx, data, data.len);
      if (result != 0) { debug::error("Failed to set png buffer.", spng::strerror(result)); return {}; }
      result = spng::decoded_image_size(ctx, (int)Format.RGBA8, &imgSize);
      if (result != 0) { debug::error("Failed to get decoded size."); return {}; }

      //* -- Copy width and height -- *//
      Ihdr ihdr;
      result = spng::get_ihdr(ctx, &ihdr);
      if (result != 0)
        { debug::error("Get ihdr failed.", spng::strerror(result)); return {}; }
      output.w = ihdr.width;
      output.h = ihdr.height;

      //* -- Decode image data and reverse -- *//
      img = mem::new_array(char, imgSize);

      result = spng::decode_image(ctx, (void*)img, imgSize, (int)Format.RGBA8, 0);
      if (result != 0) { debug::error("Failed to decode image.", spng::strerror(result)); free(img); return {}; }

      img.reverse(output.w, output.h, 4);

    case "ppm":
    case "PPM":
      usz p;

      //* -- Read magic numbers -- *//
      if (data[0:3] != "P6\n") { debug::error("PPM has invalid data.", spng::strerror(result)); return {}; }
      p += 3;

      List{char} builder;
      String out;

      //* -- Read Width & Height -- *//
      for (int i = (int)p; data[i] != ' '; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      output.w = out.to_int()!!;
      builder.clear();
      p++;
      for (int i = (int)p; data[i] != '\n'; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      output.h = out.to_int()!!;
      builder.clear();
      p++;

      //* -- Read value scale -- *//
      for (int i = (int)p; data[i] != '\n'; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      builder.clear();
      p++;

      //* -- Read data -- *//
      img = data[p..].expand(0xff, 4);

    default:
      debug::error("Invalid filetype.");
      return {};
  }

  //* -- Gen OpenGL texture -- *//
  gl::genTextures(1, &output.id);
  gl::bindTexture(gl::GL_TEXTURE_2D, output.id);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    output.w, output.h, 0,
    gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, img);
  gl::generateMipmap(gl::GL_TEXTURE_2D);

  free(img);
  if (output.id == 0) { debug::error("Failed to upload image to OpenGL."); return {}; }

  debug::info(string::tformat("TEXTURE: [ID %d] Texture loaded successfully (%dx%d)", output.id, output.w, output.h));

  return output;
} 
fn Texture new(int width, int height) @export("texture_new") {
  uint id;
  gl::genTextures(1, &id);
  gl::bindTexture(gl::GL_TEXTURE_2D, id);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    width, height, 0,
    gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, null);
  gl::generateMipmap(gl::GL_TEXTURE_2D);

  debug::info(string::tformat("TEXTURE: [ID %d] Texture loaded successfully (%dx%d)", id, width, height));

  return {id, width, height};
}
fn void Texture.clean(&self) @export("texture_clean") {
  debug::info(string::tformat("TEXTURE: [ID %d] Cleaned up", self.id));

  gl::deleteTextures(1, &self.id);
  *self = {0,0,0};
}
fn bool Texture.is_valid(&self) @export("texture_valid")
  => self.id != 0 && self.w != 0 && self.h != 0;

fn char[] Texture.get_raw(&self) @export("texture_getraw") {
  char[] data = mem::new_array(char, 4 * ((usz)self.w * (usz)self.h));
  gl::readPixels(0, 0, self.w, self.h, gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, data);

  return data;
}
fn void Texture.save(&self, String filename = "texture.ppm") @export("texture_save") {
  char[] data = self.get_raw();
  data.reverse(self.w, self.h, 4);
  defer free(data);

  int result;

  switch (filename.to_tpath().extension()!!) {
    case "png":
      Ctx* enc = spng::ctx_new((int)CTXFlags.ENCODER);
      defer spng::ctx_free(enc);

      result = spng::set_option(enc, spng::Option.ENCODE_TO_BUFFER, 1);
      if (result != 0) { debug::error("set_options() error:", spng::strerror(result)); return; }

      Ihdr ihdr = {
        self.w, self.h,
        8, (char)ColorType.TRUECOLOR_ALPHA,
        0, 0, 0,
      };
      result = spng::set_ihdr(enc, &ihdr);
      if (result != 0) { debug::error("set_ihdr() error:", spng::strerror(result)); return; }

      result = spng::encode_image(enc, data, data.len, (int)Format.PNG, (int)EncodeFlags.FINALIZE);
      if (result != 0) { debug::error("encode_image() error:", spng::strerror(result)); return; }

      usz pngSize;
      void* png = spng::get_png_buffer(enc, &pngSize, &result);
      if (result != 0) { debug::error("get_png_buffer() error:", spng::strerror(result)); return; }

      file::save(filename, ((char*)png)[:pngSize])!!;
    case "ppm":
      File? f = file::open(filename, "wb");
      if (catch f) { debug::warning("Failed to open file", filename); return; }
      
      f.write(string::tformat("P6\n%d %d\n255\n", self.w, self.h))!!;
      usz index;
      for (int i; i < data.len; i++) {
        if (index == 3) { index = 0; continue; }
        else { index++; }
        f.write_byte(data[i])!!;
      }
      //f.write(data)!!;
    default: debug::warning("Attempted to save texture as invalid file type");
  }
}

fn char[] char[].expand(self, char value, usz offset) {
  char[] output = mem::new_array(char, self.len + (self.len / offset) + 1);
  int count = 1;
  int target = 0;
  for (int i; i < output.len; i++) {
    if (count == offset)
      { output[i] = value; count = 1; }
    else
      { output[i] = self[target++]; count++; }
  }
  output[output.len-1] = value;
  return output;
}
fn void char[].reverse(self, usz width, usz height, int bytesPerPixel) {
  usz stride = width * bytesPerPixel;
  char[] row = mem::new_array(char, stride);
  for (int y; y < height / 2; y++) {
    char* top = (char*)self + y * stride;
    char* bot = (char*)self + (height - y - 1) * stride;

    mem::copy(row, top, stride);
    mem::copy(top, bot, stride);
    mem::copy(bot, row, stride);
  }
  free(row);
}

