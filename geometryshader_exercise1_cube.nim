import sugar

import staticglfw
import opengl
import nimPNG

import sceneobj

var points = [
  #coord   color         sides
  -0.5'f32, 0.5, 1, 0, 0, 0, # red point
  0.5, 0.5, 0, 1, 0,      0, # green point
  0.5, -0.5, 0, 0, 1,     0, # blue point
  -0.5, -0.5, 1, 0, 0,    0, # red point

  -0.5, 0.5, 0, 1, 0,     1, # green point
  0.5, -0.5, 0, 0, 1,     1, # blue point
]

var myVertex: cstring = """
#version 330 core
in vec2 pos;
in vec3 color;
in float sides;
out vec3 vColor;
out float vSides;

void main() {
  gl_Position = vec4(pos, 0.0, 1.0);
  vColor = color;
  vSides = sides;
}
"""
var myFragment: cstring = """
#version 330 core
in vec3 fColor;
out vec4 outColor;
void main() {
  outColor = vec4(fColor, 1.0);
}
"""
var myGeometry: cstring = """
#version 330 core
layout(points) in;
layout(triangle_strip, max_vertices = 64) out;

in vec3 vColor[];
out vec3 fColor;
in float vSides[];

const float PI = 3.1415926;
void main() {
  fColor = vColor[0];
  vec4 prevPos = gl_in[0].gl_Position;

  /*
  for (int i = 0; i <= vSides[0]; i++) {
    float ang = PI * 2.0 / vSides[0] * i;
    vec4 offset = vec4(cos(ang) * 0.3, -sin(ang) * 0.4, 0.0, 0.0);
    gl_Position = prevPos + offset;
    EmitVertex();
  }
  */

  float x = prevPos.x;
  float y = prevPos.y;
  gl_Position = prevPos;
  EmitVertex();
  if (x < 0.0 && y > 0.0 && vSides[0] == 0.0) {
    gl_Position = prevPos + vec4(1.0, 0.0, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(0.0, -1.0, 0.0, 0.0);
    EmitVertex();
  }
  if (x > 0.0 && y > 0.0 && vSides[0] == 0.0) {
    gl_Position = prevPos + vec4(-1.0, 0.0, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(1.5, 0.5, 0.0, 0.0);
    EmitVertex();
  }
  if (x > 0.0 && y < 0.0 && vSides[0] == 0.0) {
    gl_Position = prevPos + vec4(0.0, 1.0, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(0.5, 0.5, 0.0, 0.0);
    EmitVertex();
  }
  if (x < 0.0 && y < 0.0 && vSides[0] == 0.0) {
    gl_Position = prevPos + vec4(0.0, 1.0, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(1.0, -1.0, 0.0, 0.0);
    EmitVertex();
  }
  if (x < 0.0 && y > 0.0 && vSides[0] == 1.0) {
    gl_Position = prevPos + vec4(0.5, 0.5, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(1.0, 0.0, 0.0, 0.0);
    EmitVertex();
  }
  if (x > 0.0 && y < 0.0 && vSides[0] == 1.0) {
    gl_Position = prevPos + vec4(0.5, 0.5, 0.0, 0.0);
    EmitVertex();
    gl_Position = gl_Position + vec4(0.0, 1.0, 0.0, 0.0);
    EmitVertex();
  }

  EndPrimitive();
}
"""

dump myvertex
dump myFragment
dump myGeometry

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
    myVertex, myFragment, myGeometry)

  scene.activateAttrib(size = 2, row = 6, skip = 0, "pos")
  scene.activateAttrib(size = 3, row = 6, skip = 2, "color")
  scene.activateAttrib(size = 1, row = 6, skip = 5, "sides")

  while windowShouldClose(window) == 0:

    #glClearColor 1, 1, 1, 1
    glClearColor 0, 0, 0, 1
    glClear GL_COLOR_BUFFER_BIT
    glDrawArrays(GL_POINTS, 0, 6)

    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
