
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
import std::collections, std::io, std::math;
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
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, output.id);
  gl::texParameteri((GLenum)gl::GL_TEXTURE_2D, (GLenum)gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri((GLenum)gl::GL_TEXTURE_2D, (GLenum)gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    (GLenum)gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    output.w, output.h, 0,
    (GLenum)gl::GL_RGBA, (GLenum)gl::GL_UNSIGNED_BYTE, img);
  gl::generateMipmap((GLenum)gl::GL_TEXTURE_2D);

  free(img);
  if (output.id == 0) { debug::error("Failed to upload image to OpenGL."); return {}; }

  debug::info(string::tformat("TEXTURE: [ID %d] Texture loaded successfully (%dx%d)", output.id, output.w, output.h));

  return output;
} 
fn Texture new(int width, int height) @export("texture_new") {
  uint id;
  gl::genTextures(1, &id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, id);
  gl::texParameteri((GLenum)gl::GL_TEXTURE_2D, (GLenum)gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST);
  gl::texParameteri((GLenum)gl::GL_TEXTURE_2D, (GLenum)gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST);

  gl::texImage2D(
    (GLenum)gl::GL_TEXTURE_2D, 0, gl::GL_RGBA,
    width, height, 0,
    (GLenum)gl::GL_RGBA, (GLenum)gl::GL_UNSIGNED_BYTE, null);
  gl::generateMipmap((GLenum)gl::GL_TEXTURE_2D);

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

fn void Texture.draw(&self = &&bythos::get_default_texture(), Rectangle dst = {}, Rectangle src = {}, Color tint = color::WHITE) @export("texture_draw") {
  //* -- Calculating size on screen -- *//
  Vec2f newSize = {
    dst.w == 0 ? self.w : dst.w,
    dst.h == 0 ? self.h : dst.h,
  };
  Vec4f newSrc = {
    src.x, src.y,
    src.w == 0 ? self.w : src.w,
    src.h == 0 ? self.h : src.h,
  };

  //* -- Draw -- *//
  gl::useProgram(bythos::core.defaultShader2d.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, self.id);
  bythos::core.defaultShader2d.set_vec2("position", {
    -(float)bythos::core.render.x + (dst.x * 2) + newSize.x,
    -(float)bythos::core.render.y + (dst.y * 2) + newSize.y,
  });
  bythos::core.defaultShader2d.set_vec2("scale", newSize);
  bythos::core.defaultShader2d.set_vec2("texOffset", {newSrc.x, (1-newSrc.w) - newSrc.y});
  bythos::core.defaultShader2d.set_vec2("texScale", newSrc.zw / 2);
  bythos::core.defaultShader2d.set_vec4("texColor", tint.normalize());
  gl::disable((GLenum)gl::GL_DEPTH_TEST);
  gl::bindVertexArray(bythos::core.textureMesh.vao);
  gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, bythos::core.textureMesh.vertices.len);
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
  gl::bindVertexArray(0);
}
fn void Texture.draw_instanced(&self = &&bythos::get_default_texture(), Rectangle[] dst, Rectangle[] src, Color[] tint) @export("texture_drawinstanced") {
  gl::disable((GLenum)gl::GL_DEPTH_TEST);
  gl::bindVertexArray(bythos::core.textureMesh.vao);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, self.id);
  gl::useProgram(bythos::core.defaultShader2d.id);

  for (int i; i < dst.len; i++) {
    Vec2f newSize = {
      dst[i].w == 0 ? self.w : dst[i].w,
      dst[i].h == 0 ? self.h : dst[i].h,
    };
    Vec4f texCoords = {
      src[i].x, src[i].y,
      src[i].w == 0 ? self.w : src[i].w,
      src[i].h == 0 ? self.h : src[i].h,
    };

    bythos::core.defaultShader2d.set_vec2("position", {
      -(float)bythos::core.render.x + (dst[i].x * 2) + newSize.x,
      -(float)bythos::core.render.y + (dst[i].y * 2) + newSize.y,
    });
    bythos::core.defaultShader2d.set_vec2("scale", newSize);
    bythos::core.defaultShader2d.set_vec4("texColor", tint[i].normalize());
    bythos::core.defaultShader2d.set_vec2("texOffset", {texCoords.x, (1-texCoords.w) - texCoords.y});
    bythos::core.defaultShader2d.set_vec2("texScale", texCoords.zw / 2);

    gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, bythos::core.textureMesh.vertices.len);
  }

  gl::bindVertexArray(0);
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
}
fn void Texture.draw_billboard(&self = &&bythos::get_default_texture(), Rectangle src = {}, Vec3f position = {}, Vec3f scale = {1,1,1}) @export("texture_drawbillboard") {
  gl::disable((GLenum)gl::GL_DEPTH_TEST);
  Shader sh = bythos::get_default_3dshader();
  gl::useProgram(sh.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, self.id);
  Matrix4f view = Camera.get_matrix();
  sh.set_matrix("view", view);
  Vec3f r = (Vec3f){view.m00, view.m10, view.m20} * scale.x;
  Vec3f u = (Vec3f){view.m01, view.m11, view.m21} * scale.y;
  Vec3f f = (Vec3f){view.m02, view.m12, view.m22} * scale.z;
  sh.set_matrix("model", {
    r.x, r.y, r.z, 0,
    u.x, u.y, u.z, 0,
    f.x, f.y, f.z, 0,
    position.x, position.y, position.z, 1,
  });

  //* -- Draw -- *//
  Mesh m = bythos::get_default_texturemesh();
  gl::bindVertexArray(m.vao);
  gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, m.vertices.len);
  gl::bindVertexArray(0);
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
}
fn void Texture.draw_billboard_instanced(&self = &&bythos::get_default_texture(), Rectangle[] src, Vec3f[] position, Vec3f[] scale) @export("texture_drawbillboardinstanced") {
  gl::disable((GLenum)gl::GL_DEPTH_TEST);
  Shader sh = bythos::get_default_3dshader();
  gl::useProgram(sh.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, self.id);

  Matrix4f view = Camera.get_matrix();
  sh.set_matrix("view", view);
  Mesh m = bythos::get_default_texturemesh();
  for (int i; i < src.len; i++) {
    Vec3f r = (Vec3f){view.m00, view.m10, view.m20} * scale[i].x;
    Vec3f u = (Vec3f){view.m01, view.m11, view.m21} * scale[i].y;
    Vec3f f = (Vec3f){view.m02, view.m12, view.m22} * scale[i].z;
    sh.set_matrix("model", {
      r.x, r.y, r.z, 0,
      u.x, u.y, u.z, 0,
      f.x, f.y, f.z, 0,
      position[i].x, position[i].y, position[i].z, 1,
    });

    //* -- Draw -- *//
    gl::bindVertexArray(m.vao);
    gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, m.vertices.len);
  }
  gl::bindVertexArray(0);
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
}

fn char[] Texture.get_raw(&self) @export("texture_getraw") {
  char[] data = mem::new_array(char, 4 * ((usz)self.w * (usz)self.h));
  gl::readPixels(0, 0, self.w, self.h, (GLenum)gl::GL_RGBA, (GLenum)gl::GL_UNSIGNED_BYTE, data);

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

