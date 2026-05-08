
import bythos;
import std::math;

fn void creation() @test {
  bythos::init();

  Mesh m = mesh::new(TRI);
  assert(m.vertices.len == 3, "Number of vertices in Triangle mesh are incorrect");
  assert(m.vertices[0] == (Vertex){{ 0.0, 0.5,0.0}, {0,0,1}, {1,1}, {0,0,0,1}}, "Triangle mesh vertex #0 incorrect");
  assert(m.vertices[1] == (Vertex){{-0.5,-0.5,0.0}, {0,0,1}, {1,0}, {0,0,0,1}}, "Triangle mesh vertex #1 incorrect");
  assert(m.vertices[2] == (Vertex){{ 0.5,-0.5,0.0}, {0,0,1}, {0,1}, {0,0,0,1}}, "Triangle mesh vertex #2 incorrect");

  Matrix4f matrix = matrix::IDENTITY4.translate({0,0,0}).rotate_z(0).rotate_y(0).rotate_x(0).scale({1,1,1}).transpose();
  Matrix4f base = matrix::IDENTITY4;
  assert(matrix == base, "Matrix not modified properly");

  bythos::@loop() {
    m.draw();
  };

  m.clean();

  bythos::clean();
}

/*
fn void loading() @test {
  bythos::init();

  //Mesh m = mesh::load("resources/Puffmin.obj");
  bythos::upload_file("resources/Puffmin.obj");

  while (!bythos::should_close()) {
    render::draw_mesh("Mesh_0", scale:{0.1,0.1,0.1});
    render::draw_mesh("Mesh_1", scale:{0.1,0.1,0.1});
    render::draw_mesh("Mesh_2", scale:{0.1,0.1,0.1});
    render::draw_mesh("Mesh_3", scale:{0.1,0.1,0.1});
    bythos::draw();
  }

  bythos::clean();
  assert(false);
}
*/
