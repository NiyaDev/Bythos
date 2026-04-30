
import bythos;
import std::io, std::math;
import sdl3;
import opengl::gl;

//* -- Tests -- *//
fn void rotation() @test {
  Camera cam = camera::main;

  assert(cam.target == {0,0,0},   "Failed to set main camera targte");
  assert(cam.distance == {0,5,5}, "Failed to set camera view distance");
  assert(cam.up == {0,1,0},       "Failed to set camera up");
  assert(cam.fov == 70,           "Failed to set camera fov");
  assert(cam.rotation == 0 && cam.rotTarget == 0, "Failed to set camera rotation to default");

  cam.rotate(10);
  assert(cam.rotation == 0 && cam.rotTarget == 10, "Rotate failed to set target to rotate towards");
  bythos::core.time.deltaTime = 0.0167;
  cam.update();
  assert(cam.rotation == 0.41749998927116394 && cam.rotTarget == 10, "Failed to update rotation [%.20f,%f]", cam.rotation,cam.rotTarget);
  for (int i; i < 100; i++) cam.update();
  assert(cam.rotation == 10 && cam.rotTarget == 10, "Failed to set rotation");
}

