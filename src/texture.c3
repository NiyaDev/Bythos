
module bythos::texture;
import std::io;
import spng;
import opengl::gl;
import bythos;


struct Texture {
  uint id;
  uint width, height;
  int mipmaps;
  int format;
}
enum TilingLayout {
  THREE_THREE,
  ONE_THREE,
  THREE_ONE,
}
enum ImageType {
  UNKNOWN,
  PNG,
  PPM,
}

char[] def = $embed("../resources/texture.ppm");


fn Texture load(String filename) @export("texture_load") {
  File? file = file::open(filename, "rb");
  if (catch file) debug::fatal("Failed to load image file", filename);

  char[] data = mem::new_array(char, file::get_size(filename)!!);
  file.read(data)!!;
  defer free(data);

  ImageType type;
  String[] split = filename.split(mem, ".");
  switch (split[split.len-1]) {
    case "png": type = PNG;
    case "ppm": type = PPM;
    default:    type = UNKNOWN;
  }
  
  return load_from_memory(data, type);
}
fn Texture load_from_memory(char[] data, ImageType type = PNG) @export("texture_loadfrommem") {
  Texture output;
  int result;
  char[] img;

  switch (type) {
    case PNG:
      // Create context and get decoded size
      Ctx* ctx = spng::ctx_new(0);
      defer spng::ctx_free(ctx);
      usz imgSize;

      result = spng::set_png_buffer(ctx, data, data.len);
      if (result != 0) {
        debug::error("Failed to set png buffer.");
        return load_from_memory(def, PPM);
      }

      result = spng::decoded_image_size(ctx, (int)Format.RGBA8, &imgSize);
      if (result != 0) {
        debug::error("Failed to get decoded size.");
        return load_from_memory(def, PPM);
      }

      // Copy width and height
      Ihdr ihdr;
      result = spng::get_ihdr(ctx, &ihdr);
      if (result != 0) {
        debug::error("Get ihdr failed.", spng::strerror(result));
        return load_from_memory(def, PPM);
      }
      output.width = ihdr.width;
      output.height = ihdr.height;

      // Decode image data and reverse
      img = mem::new_array(char, imgSize);

      result = spng::decode_image(ctx, (void*)img, imgSize, (int)Format.RGBA8, 0);
      if (result != 0) {
        debug::error("Failed to decode image.");
        return load_from_memory(def, PPM);
      }
      img.reverse(output.width, output.height, 4);
    case PPM:
      // TODO: Read PPM properly
      output.width = 2;
      output.height = 2;
      img = data[11..].expand(0xff, 4);
    default:
      debug::error("Invalid filetype.");
  }
  io::printfn("%s",img);

  // Gen OpenGL texture
  gl::genTextures(1, &output.id);
  gl::bindTexture(gl::GL_TEXTURE_2D, output.id);

  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    output.width, output.height, 0,
    gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, img);
  gl::generateMipmap(gl::GL_TEXTURE_2D);
  if (output.id == 0) {
    debug::error("Failed to upload image to OpenGL.");
    return load_from_memory(def, PPM);
  }
  free(img);

  return output;
}
fn Texture new(int width, int height) @export("texture_new") {
  Texture output;
  output.width = width;
  output.height = height;

  gl::genTextures(1, &output.id);
  gl::bindTexture(gl::GL_TEXTURE_2D, output.id);
  
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri(gl::GL_TEXTURE_2D, gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    width, height, 0,
    gl::GL_RGBA, gl::GL_UNSIGNED_BYTE, null);
  gl::generateMipmap(gl::GL_TEXTURE_2D);

  return output;
}
fn void Texture.clean(&self) @export("texture_clean") {
  gl::deleteTextures(1, &self.id);
  self.id = 0;
  self.width = 0;
  self.height = 0;
}
fn char[] char[].expand(self, char value, int offset) {
  char[] output = mem::new_array(char, self.len + (self.len / offset) + 1);
  io::printfn("%d",output.len);
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
/*
fn void Texture.draw(&self,
    Rectangle dst = {},
    Rectangle src = {},
    Color tint = color::WHITE) {
  // Calculating size
  Vec2f newSize = {
    dst.w <= 0 ? self.width  : dst.w,
    dst.h <= 0 ? self.height : dst.h,
  };
  Vec2f scale = {
    newSize.x / (float)bythos::bythos.renderWidth,
    newSize.y / (float)bythos::bythos.renderHeight,
  };
}
*/
