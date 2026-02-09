
import bythos;


fn void loading() @test {
  bythos::init();

  //Mesh m = mesh::load("resources/Hati.obj");
  bythos::upload_file("resources/Hati.obj");

  while (!bythos::should_close()) {
    render::draw_mesh("Hati_Skin.mo_Hati_Skin.md");
    bythos::draw();
  }

  bythos::clean();
  //assert(false);
}
