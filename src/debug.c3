
module bythos::debug;
import std::io;
import std::os;
import std::thread;
import std::time;
import bythos::color;


String recentText;
uint timer = 0;
bool printing = false;
LogLevel logLevel = ALL;

enum LogLevel {
  ALL,
  WARNING,
  ERROR,
  NONE,
}

fn void fatal(String err, args...) @export("debug_fatal") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0)
    { io::printfn("[%s] - %s %s", "FATAL".color({230,41,55,255}), err, args); }
  else
    { io::printfn("[%s] - %s", "FATAL".color({230,41,55,255}), err); }
  printing = false;

  unreachable();
}
fn void error(String err, args...) @export("debug_error") {
  if (logLevel > ERROR) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0)
    { io::printfn("[%s] - %s %s", "ERROR".color(color::RED), err, args); }
  else
    { io::printfn("[%s] - %s", "ERROR".color(color::RED), err); }
  printing = false;

  recentText = o;
  timer = 100;
}
fn void warning(String err, args...) @export("debug_warning") {
  if (logLevel > WARNING) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0)
    { io::printfn("[%s]  - %s %s", "WARN".color(color::ORANGE), err, args); }
  else
    { io::printfn("[%s]  - %s", "WARN".color(color::ORANGE), err); }
  printing = false;

  recentText = o;
  timer = 100;
}
fn void info(String err, args...) @export("debug_info") {
  if (logLevel > ALL) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0)
    { io::printfn("[%s]  - %s %s", "INFO".color(color::GRAY), err, args); }
  else
    { io::printfn("[%s]  - %s", "INFO".color(color::GRAY), err); }
  printing = false;
}

macro void @benchmark(#a) {
  Time start = time::now();
  #a;
  io::printfn("%s",time::now().diff_us(start));
}

fn String String.color(self, Color color) @export("debug_textcolor")
  => string::tformat("\e[38;2;%d;%d;%dm%s\e[0m", color.r, color.g, color.b, self);

