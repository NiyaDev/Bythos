
module bythos::vector;
import std::math;
import bythos::color;


alias Vec2f = float[<2>];
alias Vec2i = int[<2>];


fn float Vec2f.angle_rad(self, Vec2f v2) @export("vector2_angle_rad")
  => math::atan2(v2.y-self.y,v2.x-self.x);
fn float Vec2f.angle_deg(self, Vec2f v2) @export("vector2_angle_deg") 
  => math::atan2(v2.y-self.y,v2.x-self.x) * (180 / math::PI);
fn Vec2f Vec2f.rotate_rad(self, float angle) @export("vector2_rotate_rad") {
  float cosres = math::cos(angle);
  float sinres = math::sin(angle);

  return {
    (self.x * cosres) - (self.y * sinres),
    (self.x * sinres) + (self.y * cosres),
  };
}
fn Vec2f Vec2f.rotate_deg(self, float angle) @export("vector2_rotate_deg") {
  float cosres = math::cos(angle / (180 / (float)math::PI));
  float sinres = math::sin(angle / (180 / (float)math::PI));

  return {
    (self.x * cosres) - (self.y * sinres),
    (self.x * sinres) + (self.y * cosres),
  };
}
fn Vec2f Vec2f.move_towards(self, Vec2f target, float max_distance) @export("vector2_move_toward") {
  Vec2f d = target - self;
  float value = d.length().pow(2);

  if (value == 0 || (max_distance >= 0 && value <= max_distance.pow(2))) return target;
  float dist = self.distance(target);

  return self + ((d / dist) * max_distance);
}
fn Vec2f Vec2f.reflect(self, Vec2f normal) @export("vector2_reflect")
  => (self - (2 * (self * normal)) * normal);
fn Vec2f Vec2f.invert(self) @export("vector2_invert")
  => {1/self.x, 1/self.y};

fn Vec2f Vec2f.clamp(self, Vec2f min, Vec2f max) @export("vector2_clamp")
  => {math::clamp(self.x, min.x, max.y), math::clamp(self.y, min.y, max.y)};
fn Vec2f Vec2f.clamp_mag(self, float min, float max) @export("vector2_clamp_mag") {
  float length = self.length();

  if (length > 0) {
    length = math::sqrt(length);
    float scale = 1;
    if (length < min) {
      scale = min / length;
    } else if (length > max) {
      scale = max / length;
    }
    return self * scale;
  }

  return self;
}



alias Vec3f = float[<3>];
alias Vec3i = int[<3>];


fn Color Vec3f.color(self) @export("vector3_color") {
  Color result = {0,0,0,255};

  // Red
  float k = (5 + self.x / 60) % 6;
  float t = 4 - k;
  if (t <  k) { k = t; }
  if (k >= 1) { k = 1; }
  if (k <= 0) { k = 0; }
  result.r = (char)((self.z - self.z * self.y * k) * 255);

  //* Green
	k = (3 + self.x / 60) % 6;
	t = 4 - k;
	if (t <  k) { k = t; }
	if (k >= 1) { k = 1; }
	if (k <= 0) { k = 0; }
	result.g = (char)((self.z - self.z * self.y * k) * 255);

	//* Blue
	k = (1 + self.x / 60) % 6;
	t = 4 - k;
	if (t <  k) { k = t; }
	if (k >= 1) { k = 1; }
	if (k <= 0) { k = 0; }
	result.b = (char)((self.z - self.z * self.y * k) * 255);

	return result;
}
fn float Vec3f.angle_rad(self, Vec3f v2) @export("vector3_angle_rad")
  => math::atan2(self.cross(v2).length(), self.dot(v2));
fn float Vec3f.angle_deg(self, Vec3f v2) @export("vector3_angle_deg")
  => math::atan2(self.cross(v2).length(), self.dot(v2)) * (180 / math::PI);
fn Vec3f Vec3f.project(self, Vec3f v2) @export("vector3_project") {
  float v1dv2 = (self * v2).sum();
  float v2dv2 = v2.length().pow(2);
  float mag = v1dv2 / v2dv2;

  return v2 * mag;
}
fn Vec3f Vec3f.reject(self, Vec3f v2) @export("vector3_reject") {
  float v1dv2 = (self * v2).sum();
  float v2dv2 = v2.length().pow(2);
  float mag = v1dv2 / v2dv2;

  return self - (v2 * mag);
}
fn void Vec3f.orthonormalize(&self, Vec3f* v2) @export("vector3_orthonormalize") {
  *self = self.normalize();
  Vec3f vn1 = self.cross(*v2);

  vn1 = vn1.normalize();
  Vec3f vn2 = vn1.cross(*self);

  *v2 = vn2;
}
fn Vec3f Vec3f.rotate_quaternion(self, Quaternionf q) @export("vector3_rotateq") {
  Quaternionf normed = q.normalize();
  Quaternionf new = {self.x, self.y, self.z, 1};
  Quaternionf normedNeg = {-normed.i, -normed.j, -normed.k, normed.l};

  return (normed * new * normedNeg).v.xyz;
}
fn Vec3f Vec3f.rotate(self, Vec3f dist, float rot) @export("vector3_rotate") {
  float cosres = math::cos(rot / (180 / (float)math::PI));
  float sinres = math::sin(rot / (180 / (float)math::PI));
  return {
    (dist.x * cosres - dist.z * sinres) + self.x,
    self.y + dist.y,
    (dist.x * sinres + dist.z * cosres) + self.z,
  };
}
fn Vec3f Vec3f.move_towards(self, Vec3f target, float max_distance) @export("vector3_move_towards") {
  Vec3f d = target - self;
  float value = d.length().pow(2);

  if (value == 0 || (max_distance >= 0 && value <= max_distance.pow(2))) return {};

  float dist = math::sqrt(value);
  return self + d / dist * max_distance;
}
fn Vec3f Vec3f.min(self, Vec3f min) @export("vector3_min")
  => {math::min(self.x,min.x), math::min(self.y,min.y), math::min(self.z,min.z)};
fn Vec3f Vec3f.max(self, Vec3f max) @export("vector3_max")
  => {math::max(self.x,max.x), math::max(self.y,max.y), math::max(self.z,max.z)};
fn Vec3f Vec3f.invert(self) @export("vector3_invert")
  => 1 / self;
fn bool float.close(self, float f2, float amount) @export("float_close")
  => self + amount > f2 && self - amount < f2;
fn bool Vec3f.close(self, Vec3f v2, float amount) @export("vector_close")
  => self.x.close(v2.x, amount) && self.y.close(v2.y, amount) && self.z.close(v2.z, amount);



alias Vec4f = float[<4>];
alias Vec4i = int[<4>];

fn Color Vec4f.to_color(self) @export("vector4_color")
	=> {(char)(self.x * 255),	(char)(self.y * 255),	(char)(self.z * 255),	(char)(self.w * 255)};
fn Vec4f Vec4f.move_towards(self, Vec4f target, float max_distance) @export("vector4_move_towards") {
  Vec4f d = target - self;
  float value = d.length().pow(2);

  if (value == 0 || (max_distance >= 0 && value <= max_distance.pow(2))) return {};

  float dist = math::sqrt(value);
  return self + d / dist * max_distance;
}
fn Vec4f Vec4f.invert(self) @export("vector4_invert")
  => 1 / self;
fn Vec4f Vec4f.min(self, Vec4f min) @export("vector4_min")
  => {math::min(self.x,min.x), math::min(self.y,min.y), math::min(self.z,min.z), math::min(self.w,min.w)};
fn Vec4f Vec4f.max(self, Vec4f max) @export("vector4_max")
  => {math::max(self.x,max.x), math::max(self.y,max.y), math::max(self.z,max.z), math::max(self.w,max.w)};

