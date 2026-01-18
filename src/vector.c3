
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

fn Vec2f Vec2f.lerp(self, Vec2f v2, float amount) @export("vector2_lerp")
  => self + ((v2-self) * amount);
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
  result.r = (char)((self.z - self.z * self.y * k) * 250);

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



alias Vec4f = float[<4>];
alias Vec4i = int[<4>];

fn Color Vec4f.to_color(self) @export("vector4_color")
	=> {(char)(self.x * 255),	(char)(self.y * 255),	(char)(self.z * 255),	(char)(self.w * 255)};

