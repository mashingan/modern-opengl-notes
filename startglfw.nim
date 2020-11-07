import staticglfw
import opengl

proc main =
  if init() == 0:
    raise newException(Exception, "Failed to initialize GLFW")
  windowHint CONTEXT_VERSION_MAJOR, 3
  windowHint CONTEXT_VERSION_MINOR, 2
  windowHint OPENGL_PROFILE, OPENGL_CORE_PROFILE
  windowHint RESIZABLE, 0
  var window = createWindow(800, 600, "GLFW Window", nil, nil)
  makeContextCurrent window
  loadExtensions()

  var buffer = 0'u32
  glGenBuffers(1, addr buffer)
  echo buffer

  while windowShouldClose(window) == 0:
    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1:
      window.setWindowShouldClose(1)

  window.destroyWindow
  terminate()

main()
