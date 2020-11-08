import sugar, times

import staticglfw
import opengl
import nimPNG
import glm

template `as`(a, b: untyped): untyped =
  cast[b](a)

var vertices = [
  # position,   color,   texcoords
  -0.5'f,  0.5, 1, 0, 0, 0, 0,  # top-left red
     0.5,  0.5, 0, 1, 0, 1, 0,  # top-right green
     0.5, -0.5, 0, 0, 1, 1, 1,  # bottom-right green
    -0.5, -0.5, 1, 1, 1, 0, 1   # bottom-left white
]

var elements = [
  0'u32, 1, 2,
  2, 3, 0
]

var myVertex: cstring = """
#version 330 core
attribute vec2 aPos;
attribute vec2 aTexcoord;
attribute vec3 acol;

varying vec2 vPos;
varying vec2 vTexcoord;
varying vec3 vColor;

uniform mat4 model;
uniform mat4 view;
uniform mat4 proj;

void main() {
  vColor = acol;
  vTexcoord = aTexcoord;
  gl_Position = proj * view * model * vec4(aPos, 0.0, 1.0);
}
"""
var myFragment: cstring = """
#version 330 core
in vec2 vTexcoord;
uniform sampler2D texKitten;
uniform sampler2D texPuppy;
uniform float blend;
void main() {
  vec4 colKitten = texture2D(texKitten, vTexcoord);
  vec4 colPuppy = texture2D(texPuppy, vTexcoord);
  gl_FragColor = mix(colKitten, colPuppy, blend);
}
"""

dump myvertex
dump myFragment

template checkShaderCompileStatus(shader: GLuint) =
  var errnum = glGetError()
  echo "catched error: ", errnum.int
  var status = 0'i32
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr status)
  if GLBoolean(status) != GL_TRUE:
    var buf: cstring = newString(512)
    var length = 0'i32
    glGetShaderInfoLog(vertexShader, 512, addr length, buf)
    echo "failed shader compilation"
    if length > 0:
      echo buf
    return

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

  # setup vertex array object (VAO) for fast vertices switching
  # everytime calling glVertexAttribPointer.
  # This must be set first before we call glVertexAttribPointer if not
  # we will get GL_INVALID_OPERATION.
  var vao = 0'u32
  glGenVertexArrays(1, addr vao)
  vao.glBindVertexArray
  defer: glDeleteVertexArrays(1, addr vao)

  # vertex array buffer
  var vbo = 0'u32
  glGenBuffers(1, addr vbo)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof vertices, addr vertices, GL_STATIC_DRAW)
  defer: glDeleteBuffers(1, addr vbo)

  # element buffer
  var ebo = 0'u32
  glGenBuffers(1, addr ebo)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof elements, addr elements,
    GL_STATIC_DRAW)
  defer: glDeleteBuffers(1, addr ebo)

  echo "compile vertex shader"
  var vxShades = myVertex.addr as cstringArray
  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  if vertexShader.glIsShader == GL_FALSE:
    echo "cannot create vertex shader"
    return
  glShaderSource(vertexShader, 1, vxShades, nil)
  glCompileShader(vertexShader)

  # check if shader compiled succesfully
  checkShaderCompileStatus vertexShader
  echo "vertex shader compiled"
  defer: vertexShader.glDeleteShader

  echo "compile fragment shader"
  var fgShades = myFragment.addr as cstringArray
  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
  if fragmentShader.glIsShader == GL_FALSE:
    echo "cannot create fragment shader"
    return
  glShaderSource(fragmentShader, 1, fgShades, nil)
  glCompileShader(fragmentShader)

  # check if shader compiled succesfully
  checkShaderCompileStatus fragmentShader
  echo "fragment shader compiled"
  defer: fragmentShader.glDeleteShader

  var shaderProgram = glCreateProgram()
  shaderProgram.glAttachShader vertexShader
  shaderProgram.glAttachShader fragmentShader
  defer: shaderProgram.glDeleteProgram

  glLinkProgram shaderProgram
  glUseProgram shaderProgram

  echo "pos attrib"
  var posAttrib = glGetAttribLocation(shaderProgram, "aPos")
  dump posAttrib
  dump posAttrib.GLuint
  if posAttrib < 0:
    echo "invalid pos attribute"
    return
  posAttrib.GLuint.glEnableVertexAttribArray
  glVertexAttribPointer(posAttrib.GLuint, 2, cGL_FLOAT, GL_FALSE,
    7 * sizeof(float32), nil)
  
  echo "tex attrib"
  var texAttrib = glGetAttribLocation(shaderProgram, "aTexcoord")
  dump texAttrib
  dump texAttrib.GLuint
  if texAttrib < 0:
    echo "invalid texture attribute"
    return
  var skipsize = 5 * sizeof(float32)
  texAttrib.GLuint.glEnableVertexAttribArray
  glVertexAttribPointer(texAttrib.GLuint, 2, cGL_FLOAT, GL_FALSE,
    7 * sizeof(float32), skipsize as pointer)

  # texture buffer
  var texs = [0'u32, 0]
  glGenTextures(2, addr texs[0])
  defer: glDeleteTextures(2, addr texs[0])

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, texs[0])
  var sample = loadPNG24("sample.png")
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, GLsizei sample.width,
    GLsizei sample.height, 0, GL_RGB, GL_UNSIGNED_BYTE, sample.data.cstring)
  glUniform1i(glGetUniformLocation(shaderProgram, "texKitten"), 0)
  glGenerateMipmap(GL_TEXTURE_2D)
  #var texcols = [1'f32, 0, 0, 1] # red color border
  #glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, addr texcols[0])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)

  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, texs[1])
  sample = loadPNG24("sample2.png")
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, GLsizei sample.width,
    GLsizei sample.height, 0, GL_RGB, GL_UNSIGNED_BYTE, sample.data.cstring)
  glUniform1i(glGetUniformLocation(shaderProgram, "texPuppy"), 1)
  glGenerateMipmap(GL_TEXTURE_2D)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)

  var unimodel = glGetUniformLocation(shaderProgram, "model")
  var model = mat4f(1).rotate(radians(180'f32), vec3f(0, 0, 1))
  unimodel.glUniformMatrix4fv(1, GL_FALSE, addr model[0][0])

  # The lookAt function has several argument which
  # 1st: the camera position
  # 2nd: what to look which actually the center of world
  # 3rd: what axis is up, in our notes below we use z-axis as 1 which up
  var view = lookAt(vec3f(1.2, 1.2, 1.2), vec3f(0, 0, 0), vec3f(0, 0, 1))
  var uniview = glGetUniformLocation(shaderProgram, "view")
  uniview.glUniformMatrix4fv(1, GL_FALSE, addr view[0][0])

  # The perspective is projection of how we look at the world
  # that has several arguments with meaning
  # 1st: vertical field-of-view is the angle of how much we see
  #      between top and bottom of 2D surface screen. The smaller
  #      the angle means we reduce surface we can see which has
  #      the same effect of camera zooming.
  # 2nd: aspect ratio of the screen
  # 3rd and 4th: near and far planes
  var proj = perspective(45.float32.radians, 800'f32 / 600, 1, 10)
  var uniproj = glGetUniformLocation(shaderProgram, "proj")
  uniproj.glUniformMatrix4fv(1, GL_FALSE, addr proj[0][0])

  var uniblend = glGetUniformLocation(shaderProgram, "blend")

  let start = cpuTime()
  var originalModel = model # keep the original model scale
  while windowShouldClose(window) == 0:
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    let diff = cpuTime() - start
    originalModel = originalModel.rotate(diff * 180.0.radians / 1000, vec3f(0, 0, 1))
    model = originalModel
    let sindiff = (sin(4 * diff) + 1) / 2
    #let scaler = sin(diff * 5) + 0.25 + 0.75
    model = model.scale(sindiff)
    uniblend.glUniform1f(sindiff)
    unimodel.glUniformMatrix4fv(1, GL_FALSE, addr model[0][0])
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
