
import bythos;
import std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Tests -- *//
///*
fn void window() @test {
  debug::@benchmark("Initialization") { bythos::init(); };

  Texture tex = texture::load("resources/font.png");

  //float rotation;
  bythos::@loop() {
    tex.draw(dst:{0,0,200,100},src:{0,0,624,96});
    //rotation += 0.01;
    //if (keybinds::is_down("test")) Camera.rotate(target:1);

    //Mesh.draw(position:{0,-1,0});
    //Mesh.draw_instanced(mats:{
    //  MATRIX4F_IDENTITY.translate({0,0,0}).rotate_z(0).rotate_y(0).rotate_x(0).scale({1,1,1}).transpose(),
    //  MATRIX4F_IDENTITY.translate({1,0,0}).rotate_z(0).rotate_y(0).rotate_x(0).scale({1,1,1}).transpose(),
    //  MATRIX4F_IDENTITY.translate({0,0,-1}).rotate_z(0).rotate_y(0).rotate_x(0).scale({1,1,1}).transpose(),
    //  MATRIX4F_IDENTITY.translate({0,1,0}).rotate_z(0).rotate_y(0).rotate_x(0).scale({1,1,1}).transpose(),
    //});
    //Texture.draw(dst:{32,32,32,32});
    //Texture.draw_instanced(
    //  dst:{
    //    {0,0,32,32},
    //    {32,32,32,32},
    //    {128,32,64,32},
    //  },
    //  src:{{},{},{}},
    //  tint:{color::WHITE,color::WHITE,color::WHITE},
    //);
    //Texture.draw_billboard(position:{-5,0,0}, scale:{0.5,0.5,0.5});
    //Texture.draw_billboard_instanced(src:{{},{}}, position:{{-5,0,0},{1,2,0}}, scale:{{0.5,0.5,0.5},{1,1,1}});
    //Font.draw(text:"TEST", position:{100,100});
    if (keybindings::is_pressed("test")) debug::@benchmark("Screenshot png") {bythos::screenshot("screenshot.png");};
    //if (keybinds::is_pressed("test")) debug::@benchmark("Screenshot ppm") {bythos::screenshot("screenshot.ppm");};
    bythos::quit(0);
  };

  bythos::clean();
  //assert(false);
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
  Shader sh = shader::compile(shader::DEFAULT_VERTEX_3D, shader::DEFAULT_FRAGMENT_3D);
  //sh.set_matrix("projection", matrix::perspective{float}(70 * (math::PI / 180), 1.777, 0.1, 100).transpose());

  // Mesh
  Mesh m = mesh::new(CUBE);

  //Matrix4f projection, view, model;
  uint loc1 = gl::getUniformLocation(sh.id, "projection");
  //uint loc2 = gl::getUniformLocation(sh.id, "view");
  //uint loc3 = gl::getUniformLocation(sh.id, "model");

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

    m.draw(mat:{sh,{}}, rotation:{0,rotation,0});

    sdlgl::swapWindow(window);

    if (deltaTime < (1000 / 60)) {
      sdl3::delay((uint)((1000 / 60) - deltaTime));
    }
  };

  assert(false);
}
*/
