
import std::math;
import bythos;

fn void render() @test {
  bythos::init();

  Shader sh = shader::load("","resources/tests/shader_test.vs");
  Texture texture = texture::load("resources/tests/shader.png");
  sh.set_vec3("iResolution", {1280,720,0});
  sh.set_float("iTime", 0);
  sh.set_float("iTimeDelta", 0);
  sh.set_float("iFrameRate", 60);
  sh.set_int("iFrame", 0);
  sh.set_float("iChannelTime", 0);
  sh.set_vec3("iChannelResolution", {0,0,0});
  sh.set_vec4("iMouse", {0,0,0,0});
  sh.set_texture("iChannel0", texture);
  sh.set_vec4("iDate", {0,0,0,0});
  sh.set_float("iSampleRate", 0);
  bythos::core.quadMat.shader = sh;
  bythos::core.quadMat.maps[material::DIFFUSE].texture = texture;

  float time;

  bythos::@loop() {
    sh.set_float("iTime", time);
    sh.set_float("iTimeDelta", time);
    time++;
  };

  bythos::clean();
  assert(false);
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

