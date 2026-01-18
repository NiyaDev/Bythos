
module bythos::debug;


fn void fatal(String err, args...) @export("debug_fatal");
fn void error(String err, args...) @export("debug_error");
fn void warning(String err, args...) @export("debug_warning");
fn void info(String err, args...) @export("debug_info");

fn String String.color(self, Color color) @export("debug_textcolor");

