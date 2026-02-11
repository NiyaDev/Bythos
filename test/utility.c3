
import bythos;


fn void pathobject() @test {
  PathObject po = "resources/inner/filename.png".to_pathobj();
  assert(po.dir  == "resources/inner/", "Failed to parse directory. [%s != \"resources/inner/\"]", po.dir);
  assert(po.name == "filename", "Failed to parse file name. [%s != \"filename\"]", po.name);
  assert(po.type == "png", "Failed to parse file type. [%s != \"png\"]", po.type);
  assert(po.full() == "resources/inner/filename.png", "Failed to parse full path. [%s != \"resources/inner/filename.png\"]", po.full());
}
