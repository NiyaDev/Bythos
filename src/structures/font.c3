
module bythos;
import std::collections;

//* -- Structures -- *//
struct Font {
  Texture atlas;
  Vec2f dimensions;
  Rectangle[font::PRINTABLE_COUNT] rects;
}


module bythos::font;
import bythos;

//* -- Constants -- *//
const usz PRINTABLE_START =  32;
const usz PRINTABLE_END   = 127;
const usz PRINTABLE_COUNT = PRINTABLE_END - PRINTABLE_START;
const usz NUMERALS_START  =  48;
const usz UPPERCASE_START =  65;
const usz LOWERCASE_START =  97;

//* -- Globals -- *//
char[] def = $embed("../../resources/font.png");

//* -- Functions -- *//
fn Font load_from_texture(String filename, Vec2f dimensions) @export("font_loadtexture") {
  return {
    texture::load(filename),
    dimensions,
    create_rectarray(dimensions.x, dimensions.y),
  };
}
fn Font load_from_texturememory(char[] data, Vec2f dimensions) @export("font_loadtexture") {
  return {
    texture::load_from_memory(data, "png"),
    dimensions,
    create_rectarray(dimensions.x, dimensions.y),
  };
}
fn void Font.clean(&self) @export("font_clean") {
  self.atlas.clean();
}

fn void Font.draw(&self = &&bythos::get_default_font(), String text, Vec2f position = {}, Vec2f scale = {1,1}, Vec2f spacing = {}) @export("font_draw") {
  usz printableChars = text.count_printable();
  Rectangle[] dst = mem::new_array(Rectangle, printableChars);
  Rectangle[] src = mem::new_array(Rectangle, printableChars);
  Color[]     col = mem::new_array(Color, printableChars);

  for (int i; i < printableChars; i++) {
    dst[i] = {
      (i*self.dimensions.x) + position.x,
      0 + position.y,
      self.dimensions.x * scale.x,
      self.dimensions.y * scale.y,
    };
    src[i] == self.rects[text[i]-PRINTABLE_START];
    col[i] = color::WHITE;
  }

  self.atlas.draw(dst:{0,0,200,100});
  //self.atlas.draw_instanced(dst, src, col);
}

fn usz String.count_printable(&self) {
  usz count;
  for (int i; i < self.len; i++) {
    if ((*self)[i] >= PRINTABLE_START && (*self)[i] >= PRINTABLE_END)
      { count++; }
  }
  return count;
}
fn Rectangle[PRINTABLE_COUNT] create_rectarray(float x, float y) {
  Rectangle[PRINTABLE_END] output;

  output[' ']  = {x * 25, y * 3, x, y};
  output['!']  = {x *  0, y * 2, x, y};
  output['\"'] = {x * 25, y * 2, x, y};
  output['#']  = {x *  2, y * 2, x, y};
  output['$']  = {x *  3, y * 2, x, y};
  output['%']  = {x *  4, y * 2, x, y};
  output['&']  = {x *  6, y * 2, x, y};
  output['\''] = {x * 24, y * 2, x, y};
  output['(']  = {x *  8, y * 2, x, y};
  output[')']  = {x *  9, y * 2, x, y};
  output['*']  = {x *  7, y * 2, x, y};
  output['+']  = {x * 13, y * 2, x, y};
  output[',']  = {x *  0, y * 3, x, y};
  output['-']  = {x * 10, y * 2, x, y};
  output['.']  = {x *  1, y * 3, x, y};
  output['/']  = {x *  4, y * 3, x, y};

  output['0']  = {x *  6, y * 3, x, y};
  output['1']  = {x *  7, y * 3, x, y};
  output['2']  = {x *  8, y * 3, x, y};
  output['3']  = {x *  9, y * 3, x, y};
  output['4']  = {x * 10, y * 3, x, y};
  output['5']  = {x * 11, y * 3, x, y};
  output['6']  = {x * 12, y * 3, x, y};
  output['7']  = {x * 13, y * 3, x, y};
  output['8']  = {x * 14, y * 3, x, y};
  output['9']  = {x * 15, y * 3, x, y};

  output[':']  = {x * 23, y * 2, x, y};
  output[';']  = {x * 22, y * 2, x, y};
  output['<']  = {x *  2, y * 3, x, y};
  output['=']  = {x * 12, y * 2, x, y};
  output['>']  = {x *  3, y * 3, x, y};
  output['?']  = {x *  5, y * 3, x, y};
  output['@']  = {x *  1, y * 2, x, y};

  output['A']  = {x *  0, y, x, y};
  output['B']  = {x *  1, y, x, y};
  output['C']  = {x *  2, y, x, y};
  output['D']  = {x *  3, y, x, y};
  output['E']  = {x *  4, y, x, y};
  output['F']  = {x *  5, y, x, y};
  output['G']  = {x *  6, y, x, y};
  output['H']  = {x *  7, y, x, y};
  output['I']  = {x *  8, y, x, y};
  output['J']  = {x *  9, y, x, y};
  output['K']  = {x * 10, y, x, y};
  output['L']  = {x * 11, y, x, y};
  output['M']  = {x * 12, y, x, y};
  output['N']  = {x * 13, y, x, y};
  output['O']  = {x * 14, y, x, y};
  output['P']  = {x * 15, y, x, y};
  output['Q']  = {x * 16, y, x, y};
  output['R']  = {x * 17, y, x, y};
  output['S']  = {x * 18, y, x, y};
  output['T']  = {x * 19, y, x, y};
  output['U']  = {x * 20, y, x, y};
  output['V']  = {x * 21, y, x, y};
  output['W']  = {x * 22, y, x, y};
  output['X']  = {x * 23, y, x, y};
  output['Y']  = {x * 24, y, x, y};
  output['Z']  = {x * 25, y, x, y};

  output['[']  = {x * 14, y * 2, x, y};
  output['\\'] = {x * 18, y * 2, x, y};
  output[']']  = {x * 15, y * 2, x, y};
  output['^']  = {x *  5, y * 2, x, y};
  output['_']  = {x * 11, y * 2, x, y};
  output['`']  = {x * 20, y * 2, x, y};

  output['a']  = {x *  0, 0, x, y};
  output['b']  = {x *  1, 0, x, y};
  output['c']  = {x *  2, 0, x, y};
  output['d']  = {x *  3, 0, x, y};
  output['e']  = {x *  4, 0, x, y};
  output['f']  = {x *  5, 0, x, y};
  output['g']  = {x *  6, 0, x, y};
  output['h']  = {x *  7, 0, x, y};
  output['i']  = {x *  8, 0, x, y};
  output['j']  = {x *  9, 0, x, y};
  output['k']  = {x * 10, 0, x, y};
  output['l']  = {x * 11, 0, x, y};
  output['m']  = {x * 12, 0, x, y};
  output['n']  = {x * 13, 0, x, y};
  output['o']  = {x * 14, 0, x, y};
  output['p']  = {x * 15, 0, x, y};
  output['q']  = {x * 16, 0, x, y};
  output['r']  = {x * 17, 0, x, y};
  output['s']  = {x * 18, 0, x, y};
  output['t']  = {x * 19, 0, x, y};
  output['u']  = {x * 20, 0, x, y};
  output['v']  = {x * 21, 0, x, y};
  output['w']  = {x * 22, 0, x, y};
  output['x']  = {x * 23, 0, x, y};
  output['y']  = {x * 24, 0, x, y};
  output['z']  = {x * 25, 0, x, y};

  output['{']  = {x * 16, y * 2, x, y};
  output['|']  = {x * 19, y * 2, x, y};
  output['}']  = {x * 17, y * 2, x, y};
  output['~']  = {x * 21, y * 2, x, y};

  return output[PRINTABLE_START..];
}

