
module bythos::texture;
import std::io;
import std::collections;
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
fn ImageType to_type(String type) {
  String[] split = type.tsplit(".");
  switch (split[split.len-1]) {
    case "png": return PNG;
    case "ppm": return PPM;
    default:    return UNKNOWN;
  }
}

char[] def = $embed("../resources/texture.ppm");


fn Texture load(String filename) @export("texture_load") {
  debug::info("Loading Texture.", filename);

  File? file = file::open(filename, "rb");
  if (catch file)
    { debug::fatal("Failed to load image file", filename); }

  char[] data = mem::new_array(char, file::get_size(filename)!!);
  file.read(data)!!;
  defer free(data);
  
  return load_from_memory(data, to_type(filename));
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
      if (result != 0)
        { debug::error("Failed to set png buffer.", spng::strerror(result)); return {}; }

      result = spng::decoded_image_size(ctx, (int)Format.RGBA8, &imgSize);
      if (result != 0)
        { debug::error("Failed to get decoded size."); return {}; }

      // Copy width and height
      Ihdr ihdr;
      result = spng::get_ihdr(ctx, &ihdr);
      if (result != 0)
        { debug::error("Get ihdr failed.", spng::strerror(result)); return {}; }
      output.width  = ihdr.width;
      output.height = ihdr.height;

      // Decode image data and reverse
      img = mem::new_array(char, imgSize);

      result = spng::decode_image(ctx, (void*)img, imgSize, (int)Format.RGBA8, 0);
      if (result != 0)
        { debug::error("Failed to decode image.", spng::strerror(result)); free(img); return {}; }

      img.reverse(output.width, output.height, 4);
    case PPM:
      usz p;

      // Read magic numbers
      if (data[0:3] != "P6\n")
        { debug::error("PPM has invalid data.", spng::strerror(result)); return {}; }
      p += 3;

      List{char} builder;
      String out;

      // Width
      for (int i = (int)p; data[i] != ' '; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      output.width = out.to_int()!!;
      builder.clear();
      p++;

      // Height
      for (int i = (int)p; data[i] != '\n'; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      output.height = out.to_int()!!;
      builder.clear();
      p++;

      // value scale
      for (int i = (int)p; data[i] != '\n'; i++)
        { builder.push(data[i]); p++; }
      out = (String)builder.to_tarray();
      //output.height = out.to_int()!!;
      builder.clear();
      p++;

      // Read data
      img = data[p..].expand(0xff, 4);
    default:
      debug::error("Invalid filetype.");
      return {};
  }

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

  free(img);
  if (output.id == 0)
    { debug::error("Failed to upload image to OpenGL."); return {}; }

  return output;
}
fn Texture new(int width, int height) @export("texture_new") {
  debug::info("Generating a new blank texture.");

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
  debug::info("Cleaning up texture.");

  gl::deleteTextures(1, &self.id);
  self.id = 0;
  self.width = 0;
  self.height = 0;
}
fn void Texture.draw(&self,
    Rectangle dst = {},
    Rectangle src = {},
    Color tint = color::WHITE) {
  // Calculating size
  Vec2f newSize = {
    dst.w <= 0 ? self.width  : dst.w,
    dst.h <= 0 ? self.height : dst.h,
  };

  // Change texcoords
  Rectangle newSrc = {
    src.x, src.y,
    src.w <= 0 ? self.width  : src.w,
    src.h <= 0 ? self.height : src.h,
  };
  Vec2f topLeft  = {
    newSrc.x  / (float)self.width,
    1 - (newSrc.y  / (float)self.height),
  };
  Vec2f topRight = {
    (newSrc.x / (float)self.width) + (newSrc.w / (float)self.width),
    1 - (newSrc.y  / (float)self.height),
  };
  Vec2f botLeft  = {
    newSrc.x  / (float)self.width,
    1 - ((newSrc.y / (float)self.height) + (newSrc.h / (float)self.height)),
  };
  Vec2f botRight = {
    (newSrc.x / (float)self.width) + (newSrc.w / (float)self.width),
    1 - ((newSrc.y / (float)self.height) + (newSrc.h / (float)self.height)),
  }; 

  // Update Vertex info
  Mesh* mesh = bythos::core.storage.meshes.get_ref("texture")!!;
  mesh.update_texcoords({topLeft, botLeft, botRight, topLeft, botRight, topRight});

  // Start shader
  gl::useProgram(mesh.material.shader.id);

  // Update uniforms
  Vec2f position = {
    -(float)bythos::core.window.render.x + (dst.x * 2) + newSize.x,
    -(float)bythos::core.window.render.y + (dst.y * 2) + newSize.y,
  };
  mesh.material.shader.set_uniform("position", &position);
  mesh.material.shader.set_uniform("scale", &newSize);
  mesh.material.shader.set_uniform("texColor", &&tint.normalize());
  mesh.material.shader.set_uniform("texOffset", &&(Vec2f){0,0});
  mesh.material.shader.set_uniform("texScale", &&(Vec2f){1,1});

  gl::bindTexture(gl::GL_TEXTURE_2D, self.id);
  gl::disable(gl::GL_DEPTH_TEST);

  // Draw
  gl::bindVertexArray(mesh.vao);
  gl::drawArrays(gl::GL_TRIANGLES, 0, mesh.vertices.len);
  gl::bindVertexArray(0);

  // Reset
  gl::enable(gl::GL_DEPTH_TEST);
  mesh.update_texcoords({{0,1}, {0,0}, {1,0}, {0,1}, {1,0}, {1,1}});
}
fn void Texture.draw_instanced(&self, Rectangle[] dst, Rectangle[] src, Color[] tint) {
  Vec2f render = bythos::core.window.render;
  Mesh* mesh = bythos::core.storage.meshes.get_ref("texture")!!;

  gl::disable(gl::GL_DEPTH_TEST);
  gl::bindVertexArray(mesh.vao);
  gl::bindTexture(gl::GL_TEXTURE_2D, self.id);
  gl::useProgram(mesh.material.shader.id);

  for (int i; i < dst.len; i++) {
    Vec2f newSize = {
      dst[i].w <= 0 ? self.width  : dst[i].w,
      dst[i].h <= 0 ? self.height : dst[i].h,
    };
    Vec4f texCoords = {
      src[i].x / self.width,
      src[i].y / self.height,
      src[i].w <= 0 ? self.width  : src[i].w / self.width,
      src[i].h <= 0 ? self.height : src[i].h / self.height,
    };

    mesh.material.shader.set_uniform("position", &&(Vec2f){
      -render.x + (dst[i].x * 2) + newSize.x,
      -render.y + (dst[i].y * 2) + newSize.y,
    });
    mesh.material.shader.set_uniform("scale", &newSize);
    mesh.material.shader.set_uniform("texColor", &&tint[i].normalize());
    mesh.material.shader.set_uniform("texOffset", &&(Vec2f){texCoords.x, (1-texCoords.w) - texCoords.y});
    mesh.material.shader.set_uniform("texScale", &&texCoords.zw);

    gl::drawArrays(gl::GL_TRIANGLES, 0, mesh.vertices.len);
  }

  gl::bindVertexArray(0);
  gl::enable(gl::GL_DEPTH_TEST);
}

fn char[] char[].expand(self, char value, int offset) {
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

