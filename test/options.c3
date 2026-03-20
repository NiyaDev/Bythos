
import bythos;
import std::collections;


fn void loading() @test {
  OptionsList opts = options::load_all("resources/options.toml");
  assert(opts["fullscreen"]!!.b == true, "Fullscreen missing");
  assert(opts["screen_width"]!!.i == 1280, "Width missing");
  assert(opts["screen_height"]!!.i == 720, "Height missing");
  assert(opts["render_resolution"]!!.f == 1.0, "Render resolution missing");
  opts.clean();
}
