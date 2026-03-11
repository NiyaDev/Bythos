
import bythos;
import std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Tests -- *//
fn void window() @test {
  debug::@benchmark("Initialization")
    { bythos::init(); };

  Mesh m = mesh::new(CUBE);
  //io::printfn("%s, %s, %s, %s",mesh::VERTEX_POSITION, mesh::VERTEX_NORMAL, mesh::VERTEX_TEXCOORD, mesh::VERTEX_COLOR);
  uint program = bythos::core.defaultShader3d.id;
  gl::useProgram(program);
  uint projloc = gl::getUniformLocation(program, "projection");
  Matrix4f projection = matrix::perspective{float}(70 * math::PI / 180, (float)bythos::core.render.x / (float)bythos::core.render.y, 0.1, 100).transpose();
  gl::uniformMatrix4fv(projloc, 1, gl::GL_FALSE, (float*)&projection);
  //io::printfn("%s",projloc);

  bythos::@loop() {
    camera::rotate(0.1);
    camera::update();
    //m.draw(position: {1,0,0});
    bythos::core.defaultMesh.draw(scale:{1.1,1,1});
  };

  m.clean();

  bythos::clean();
  assert(false);
}



