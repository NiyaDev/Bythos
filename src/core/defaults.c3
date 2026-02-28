
module bythos;

fn void set_default_shader2d(Shader sh) @export("defaults_shader2d") {
  // If the shader is one of the defaults loaded it isn't tracked by the user
  if (core.defaultShader2d.id > 4)
    { core.defaultShader2d.clean(); }

  core.defaultShader2d = sh;
  debug::info(string::tformat("SHADER: [ID %d] Default 2D Shader set", sh.id));
}
fn void set_default_shader3d(Shader sh) @export("defaults_shader2d") {
  // If the shader is one of the defaults loaded it isn't tracked by the user
  if (core.defaultShader3d.id > 4)
    { core.defaultShader3d.clean(); }

  core.defaultShader3d = sh;
  debug::info(string::tformat("SHADER: [ID %d] Default 3D Shader set", sh.id));
}
