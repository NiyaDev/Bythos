
module bythos;
import sdl3;
import opengl::gl;

//* -- Functions -- *//
fn void draw_start() @export("bythos_drawstart") {
  //gl::bindFramebuffer(gl::GL_FRAMEBUFFER, core.framebuffer);
  //gl::enable(gl::GL_DEPTH_TEST);
  gl::viewport(0,0, core.render.x, core.render.y);

  gl::clearColor(0.5,0.5,0.5,1);
  gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

  //gl::polygonMode(gl::GL_FRONT_AND_BACK, gl::GL_LINE);
}
fn void draw_end() @export("bythos_drawend") {
  //gl::bindFramebuffer(gl::GL_FRAMEBUFFER, 0);
  //gl::disable(gl::GL_DEPTH_TEST);
  //gl::clearColor(0,0.5,0,1);
  //gl::clear(gl::GL_COLOR_BUFFER_BIT);
  //gl::viewport(0, 0, core.screen.x, core.screen.y);
  
  //core.quad.draw();
  sdlgl::swapWindow(core.window);
}

