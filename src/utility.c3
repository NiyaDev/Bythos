
module bythos;
import std::io;


struct PathObject {
  String dir, name, type;
}
fn PathObject String.to_pathobj(&self) {
  String[] period = self.tsplit(".");
  String[] slash = period[0].tsplit("/");

  return {
    self.trim_right(string::tformat("%s.%s",slash[slash.len-1],period[period.len-1])),
    slash[slash.len-1],
    period[period.len-1],
  };
}
fn String PathObject.full(&self) {
  return string::tformat("%s%s.%s", self.dir, self.name, self.type);
}

