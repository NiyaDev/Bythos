
module bythos;
import std::io;
import sdl3;

// Functions
macro void @loop(; @body()) {
  while (true) {
  	//* -- DeltaTime -- *//
  	double currentFrame = ((double)sdl3::getTicks() / 1000);
  	core.time.deltaTime = currentFrame - core.time.lastFrame;
  	core.time.lastFrame = currentFrame;
  	//if (core.time.deltaTime < 0.001) continue;
    //io::printfn("%f", core.time.deltaTime);

  	//* -- Keys -- *//
  	for (int i; i < core.input.keyboard.currentKeyState.len; i++) {
  	  core.input.keyboard.previousKeyState[i] = core.input.keyboard.currentKeyState[i];
  	}
  	core.input.keyboard.keyPressedQueue = {};
  	core.input.keyboard.charPressedQueue = {};

  	core.input.mouse.previousWheel = core.input.mouse.currentWheel;
  	core.input.mouse.currentWheel = 0;

  	core.input.mouse.previousPosition = core.input.mouse.currentPosition;

  	//* -- Events -- *//
  	Event event;
  	while (sdl3::pollEvent(&event)) {
  	  switch (event.type) {
  	    case QUIT:
  	    case TERMINATING:
  	    case WINDOW_CLOSE_REQUESTED:
  	    case WINDOW_DESTROYED:
  	      return;

  	    case LOW_MEMORY:
  	    case WILL_ENTER_BACKGROUND:
  	    case DID_ENTER_BACKGROUND:
  	    case WILL_ENTER_FOREGROUND:
  	    case DID_ENTER_FOREGROUND:
  	      break;

  	    case LOCALE_CHANGED:
  	    case SYSTEM_THEME_CHANGED:
  	      break;

  	    // Display
  	    case DISPLAY_ORIENTATION:
  	    case DISPLAY_ADDED:
  	    case DISPLAY_REMOVED:
  	    case DISPLAY_MOVED:
  	    case DISPLAY_DESKTOP_MODE_CHANGED:
  	    case DISPLAY_CURRENT_MODE_CHANGED:
  	    case DISPLAY_CONTENT_SCALE_CHANGED:
  	    case DISPLAY_USABLE_BOUNDS_CHANGED:
  	      break;

  	    // Window
  	    case WINDOW_SHOWN:
  	    case WINDOW_HIDDEN:
  	    case WINDOW_EXPOSED:
  	      break;

  	    case WINDOW_MOVED:
  	    case WINDOW_RESIZED:
  	    case WINDOW_PIXEL_SIZE_CHANGED:
  	    case WINDOW_METAL_VIEW_RESIZED:
  	    case WINDOW_MINIMIZED:
  	    case WINDOW_MAXIMIZED:
  	    case WINDOW_RESTORED:
  	    case WINDOW_MOUSE_ENTER:
  	    case WINDOW_MOUSE_LEAVE:
  	    case WINDOW_FOCUS_GAINED:
  	    case WINDOW_FOCUS_LOST:
  	    case WINDOW_HIT_TEST:
  	    case WINDOW_ICCPROF_CHANGED:
  	    case WINDOW_DISPLAY_CHANGED:
  	    case WINDOW_DISPLAY_SCALE_CHANGED:
  	    case WINDOW_SAFE_AREA_CHANGED:
  	    case WINDOW_OCCLUDED:
  	    case WINDOW_ENTER_FULLSCREEN:
  	    case WINDOW_LEAVE_FULLSCREEN:
  	    case WINDOW_HDR_STATE_CHANGED:
  	      break;

  	    // Keyboard
  	    case KEY_DOWN:
  	      Scancode key = event.key.scancode;
  	      if (key != UNKNOWN) {
  	        // Check if key was up before
  	        if (core.input.keyboard.currentKeyState[(int)key] == false)
  	          { core.input.keyboard.currentKeyState[(int)key] = true; }
  	        if (core.input.keyboard.currentKeyState[(int)key] == core.input.keyboard.previousKeyState[(int)key])
  	          { core.input.keyboard.repeatKeyState[(int)key] = true; }

  	        if (core.input.keyboard.currentKeyState[core.input.keyboard.exitKey] == true)
  	          { return; }
  	      }
  	    case KEY_UP:
  	      Scancode key = event.key.scancode;
  	      if (key != UNKNOWN) {
  	        core.input.keyboard.currentKeyState[(int)key] = false;
  	        core.input.keyboard.repeatKeyState[(int)key] = false;
  	      }
  	    //  keybinds::add_queue(event.key);

  	    case TEXT_EDITING:
  	    case TEXT_INPUT:
  	      io::printfn("%s",event.edit.text);
  	      break;
	
  	    case KEYMAP_CHANGED:
  	    case KEYBOARD_ADDED:
  	    case KEYBOARD_REMOVED:
  	    case TEXT_EDITING_CANDIDATES:
  	    case SCREEN_KEYBOARD_SHOWN:
  	    case SCREEN_KEYBOARD_HIDDEN:
  	      break;

  	    // Mouse
  	    case MOUSE_MOTION:
  	      if (!core.input.mouse.isLocked) {
  	        core.input.mouse.currentPosition = {event.motion.x, event.motion.y};
  	      }
  	    case MOUSE_BUTTON_DOWN:
  	      core.input.mouse.currentState[event.button.button-1] = true;
  	    case MOUSE_BUTTON_UP:
  	      core.input.mouse.currentState[event.button.button-1] = false;
  	    case MOUSE_WHEEL:
  	      core.input.mouse.currentWheel = event.wheel.y;

  	    case MOUSE_ADDED:
  	    case MOUSE_REMOVED:
  	      break;

  	    // Joystick
  	    case JOYSTICK_AXIS_MOTION:
  	    case JOYSTICK_BALL_MOTION:
  	    case JOYSTICK_HAT_MOTION:
  	    case JOYSTICK_BUTTON_DOWN:
  	    case JOYSTICK_BUTTON_UP:
  	    case JOYSTICK_ADDED:
  	    case JOYSTICK_REMOVED:
  	    case JOYSTICK_BATTERY_UPDATED:
  	    case JOYSTICK_UPDATE_COMPLETE:
  	      break;

  	    // Gamepad
  	    case GAMEPAD_AXIS_MOTION:
  	    case GAMEPAD_BUTTON_DOWN:
  	    case GAMEPAD_BUTTON_UP:
  	    case GAMEPAD_ADDED: 
  	    case GAMEPAD_REMOVED:
  	    case GAMEPAD_REMAPPED:
  	    case GAMEPAD_TOUCHPAD_DOWN:
  	    case GAMEPAD_TOUCHPAD_MOTION:
  	    case GAMEPAD_TOUCHPAD_UP:
  	    case GAMEPAD_SENSOR_UPDATE:
  	    case GAMEPAD_UPDATE_COMPLETE:
  	    case GAMEPAD_STEAM_HANDLE_UPDATED:
  	      break;

  	    // Touch
  	    case FINGER_DOWN:
  	    case FINGER_UP:
  	    case FINGER_MOTION:
  	    case FINGER_CANCELED:
  	    case PINCH_BEGIN:
  	    case PINCH_UPDATE:
  	    case PINCH_END:
  	      break;
	
  	    // Clipboard
  	    case CLIPBOARD_UPDATE:
  	      break;

  	    // File drop
  	    case DROP_FILE:
  	    case DROP_TEXT:
  	    case DROP_BEGIN:
  	    case DROP_COMPLETE:
  	    case DROP_POSITION:
  	      break;

  	    // Audio device events
  	    case AUDIO_DEVICE_ADDED:
  	    case AUDIO_DEVICE_REMOVED:
  	    case AUDIO_DEVICE_FORMAT_CHANGED:
  	      break;

  	    case SENSOR_UPDATE:
  	      break;

  	    // Pen
  	    case PEN_PROXIMITY_IN:
  	    case PEN_PROXIMITY_OUT:
  	    case PEN_DOWN:
  	    case PEN_UP:
  	    case PEN_BUTTON_DOWN:
  	    case PEN_BUTTON_UP:
  	    case PEN_MOTION:
  	    case PEN_AXIS:
  	      break;

  	    // Camera hotplug
  	    case CAMERA_DEVICE_ADDED:
  	    case CAMERA_DEVICE_REMOVED:
  	    case CAMERA_DEVICE_APPROVED:
  	    case CAMERA_DEVICE_DENIED:
  	      break;

  	    // Render
  	    case RENDER_TARGETS_RESET:
  	    case RENDER_DEVICE_RESET:
  	    case RENDER_DEVICE_LOST:
  	      break;

  	    default: debug::info("Unhandled event.", event.type);
  	  }
  	}
  	for (int i; i < core.input.keyboard.currentKeyState.len; i++) {
  	  if (core.input.keyboard.currentKeyState[i] == true
  	    && core.input.keyboard.previousKeyState[i] == true)
  	      { core.input.keyboard.repeatKeyState[i] = true; }
  	}
  	core.input.mouse.delta = core.input.mouse.previousPosition - core.input.mouse.currentPosition;

    draw_start();

  	@body();

  	draw_end();
  }
}

