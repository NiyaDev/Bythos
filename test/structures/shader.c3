
import std::math;
import bythos;

fn void render() @test {
  bythos::init();

  Shader sh = shader::load("","resources/tests/shader_test.vs");
  Texture texture = texture::load("resources/tests/shader.png");
  sh.set_vec2("u_resolution", {1280,720});
  sh.set_vec4("u_mouse", {640,360,0,0});
  bythos::set_framebuffer_shader(sh);

  float time;

  bythos::@loop() {
    sh.set_float("u_time", time);
    time += 0.01;
  };

  bythos::clean();
}
/* TODO: Create shader to test things with
fn void set_uniforms() @test {
  Shader s = shader::compile();

  shader::set_uniform{int}  (&s, "test", 0);
  shader::set_uniform{float}(&s, "test", 0.1);
  shader::set_uniform{Vec2f}(&s, "test", {0,0});
  shader::set_uniform{Vec3f}(&s, "test", {0,0,0});
  shader::set_uniform{Vec4f}(&s, "test", {0,0,0,0});
  shader::set_uniform{Matrix4f}(&s, "test", {});
  shader::set_uniform{Texture}(&s, "test", {});

  assert(false,"End");
}
*/

