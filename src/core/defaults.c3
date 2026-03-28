
module bythos;


//* -- Getting -- *//
fn Mesh get_default_mesh() @export("default_getmesh") => core.defaultMesh;
fn Mesh get_default_texturemesh() @export("default_gettexturemesh") => core.textureMesh;
fn Texture get_default_texture() @export("default_gettexture") => core.defaultTexture;
fn Material get_default_material() @export("default_getmaterial") => core.defaultMaterial;
fn Shader get_default_2dshader() @export("default_get2dshader") => core.defaultShader2d;
fn Shader get_default_3dshader() @export("default_get3dshader") => core.defaultShader3d;

//* -- Setting -- *//
fn void set_default_mesh(Mesh m) @export("default_setmesh") {
  core.defaultMesh.clean();
  core.defaultMesh = m;
} 
fn void set_default_texture(Texture t) @export("default_settexture") {
  core.defaultTexture.clean();
  core.defaultTexture = t;
}
fn void set_default_material(Material m) @export("default_setmaterial") {
  core.defaultMaterial.clean();
  core.defaultMaterial = m;
}
fn void set_default_2dshader(Shader s) @export("default_set2dshader") {
  core.defaultShader2d.clean();
  core.defaultShader2d = s;
}
fn void set_default_3dshader(Shader s) @export("default_set3dshader") {
  core.defaultShader3d.clean();
  core.defaultShader3d = s;
}

//* -- Framebuffer -- *//
fn void set_framebuffer_shader(Shader s) @export("default_framebuffershader") {
  core.frameShader.clean();
  core.frameShader = s;
}
fn void set_framebuffer_texture(Texture t) @export("defualt_framebuffertexture") {
  core.frameTexture.clean();
  core.frameTexture = t;
}

