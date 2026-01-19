
//import bythos;


fn void basic() @test {
  bythos::init();
  defer bythos::clean();

  while (!bythos::should_close()) {
    bythos::draw();
  }
  assert(false, "reached end");
}
