
module bythos::debug;
import bythos::color;


extern fn void fatal(String err, args...) @extern("debug_fatal");
extern fn void error(String err, args...) @extern("debug_error");
extern fn void warning(String err, args...) @extern("debug_warning");
extern fn void info(String err, args...) @extern("debug_info");

extern fn String String.color(self, Color color) @extern("debug_textcolor");

