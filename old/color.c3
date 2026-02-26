
module bythos::color;
import std::math;
import bythos::vector;


alias Color = char[<4>];
const Color LIGHTGRAY		= {200, 200, 200, 255};
const Color GRAY		  	= {130, 130, 130, 255};
const Color DARKGRAY		= { 80,  80,  80, 255};
const Color YELLOW			= {253, 249,   0, 255};
const Color GOLD		  	= {255, 203,   0, 255};
const Color ORANGE	 		= {255, 161,   0, 255};
const Color PINK 				= {255, 109, 194, 255};
const Color RED 				= {230,  41,  55, 255};
const Color MAROON 			= {190,  33,  55, 255};
const Color GREEN 			= {  0, 228,  48, 255};
const Color LIME				= {  0, 158,  47, 255};
const Color DARKGREEN		= {  0, 117,  44, 255};
const Color SKYBLUE			= {102, 191, 255, 255};
const Color BLUE				= {  0, 121, 241, 255};
const Color DARKBLUE		= {  0,  82, 172, 255};
const Color PURPLE			= {200, 122, 255, 255};
const Color VIOLET			= {135,  60, 190, 255};
const Color DARKPURPLE	= {112,  31, 126, 255};
const Color BEIGE				= {211, 176, 131, 255};
const Color BROWN				= {127, 106,  79, 255};
const Color DARKBROWN		= { 76,  63,  47, 255};
const Color WHITE				= {255, 255, 255, 255};
const Color BLACK				= {  0,   0,   0, 255};
const Color BLANK				= {  0,   0,   0,   0};
const Color MAGENTA			= {255,   0, 255, 255};
const Color PALETTE_30	= { 48,  56,  67, 255};


fn Color Color.multiply(self, float f) @export("color_multiply")
  => (Color){(char)(self.r*f), (char)(self.g*f), (char)(self.b*f), (char)self.a};

fn uint Color.to_int(self) @export("color_toint")
  => self.r << 24 | self.g << 16 | self.b << 8 | self.a;
fn Color uint.to_color(self) @export("color_fromint")
  => (Color){(char)(self >> 24), (char)(self >> 16), (char)(self >> 8), (char)self};
fn Vec3f Color.to_hsv(self) @export("color_tohsv") {
  float r = (float)self.r / 255;
	float g = (float)self.g / 255;
	float b = (float)self.b / 255;
	float cmax = math::max(r, math::max(g, b));
	float cmin = math::min(r, math::min(g, b));
	float delta = cmax - cmin;

	float hue;
	if (delta == 0.0) { hue = 0; }
	else if (cmax == r) { hue = (60 * (((g - b) / delta) + 360)) % 360; }
	else if (cmax == g) { hue = (60 * (((b - r) / delta) + 120)) % 360; }
	else if (cmax == b) { hue = (60 * (((r - g) / delta) + 240)) % 360; }
	else { hue = -1; };

	float sat = (cmax == 0 ? 0 : delta / cmax);

	return {hue,sat,cmax};
}
fn Vec4f Color.normalize(self) @export("color_normalize")
	=> (Vec4f){(float)self.r / 255,	(float)self.g / 255,	(float)self.b / 255,	(float)self.a / 255};

fn Color Color.fade(self, float alpha) @export("color_fade")
  => (Color){self.r,self.g,self.b,(char)(255*alpha)};
fn Color Color.tint(self, Color tint) @export("color_tint")
  => ((self.normalize() / 255 * tint.normalize()) * 255).to_color();
fn Color Color.brightness(self, float factor) @export("color_brightness") {
  Vec4f new = self.normalize();

  if (factor < 0) {
    //factor = 1 + factor;
    new *= 1 + factor;
    new.w = (float)self.a / 255;
  } else {
    new = {
			(255 - new.x) * factor + new.x,
			(255 - new.y) * factor + new.y,
			(255 - new.z) * factor + new.z,
			(float)self.a / 255,
		};
  }
  return new.to_color();
}
fn Color Color.contrast(self, float contrast) @export("color_contrast") {
  Color result = self;

	contrast += 1;
	contrast *= contrast;

	Vec4f norm = self.normalize();
	norm.x = (float)((((norm.x - 0.5) * contrast) + 0.5) * 255).clamp(0,255);
	norm.y = (float)((((norm.y - 0.5) * contrast) + 0.5) * 255).clamp(0,255);
	norm.z = (float)((((norm.z - 0.5) * contrast) + 0.5) * 255).clamp(0,255);

	return {(char)norm.x,(char)norm.y,(char)norm.z,self.a};
}
fn Color Color.alpha(self, float alpha) @export("color_alpha")
	=> {self.r, self.g, self.b, (char)(255 * alpha)};

