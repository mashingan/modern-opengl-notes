import sugar

import staticglfw
import opengl
import nimPNG

import sceneobj

var points = [
  -0.5'f32, 0.5,
  0.5, 0.5,
  0.5, -0.5,
  -0.5, -0.5,
]

var myVertex: cstring = """
#version 330 core
attribute vec2 pos;
void main() {
  gl_Position = vec4(pos, 0.0, 1.0);
}
"""
var myFragment: cstring = """
#version 330 core
out vec4 outColor;
void main() {
  outColor = vec4(1.0, 0.0, 0.0, 1.0);
}
"""

dump myvertex
dump myFragment

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

  defer:
    window.destroyWindow
    terminate()

  dump sizeof(points)
  dump (addr points).repr
  var scene = initScene(sizeof points, addr points, "outColor",
    myVertex, myFragment)

  scene.activateAttrib(size = 2, row = 0, skip = 0, "pos")

  while windowShouldClose(window) == 0:

    #glClearColor 1, 1, 1, 1
    glClearColor 0, 0, 0, 1
    glClear GL_COLOR_BUFFER_BIT
    glDrawArrays(GL_POINTS, 0, 4)

    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
