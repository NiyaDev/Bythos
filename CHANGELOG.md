
### v0.1.0
#### [1/17/26]
- Finished Vector2 and colors

#### [1/18/26]
- Finished Vector3, Vector4, Debug, and most of the work on Textures.

#### [1/19/25]
- Finished basic SDL3 and OpenGL integration.

#### [1/21/25]
- Added all bindings for Textures, Rectangles, and core functions.
- Made framework for Materials, Shaders, and Meshes.
- Re-wrote default texture generation to be simpler.

#### [1/22/26]
- Finished most mesh functions.

#### [1/23/26]
- Finished most shader functions and started working on set_uniform, but had trouble with implementation.
- Finished Camera.

#### [1/24/26]
- Still trying to fix nothing rendering but it's all broken and i don't know why.

#### [1/25/26]
- Finally got it working and it was stupid. Forgot the Perspective matrix and then to transpose it.

#### [1/26/26]
- Got rendering working normally and then re-implemented the framebuffer.

#### [1/27/26]
- Tested changing Bythos so that its a structure that's used, but it got nowhere and is reverted.

#### [1/28/26]
- Added log level to only display logs of an equal severity or higher. Set to ALL by default.
- Re-wrote Bythos structure to compartmentalize more data and re-wrote and organized bythos functions.
- Started fixing PPM loading.

#### [1/29/26]
- Fixed bindings for Bythos, Color, Debug, Rectangle, Texture, and Vector.
- Added bindings for Mesh with temp material binding.
- Started on Re-implementing Keyboard input and keybinds.
- Re-added mouse position and proper delta calculation.

#### [1/30/26]
- Set up keybinds system and bindings.

#### [1/31/26]
- Clean up texture and add info messages.
- Fix memory leak in general test.
- Improved mesh cleaning.
- Removed old Bythos main file.

#### [2/1/26]
- Added screenshot in both .png and .ppm formats.

#### [2/2/26]
- Added clean function to materials.

#### [2/3/26]
- Added draw_instanced back to mesh.
- Finished first version of 3d render pipeline.
- Merged draw_start and draw_end.
- Started on draw function for textures, but wasn't able to get it to work yet.

#### [2/4/26]
- Fixed Texture rendering.
  - Turned out it was an error with the color value not getting to the shader, making it transparent.
- Started on 2d render pipeline.
  - Finished the function, but it doesn't seemt to work?

#### [2/5/26]
- Fixed Texture drawing. It was just the priority thing that was messed up.
  - Also the shader was never turned on, but that's not important.
- Re-wrote texture drawing to be slightly more efficient. Drawing meshes still is more efficient overall, though.

#### [2/6/26]
- Added unit tests for Textures.
- Re-did cleanup for Bythos. Now it actually cleans everything up and allows for tests to work.
- Changed Texture, Mesh, and Keybind Hashmaps to pointers due to stange problem causing the data to corrupt?
- Added to TODO list.

#### [2/7/26]
- Started on Material functions.
  - Loading is started, but not functional.
  - Unit tests are prepared.
- Re-wrote Material and Mesh structures to be closer to raylib.
  - Changed all references to old structure in bythos.

#### [2/8/26]
- Basic material loader finished?
  - Needs testing.

#### [2/9/26]
- Finished basic material loading.
  - Tests
- Fixed basic Mesh loading.
  - Tests
  - New problem: Crashes on sdl3::gl_swap_window() for some reason after calling render::draw_mesh().

