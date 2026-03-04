
module utility;

fn String get_extension(String str) {
  String[] split = str.tsplit(".");
  return split[split.len-1];
}

