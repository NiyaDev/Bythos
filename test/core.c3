
import bythos;
import std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Tests -- *//
///*
fn void window() @test {
  debug::@benchmark("Initialization")
    { bythos::init(); };

  Mesh m = mesh::new(CUBE);
  //io::printfn("%s, %s, %s, %s",mesh::VERTEX_POSITION, mesh::VERTEX_NORMAL, mesh::VERTEX_TEXCOORD, mesh::VERTEX_COLOR);
  //uint program = bythos::core.defaultShader3d.id;
  //gl::useProgram(program);
  //uint projloc = gl::getUniformLocation(program, "projection");
  //Matrix4f projection = matrix::perspective{float}(70 * math::PI / 180, (float)bythos::core.render.x / (float)bythos::core.render.y, 0.1, 100).transpose();
  //gl::uniformMatrix4fv(projloc, 1, gl::GL_FALSE, (float*)&projection);
  //io::printfn("%s",projloc);

  bythos::@loop() {
    //camera::rotate(0.1);
    //camera::update();
    m.draw(position: {1,0,0});
    //bythos::core.defaultMesh.draw(scale:{1,1,1});
  };

  m.clean();

  bythos::clean();
  assert(false);
}
//*/

/*
fn void restart() @test {
  // Startup
  if (!sdl3::init({.video = true, .audio = true})) 
    { debug::fatal("Failed to initialize SDL3", sdl3::getError()); }
  sdlgl::setAttribute(GLAttr.CONTEXT_MAJOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_MINOR_VERSION, 3);
  sdlgl::setAttribute(GLAttr.CONTEXT_PROFILE_MASK, sdlgl::CONTEXT_PROFILE_CORE);
  sdl3::Window* window = sdl3::createWindow("WTF", 1280, 720, {.opengl = true});
  if (!window) debug::fatal("Failed to create SDL3 window", sdl3::getError());
  
  sdl3::GLContext* context = sdlgl::createContext(window);
  if (!context) debug::fatal("Failed to create OpenGL context", sdl3::getError());
  if (!sdlgl::makeCurrent(window, context)) debug::fatal("Failed to make GLContext current", sdl3::getError());
  int? result = opengl::init((gl::GLLoadFn)&sdlgl::getProcAddress);
  if (catch result) debug::fatal("Failed to load OpenGL functions");
  gl::enable(gl::GL_DEPTH_TEST);

  // shader
  int resultsh;
  Shader sh;

  uint v = gl::createShader(gl::GL_VERTEX_SHADER);
  gl::shaderSource(v, 1, &&((char*)shader::DEFAULT_VERTEX_3D), null);
  gl::compileShader(v);

  uint f = gl::createShader(gl::GL_FRAGMENT_SHADER);
  gl::shaderSource(f, 1, &&((char*)shader::DEFAULT_FRAGMENT_3D), null);
  gl::compileShader(f);

  sh.id = gl::createProgram();
  gl::attachShader(sh.id, v);
  gl::attachShader(sh.id, f);
  gl::linkProgram(sh.id);

  gl::deleteShader(v);
  gl::deleteShader(f);

  // Mesh
  Mesh m;
  gl::genVertexArrays(1, &m.vao);
  gl::genBuffers(1, &m.vbo);
  gl::bindVertexArray(m.vao);
  gl::bindBuffer(gl::GL_ARRAY_BUFFER, m.vbo);
  gl::bufferData(gl::GL_ARRAY_BUFFER, mesh::BASIC_CUBE.len * bythos::Vertex.sizeof, mesh::BASIC_CUBE, gl::GL_STATIC_DRAW);

  gl::vertexAttribPointer(0, 3, gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)0);
  gl::enableVertexAttribArray(0);
  gl::vertexAttribPointer(1, 3, gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)12);
  gl::enableVertexAttribArray(1);
  gl::vertexAttribPointer(2, 2, gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)24);
  gl::enableVertexAttribArray(2);
  gl::vertexAttribPointer(3, 4, gl::GL_FLOAT, gl::GL_FALSE, bythos::Vertex.sizeof, (void*)32);
  gl::enableVertexAttribArray(3);

  Matrix4f projection, view, model;
  uint loc1 = gl::getUniformLocation(sh.id, "projection");
  uint loc2 = gl::getUniformLocation(sh.id, "view");
  uint loc3 = gl::getUniformLocation(sh.id, "model");

  gl::useProgram(sh.id);
  projection = matrix::perspective{float}(70 * (math::PI / 180), 1.777, 0.1, 100).transpose();
  gl::uniformMatrix4fv(loc1, 1, gl::GL_FALSE, (float*)&projection);


  double deltaTime, lastFrame;
  float rotation;

  while (true) {
    double currentFrame = ((double)sdl3::getTicks() / 1000);
    deltaTime = currentFrame - lastFrame;
    lastFrame = currentFrame;

    Event event;
    while (sdl3::pollEvent(&event)) {
      if (event.type == QUIT) {
        assert(false);
        return;
      }
    }

    rotation += 0.01;

    gl::clearColor(0.5,0.5,0.5,1);
    gl::clear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);
    //gl::polygonMode(gl::GL_FRONT_AND_BACK, gl::GL_LINE);

    gl::useProgram(sh.id);
    gl::uniformMatrix4fv(loc2, 1, gl::GL_FALSE, (float*)&&matrix::look_at{float}({0,5,5}, {0,0,0}, {0,1,0}).transpose());
    gl::uniformMatrix4fv(loc3, 1, gl::GL_FALSE, (float*)&&MATRIX4F_IDENTITY.translate({0,0,0}).rotate_z(0).rotate_y(rotation).rotate_x(0).scale({1,1,1}).transpose());

    gl::bindVertexArray(m.vao);
    gl::drawArrays(gl::GL_TRIANGLES, 0, mesh::BASIC_CUBE.len);

    sdlgl::swapWindow(window);

    if (deltaTime < (1000 / 60)) {
      sdl3::delay((uint)((1000 / 60) - deltaTime));
    }
  };

  assert(false);
}
*/
