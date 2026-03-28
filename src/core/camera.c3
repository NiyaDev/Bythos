
module bythos;

//* -- Structures -- *//
struct Camera {
  Vec3f target, distance, up;
  float fov, rotation, rotTarget;
}


module bythos::camera;
import std::math;
import bythos;

//* -- Globals -- *//
Camera main @export("camera_main") = {
  {0,0,0},
  {0,5,5},
  {0,1,0},
  70,
  0, 0,
};

//* -- Functions -- *//
fn void Camera.update(&self = &main) @export("camera_update") {
  if ((self.rotation.close(self.rotTarget, 1))) {
    float dir;
    if ((self.rotTarget - self.rotation) > 0) dir = +0.5;
    if ((self.rotTarget - self.rotation) < 0) dir = -0.5;
    self.rotation += dir * (500 * (float)bythos::core.time.deltaTime);
  } else {
    self.rotation = self.rotTarget;

    if (self.rotation < 0) {
      self.rotation += 360;
      self.rotTarget += 360;
    }
    if (self.rotation > 360) {
      self.rotation -= 360;
      self.rotTarget -= 360;
    }
  }
}
fn Matrix4f Camera.get_matrix(&self = &main) @export("camera_getmatrix")
  => matrix::look_at{float}(self.target.rotate(self.distance, self.rotation), self.target, self.up).transpose();
fn void Camera.rotate(&self = &main, float target) @export("camera_rotate")
  => self.rotTarget += target;
fn bool Camera.is_rotating(&self = &main) @export("camera_isrotating")
  => self.rotation != self.rotTarget;
fn Vec3f Camera.position(&self = &main) @export("camera_position") {
  float c = math::cos(self.rotation * (float)(math::PI/180));
  float s = math::sin(self.rotation * (float)(math::PI/180));

  Vec3f p = self.distance - self.target;
  Vec3f rotated = {
     p.x * c + p.z * s,
     p.y,
    -p.x * s + p.z * c,
  };

  return self.target + rotated;
}

