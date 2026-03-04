
module bythos;

fn void set_default_shader2d(Shader sh) @export("defaults_shader2d") {
  if (core.defaultShader2d.id > 4) { core.defaultShader2d.clean(); }

  core.defaultShader2d = sh;
  debug::info(string::tformat("SHADER: [ID %d] Default 2D Shader set", sh.id));
}
fn void set_default_shader3d(Shader sh) @export("defaults_shader3d") {
  if (core.defaultShader3d.id > 4) { core.defaultShader3d.clean(); }

  core.defaultShader3d = sh;
  debug::info(string::tformat("SHADER: [ID %d] Default 3D Shader set", sh.id));
}

fn void set_default_texture(Texture t) @export("defaults_texture") {
  if (core.defaultTexture.id > 1) { core.defaultTexture.clean(); }

  core.defaultTexture = t;
  debug::info(string::tformat("TEXTURE: [ID %d] Default texture set", t.id));
}

fn void set_default_quad(Mesh m) @export("defaults_texture") {
  if (core.quad.vao > 3) { core.quad.clean(); }

  core.quad = m;
  debug::info(string::tformat("MESH: [ID %d] Default quad mesh set", m.vao));
}
fn void set_default_mesh(Mesh m) @export("defaults_texture") {
  if (core.defaultMesh.vao > 3) { core.defaultMesh.clean(); }

  core.defaultMesh = m;
  debug::info(string::tformat("MESH: [ID %d] Default mesh set", m.vao));
}
fn void set_default_texturemesh(Mesh m) @export("defaults_texture") {
  if (core.textureMesh.vao > 3) { core.textureMesh.clean(); }

  core.textureMesh = m;
  debug::info(string::tformat("MESH: [ID %d] Default default texture mesh set", m.vao));
}

