
module bythos;
import std::io;
import sdl3;

//* -- Macros -- *//
macro void @loop(; @body()) {
  while (true) {
    //* -- Timing -- *//
    double currentFrame = ((double)sdl3::getTicks() / 1000);
  	core.time.deltaTime = currentFrame - core.time.lastFrame;
  	core.time.lastFrame = currentFrame;

  	//* -- Events -- *//
  	Event event;
  	while (sdl3::pollEvent(&event)) {
  	  switch (event.type) {
  	    case QUIT:
  	    case TERMINATING:
  	    case WINDOW_CLOSE_REQUESTED:
  	    case WINDOW_DESTROYED:
  	      return;
  	    default: break;
  	  }
  	}

  	//* -- Body -- *//
  	draw_start();
    @body();
  	draw_end();

  	if (core.time.deltaTime < core.time.targetFrametime) {
      sdl3::delay((uint)(core.time.targetFrametime - core.time.deltaTime));
  	}
  }
}

