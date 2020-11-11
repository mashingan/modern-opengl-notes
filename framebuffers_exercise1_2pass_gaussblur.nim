import sugar, times

import staticglfw
import opengl
import nimPNG
import glm

import sceneobj

var vertices = [
 -0.5'f32, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
     0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
     0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
     0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
    -0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 0.0,

    -0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
     0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
    -0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
    -0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,

    -0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
    -0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
    -0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
    -0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
    -0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
    -0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,

     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
     0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
     0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
     0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
     0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,

    -0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
     0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
     0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
     0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
    -0.5, -0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
    -0.5, -0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,

    -0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,
     0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 1.0, 1.0,
     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
     0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 1.0, 0.0,
    -0.5,  0.5,  0.5, 1.0, 1.0, 1.0, 0.0, 0.0,
    -0.5,  0.5, -0.5, 1.0, 1.0, 1.0, 0.0, 1.0,

    -1.0, -1.0, -0.5, 0.0, 0.0, 0.0, 0.0, 0.0,
     1.0, -1.0, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0,
     1.0,  1.0, -0.5, 0.0, 0.0, 0.0, 1.0, 1.0,
     1.0,  1.0, -0.5, 0.0, 0.0, 0.0, 1.0, 1.0,
    -1.0,  1.0, -0.5, 0.0, 0.0, 0.0, 0.0, 1.0,
    -1.0, -1.0, -0.5, 0.0, 0.0, 0.0, 0.0, 0.0
]
var quadVertices = [
    -1.0'f32,  1.0,  0.0, 1.0,
     1.0,  1.0,  1.0, 1.0,
     1.0, -1.0,  1.0, 0.0,

     1.0, -1.0,  1.0, 0.0,
    -1.0, -1.0,  0.0, 0.0,
    -1.0,  1.0,  0.0, 1.0,
]

var elements = [
  0'u32, 1, 2,
  2, 3, 0
]

var myVertex: cstring = """
#version 330 core
attribute vec3 aPos;
attribute vec2 aTexcoord;
attribute vec3 acol;

varying vec3 vPos;
varying vec2 vTexcoord;
varying vec3 vColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

uniform vec3 overrideColor;

void main() {
  vColor = overrideColor * acol;
  vTexcoord = aTexcoord;
  gl_Position = proj * view * model * vec4(aPos, 1.0);
}
"""
var myFragment: cstring = """
#version 330 core
in vec2 vTexcoord;
in vec3 vPos;
in vec3 vColor;
uniform sampler2D texKitten;
uniform sampler2D texPuppy;
uniform float blend;
out vec4 outColor;
void main() {
  vec4 colKitten = texture2D(texKitten, vTexcoord);
  vec4 colPuppy = texture2D(texPuppy, vTexcoord);
  vec4 texColor = mix(colKitten, colPuppy, blend);
  //gl_FragColor = mix(colKitten, colPuppy, blend);
  outColor = vec4(vColor, 1.0) * texColor;
}
"""

var shader2Dvertex: cstring = """
#version 330 core
in vec2 position;
in vec2 texcoord;
out vec2 vTexcoord;
void main() {
  vTexcoord = texcoord;
  gl_Position = vec4(position, 0.0, 1.0);
}
"""

# source ref:
# https://github.com/genekogan/Processing-Shader-Examples/blob/master/TextureShaders/data/blur.glsl 
var shader2Dfragment: cstring = """
#version 330 core
in vec2 vTexcoord;
out vec4 outColor;
uniform sampler2D texFramebuffer;

const float PI = 3.14159265;
const float blurSizeH = 1.0 / 300.0;
const float blurSizeV = 1.0 / 200.0;
const float sigma = 1.9;
const vec2 texOffset = vec2(blurSizeH/2.0, blurSizeV/2.0);

void gaussfunc(inout float x);
void main() {
  vec2 p = vTexcoord.st;
  vec3 incGauss;
  incGauss.x = 1.0 / (sqrt(2.0 * PI) * sigma);
  incGauss.y = exp(-0.5 / (sigma * sigma));
  incGauss.z = incGauss.y * incGauss.y;

  vec4 argval = vec4(0.0);
  float coeffsum = 0.0;
  argval += texture2D(texFramebuffer, p) * incGauss.x;
  coeffsum += incGauss.x;
  incGauss.xy += incGauss.yz;

  for (float i = -4; i <= 4; i++) {
    argval += texture2D(texFramebuffer, p - i * texOffset) * incGauss.x;
    argval += texture2D(texFramebuffer, p + i * texOffset) * incGauss.x;
    coeffsum += 2.0 * incGauss.x;
    incGauss.xy += incGauss.yz;
  }
  outColor = argval / coeffsum;

/* below version is fail not efficient
  vec4 sum = vec4(0.0);
  for (float x = -4; x <= 4; x++) {
    for (float y = -4; y <= 4; x++) {
      float xx = x;
      float yy = y;
      gaussfunc(xx);
      gaussfunc(yy);
      sum += texture2D(
        texFramebuffer,
        vec2(vTexcoord.x + xx, vTexcoord.y + yy)
       ) / 81.0;
    }
  }
  outColor = sum;
  */
}

void gaussfunc(inout float x) {
  x = 1.0 / (2 * PI * sigma * sigma) * exp(-(x * x) / (2 * sigma * sigma));
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

  glEnable GL_DEPTH_TEST

  defer:
    window.destroyWindow
    terminate()

  var screen = initScene(sizeof quadVertices, addr quadVertices, "outColor",
    shader2Dvertex, shader2Dfragment)
  var scene = initScene(sizeof vertices, addr vertices, "outColor",
    myVertex, myFragment)

  # element buffer
  var ebo = 0'u32
  glGenBuffers(1, addr ebo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof elements, addr elements,
    GL_STATIC_DRAW)
  defer: glDeleteBuffers(1, addr ebo)

  scene.useProgram
  scene.useVao
  scene.useVbo
  scene.activateAttrib(size = 3, row = 8, skip = 0, "aPos")
  scene.activateAttrib(size = 3, row = 8, skip = 3, "acol")
  scene.activateAttrib(size = 2, row = 8, skip = 6, "aTexcoord")

  # texture buffer
  var texs = [0'u32, 0]
  glGenTextures(2, addr texs[0])
  defer: glDeleteTextures(2, addr texs[0])

  scene.loadTexture("sample.png", "texKitten", texs[0], GL_TEXTURE0)
  scene.loadTexture("sample2.png", "texPuppy", texs[1], GL_TEXTURE1)

  var unimodel = glGetUniformLocation(scene.program, "model")
  var model = mat4f(1).rotate(radians(180'f32), vec3f(0, 0, 1))
  unimodel.glUniformMatrix4fv(1, GL_FALSE, addr model[0][0])

  var view = lookAt(vec3f(2.5, 2.5, 2.0), vec3f(0, 0, 0), vec3f(0, 0, 1))
  var uniview = glGetUniformLocation(scene.program, "view")
  uniview.glUniformMatrix4fv(1, GL_FALSE, addr view[0][0])

  var proj = perspective(45.float32.radians, 800'f32 / 600, 1, 10)
  var uniproj = glGetUniformLocation(scene.program, "proj")
  uniproj.glUniformMatrix4fv(1, GL_FALSE, addr proj[0][0])

  var uniblend = glGetUniformLocation(scene.program, "blend")
  var unicolor = glGetUniformLocation(scene.program, "overrideColor")

  screen.useVao
  screen.useVbo
  screen.useProgram
  screen.activateAttrib(size = 2, row = 4, skip = 0, "position")
  screen.activateAttrib(size = 2, row = 4, skip = 2, "texcoord")
  glUniform1i(glGetUniformLocation(screen.program, "texFramebuffer"), 0)

  # we initialize the frameBuffer to be used,
  # but we still can't use this frameBuffer yet
  var frameBuffer = 0'u32
  glGenFramebuffers 1, addr frameBuffer
  defer: glDeleteFramebuffers(1, addr frameBuffer)

  # Bind our frameBuffer
  useFramebuffer frameBuffer

  var texColorBuffer = 0'u32
  glGenTextures 1, addr texColorBuffer
  defer: glDeleteTextures(1, addr texColorBuffer)

  var rboDepthStencil = 0'u32
  glGenRenderbuffers(1, addr rboDepthStencil)
  defer: glDeleteRenderbuffers(1, addr rboDepthStencil)

  texColorBuffer.drawBufferTexture rboDepthStencil

  var reflection = model
  let start = cpuTime()
  while windowShouldClose(window) == 0:
    # Bind our framebuffer and draw 3D scene spinning cube
    useFramebuffer frameBuffer
    scene.useVao
    glEnable GL_DEPTH_TEST
    scene.useProgram

    glActiveTexture GL_TEXTURE0
    glBindTexture GL_TEXTURE_2D, texs[0]
    glActiveTexture GL_TEXTURE1
    glBindTexture GL_TEXTURE_2D, texs[1]

    glClearColor 1, 1, 1, 1
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    let diff = cpuTime() - start
    let newval = sin diff

    uniblend.glUniform1f((sin(4 * diff) + 1) / 2)
    model = model.rotate(newval / 50 * 180.0.radians, vec3f(0, 0, 1))
    unimodel.glUniformMatrix4fv(1, GL_FALSE, addr model[0][0])
    glDrawArrays(GL_TRIANGLES, 0, 36)

    glEnable GL_STENCIL_TEST

    # draw floor
    glStencilFunc GL_ALWAYS, 1, 0xff          # set any stencil to 1
    glStencilOp GL_KEEP, GL_KEEP, GL_REPLACE
    glStencilMask 0xff                        # write to stencil buffer
    #glColorMask GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE
    glDepthMask GL_FALSE                      # don't write to depth buffer
    glClear GL_STENCIL_BUFFER_BIT             # clear stencil buffer, 0 by def

    glDrawArrays(GL_TRIANGLES, 36, 6) # draw the floor

    # draw the cube reflection
    glStencilFunc GL_EQUAL, 1, 0xff # pass test if stencil value is 1
    glStencilMask 0x00              # don't write anything to stencil buffer
    glDepthMask GL_TRUE             # write to depth buffer

    reflection = model.translate(vec3f(0, 0, -1)).scale(vec3f(1, 1, -1))
    unimodel.glUniformMatrix4fv(1, GL_FALSE, addr reflection[0][0])
    unicolor.glUniform3f(0.3, 0.3, 0.3) # set the darker color shade
    glDrawArrays(GL_TRIANGLES, 0, 36)
    unicolor.glUniform3f(1, 1, 1)       # set it to identity color vector

    glDisable GL_STENCIL_TEST

    # Bind default framebuffer and draw contents of our framebuffer
    glBindFramebuffer GL_FRAMEBUFFER, 0
    screen.useVao
    glDisable GL_DEPTH_TEST
    screen.useProgram

    glActiveTexture GL_TEXTURE0
    glBindTexture GL_TEXTURE_2D, texColorBuffer
    glDrawArrays GL_TRIANGLES, 0, 6 # 1st pass
    #glDrawArrays GL_TRIANGLES, 0, 6 # 2nd pass

    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
