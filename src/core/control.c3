
module bythos;

fn void set_exitkey(int key) @export("control_exitkey") {
  core.input.keyboard.exitKey = key;
}
