
module bythos;
import sdl3;

//* -- Macros -- *//
macro void @loop(; @body()) {
  while (true) {
    //* -- Deltatime -- *//
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
  }
}

