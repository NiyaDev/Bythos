
module bythos::render;
import std::io;
import std::collections;
import std::math;
import std::time;
import bythos;



List{TextureRenderInfo} renderPipeline2D;
List{MeshRenderInfo} renderPipeline3D;

struct TextureRenderInfo {
  String textureName;
  Rectangle dst, src;
  Vec3f rotation;
  Color tint;
  int priority;
}
struct MeshRenderInfo {
  String meshName;
  Vec3f position, scale, rotation;
  Shader shaderOverride;
}

fn void draw_mesh(
  String meshName = "default",
  Vec3f position = {},
  Vec3f scale = {1,1,1},
  Vec3f rotation = {},
  Shader shaderOverride = {},
) @export("render_mesh")
  { renderPipeline3D.push({meshName, position, scale, rotation, shaderOverride}); }

fn void draw_texture(
  String textureName = "default",
  Rectangle src = {},
  Rectangle dst = {},
  Vec3f rotation = {},
  Color tint = color::WHITE,
  int priority = 0,
) @export("render_texture")
  { renderPipeline2D.push({textureName, dst, src, rotation, tint, priority}); }

fn void draw_texture_tiled() @export("render_texturetiled") {}
fn void draw_font() @export("render_font") {}

fn void render3d() {
  // 3D
  List{String} entries;
  for (int i; i < renderPipeline3D.len(); i++) {
    String name = renderPipeline3D[i].meshName;
    if (!entries.contains(name)) entries.push(name);
  }

  for (int i; i < entries.len(); i++) {
    usz count;
    for (int j; j < renderPipeline3D.len(); j++)
      { if (entries[i] == renderPipeline3D[i].meshName) count++; }
    Matrix4f[] arr = mem::new_array(Matrix4f, count);
    usz index;
    for (int j; j < renderPipeline3D.len(); j++) {
      if (entries[i] == renderPipeline3D[j].meshName) {
        arr[index] = MATRIX4F_IDENTITY
          .translate(renderPipeline3D[j].position)
          .rotate_z(renderPipeline3D[j].rotation.z)
          .rotate_y(renderPipeline3D[j].rotation.y)
          .rotate_x(renderPipeline3D[j].rotation.x)
          .scale(renderPipeline3D[j].scale)
          .transpose();
        index++;
      }
    }
    bythos::core.storage.meshes[entries[i]]!!.draw_instanced(arr);
    free(arr);
  }
  entries.free();
  renderPipeline3D.clear();
}
fn void render2d() {}

