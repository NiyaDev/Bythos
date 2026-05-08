
module bythos;
import sdl3;
import opengl::gl;

//* -- Functions -- *//
fn void draw_start() @export("bythos_drawstart") {
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, core.framebuffer);
  gl::enable((GLenum)gl::GL_DEPTH_TEST);
  gl::viewport(0,0, core.render.x, core.render.y);

  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear((GLbitfield)gl::GL_COLOR_BUFFER_BIT | (GLbitfield)gl::GL_DEPTH_BUFFER_BIT);
}
fn void draw_end() @export("bythos_drawend") {
  gl::bindFramebuffer((GLenum)gl::GL_FRAMEBUFFER, 0);
  gl::disable((GLenum)gl::GL_DEPTH_TEST);
  gl::clearColor(0,0.5,0,1);
  gl::clear((GLbitfield)gl::GL_COLOR_BUFFER_BIT);
  gl::viewport(0, 0, core.screen.x, core.screen.y);
  
  gl::useProgram(core.frameShader.id);
  gl::bindTexture((GLenum)gl::GL_TEXTURE_2D, core.frameTexture.id);
  gl::bindVertexArray(core.quad.vao);
  gl::drawArrays((GLenum)gl::GL_TRIANGLES, 0, core.quad.vertices.len);
  gl::bindVertexArray(0);

  sdlgl::swapWindow(core.window);
}

fn void reset_framebuffer() {
  core.frameTexture.clean();
  core.frameTexture = texture::new(core.render.x, core.render.x);
}

