
module bythos::camera;
import std::math;
import bythos;


struct Camera {
  Vec3f target, distance, up;
  float fov, rotation, rotTarget;
}

Camera main @export("camera_main") = {
  {0,0,0},
  {0,5,5},
  {0,1,0},
  70,
  0, 0,
};

fn void update(Camera* cam = &main) @export("camera_update") {
  if ((cam.rotation.close(cam.rotTarget, 5))) {
    float dir;
    if ((cam.rotTarget - cam.rotation) > 0) dir = +1;
    if ((cam.rotTarget - cam.rotation) < 0) dir = -1;
    cam.rotation += dir * (500 * (float)bythos::core.time.deltaTime);
  } else {
    cam.rotation = cam.rotTarget;

    if (cam.rotation < 0) {
      cam.rotation += 360;
      cam.rotTarget += 360;
    }
    if (cam.rotation > 360) {
      cam.rotation -= 360;
      cam.rotTarget -= 360;
    }
  }
}

fn Matrix4f get_matrix(Camera* cam = &main) @export("camera_getmatrix")
  => matrix::look_at{float}(cam.target.rotate(cam.distance, cam.rotation), cam.target, cam.up).transpose();
fn void rotate(float target, Camera* cam = &main) @export("camera_rotate")
  => cam.target += target;
fn bool is_rotating(Camera* cam = &main) @export("camera_isrotating")
  => cam.rotation != cam.rotTarget;

