
module bythos::debug;
import std::io, std::os, std::thread, std::time;
import bythos;

//* -- Globals -- *//
String recentText;
uint timer = 0;
bool printing = false;
LogLevel logLevel = ALL;

//* -- Enumerations -- *//
enum LogLevel {
  ALL,
  WARNING,
  ERROR,
  NONE,
}

//* -- Functions -- *//
fn void fatal(String err, args...) @export("debug_fatal") {
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0) { io::printfn("[%s] - %s %s", "FATAL".color(color::RED), err, args); }
  else              { io::printfn("[%s] - %s",    "FATAL".color(color::RED), err); }
  printing = false;

  unreachable();
}
fn void error(String err, args...) @export("debug_error") {
  if (logLevel > ERROR) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0) { io::printfn("[%s] - %s %s", "ERROR".color(color::RED), err, args); }
  else              { io::printfn("[%s] - %s",    "ERROR".color(color::RED), err); }
  printing = false;

  //recentText = err;
  timer = 100;
}
fn void warning(String err, args...) @export("debug_warning") {
  if (logLevel > WARNING) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0) { io::printfn("[%s]  - %s %s", "WARN".color(color::ORANGE), err, args); }
  else              { io::printfn("[%s]  - %s",    "WARN".color(color::ORANGE), err); }
  printing = false;

  //recentText = err;
  timer = 100;
}
fn void info(String err, args...) @export("debug_info") {
  if (logLevel > ALL) return;
  while (printing) thread::sleep_ms(1);

  printing = true;
  if (args.len > 0) { io::printfn("[%s]  - %s %s", "INFO".color(color::GRAY), err, args); }
  else              { io::printfn("[%s]  - %s",    "INFO".color(color::GRAY), err); }
  printing = false;
}

fn String String.color(self, bythos::Color color) @export("debug_textcolor")
  => string::tformat("\e[38;2;%d;%d;%dm%s\e[0m", color.r, color.g, color.b, self);
fn void set_log_level(LogLevel level) @export("debug_setloglevel")
  => logLevel = level;

//* -- Macros -- *//
macro void @benchmark(#b; @body()) {
  time::Time start = time::now();
  @body();
  io::printfn("[%s]  - %s: %s - %sus", "INFO".color(color::GRAY), "BENCHMARK".color(color::DARKGREEN), #b, time::now().diff_us(start));
}

