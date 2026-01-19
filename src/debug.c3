
module bythos::debug;
import std::io;
import std::os;
import std::thread;
import bythos::color;


String recentText;
uint timer = 0;
bool printing = false;

fn void fatal(String err, args...) @export("debug_fatal") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  String o = string::tformat("[%s] - %s %s", "FATAL".color({230,41,55,255}), err, args);
  io::printn(o);
  printing = false;

  os::exit(1);
}
fn void error(String err, args...) @export("debug_error") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  String o = string::tformat("[%s] - %s %s", "ERROR".color(color::RED), err, args);
  io::printn(o);
  printing = false;

  recentText = o;
  timer = 100;
}
fn void warning(String err, args...) @export("debug_warning") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  String o = string::tformat("[%s] - %s %s", "WARN".color(color::ORANGE), err, args);
  io::printn(o);
  printing = false;

  recentText = o;
  timer = 100;
}
fn void info(String err, args...) @export("debug_info") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  String o = string::tformat("[%s] - %s %s", "INFO".color(color::GRAY), err, args);
  io::printn(o);
  printing = false;
}

fn String String.color(self, Color color) @export("debug_textcolor")
  => string::tformat("\e[38;2;%d;%d;%dm%s\e[0m", color.r, color.g, color.b, self);

