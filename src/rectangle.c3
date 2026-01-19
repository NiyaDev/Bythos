
module bythos::rectangle;
import bythos::vector;


union Rectangle {
  struct { float x, y, w, h; }
  float[<4>] f;
}


fn bool Rectangle.equals(self, Rectangle rhs) @operator(==) @export("rect_equals")
  => (self.x == rhs.x && self.y == rhs.y && self.w == rhs.w && self.h == rhs.h);

fn Rectangle Rectangle.add(self, Rectangle rhs) @operator(+) @export("rect_add")
  => {self.x + rhs.x, self.y + rhs.y, self.w + rhs.w, self.h + rhs.h};
fn Rectangle Rectangle.add_v2(self, Vec2f rhs) @operator_s(+) @export("rect_addv2")
  => {self.x + rhs.x, self.y + rhs.y, self.w, self.h};
fn Rectangle Rectangle.add_v4(self, Vec4f rhs) @operator_s(+) @export("rect_addv4")
  => {self.x + rhs.x, self.y + rhs.y, self.w + rhs.w, self.h + rhs.w};

fn Rectangle Rectangle.sub(self, Rectangle rhs) @operator(-) @export("rect_sub")
  => {self.x - rhs.x, self.y - rhs.y, self.w - rhs.w, self.h - rhs.h};
fn Rectangle Rectangle.sub_v2(self, Vec2f rhs) @operator_s(-) @export("rect_subv2")
  => {self.x - rhs.x, self.y - rhs.y, self.w, self.h};
fn Rectangle Rectangle.sub_v4(self, Vec4f rhs) @operator_s(-) @export("rect_subv4")
  => {self.x - rhs.x, self.y - rhs.y, self.w - rhs.w, self.h - rhs.w};

fn Rectangle Rectangle.mul(self, Rectangle rhs) @operator(*) @export("rect_mul")
  => {self.x * rhs.x, self.y * rhs.y, self.w * rhs.w, self.h * rhs.h};
fn Rectangle Rectangle.mul_v2(self, Vec2f rhs) @operator_s(*) @export("rect_mulv2")
  => {self.x * rhs.x, self.y * rhs.y, self.w, self.h};
fn Rectangle Rectangle.mul_v4(self, Vec4f rhs) @operator_s(*) @export("rect_mulv4")
  => {self.x * rhs.x, self.y * rhs.y, self.w * rhs.w, self.h * rhs.w};

fn Rectangle Rectangle.div(self, Rectangle rhs) @operator(/) @export("rect_div")
  => {self.x / rhs.x, self.y / rhs.y, self.w / rhs.w, self.h / rhs.h};
fn Rectangle Rectangle.div_v2(self, Vec2f rhs) @operator_s(/) @export("rect_divv2")
  => {self.x / rhs.x, self.y / rhs.y, self.w, self.h};
fn Rectangle Rectangle.div_v4(self, Vec4f rhs) @operator_s(/) @export("rect_divv4")
  => {self.x / rhs.x, self.y / rhs.y, self.w / rhs.w, self.h / rhs.w};

fn Vec2f Rectangle.v2(self) @export("rect_v2")
  => self.f.xy;
fn Vec4f Rectangle.v4(self) @export("rect_v4")
  => self.f.xyzw;

fn bool Rectangle.within(&self, Vec2f rhs) @export("rect_within")
  => ((rhs.x >= self.x && rhs.x < = self.x + self.w) && (rhs.y >= self.y && rhs.y < = self.y + self.h));

