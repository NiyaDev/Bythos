
import bythos;


fn void loading() @test {
  bythos::init();

  //Mesh m = mesh::load("resources/Hati.obj");
  bythos::upload_file("resources/Hati.obj");

  while (!bythos::should_close()) {
    //render::draw_mesh("Hati_Skin", scale:{2,2,2});
    bythos::draw();
  }

  bythos::clean();
  //assert(false);
}
