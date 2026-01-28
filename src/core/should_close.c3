
module bythos;
import sdl3;


fn bool should_close() @export("bythos_shouldclose") {
  // Calculate deltatime
  double currentFrame = ((double)sdl3::get_ticks() / 1000);
  core.time.deltaTime = currentFrame - core.time.lastFrame;
  core.time.lastFrame = currentFrame;

  // Update keybinds

  // Poll events
  while (sdl3::poll_event(&core.window.event)) {
    switch (core.window.event.type) {
      case FIRST: break;

      case QUIT:
      case TERMINATING:
      case WINDOW_CLOSE_REQUESTED:
      case WINDOW_DESTROYED:
        return true;

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
      case KEY_UP:
        break;
      //  keybinds::add_queue(event.key);

      case TEXT_EDITING:
      case TEXT_INPUT:
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
        core.input.mouse.delta = {core.window.event.motion.xrel, core.window.event.motion.yrel};
        core.input.mouse.position = {core.window.event.motion.x, core.window.event.motion.y};
      case MOUSE_BUTTON_DOWN:
        core.input.mouse.currentState[core.window.event.button.button-1] = true;
      case MOUSE_BUTTON_UP:
        core.input.mouse.currentState[core.window.event.button.button-1] = false;
      case MOUSE_WHEEL:
        core.input.mouse.currentWheel = core.window.event.wheel.y;

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

      default: debug::info("Unhandled event.", core.window.event.type);

    }
  }
  // Default exit key

  return false;
}


