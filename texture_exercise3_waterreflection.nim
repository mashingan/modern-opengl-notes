import sugar, times

import staticglfw
import opengl
import nimsl/nimsl
import nimPNG
import sceneobj

template `as`(a, b: untyped): untyped =
  cast[b](a)

var vertices = [
  # position,   color,   texcoords
  -1'f,  1, 1, 0, 0, 0, 0,  # top-left red
     1,  1, 0, 1, 0, 1, 0,  # top-right green
     1,  0, 0, 0, 1, 1, 1,  # center-right green
    -1,  0, 1, 1, 1, 0, 1,  # center-left white
  -1'f, -1, 1, 0, 0, 0, 0,  # bottom-left red
     1, -1, 0, 1, 0, 1, 0,  # bottom-right green
]

var elements = [
  0'u32, 1, 2,
  2, 3, 0,
  2, 3, 4,
  4, 5, 2,
]

proc myVertexShader(aTexcoord: Vec2, aPos: Vec2, vTexcoord: var Vec2,
  vPos: var Vec2): Vec4 =
  vPos = aPos
  vTexcoord = aTexcoord
  result = newVec4(aPos, 0, 1)

proc myFragmentShader(tex: Vec2, vColor: Vec3, vTexcoord: Vec2): Vec4 =
  result = newVec4(tex, vTexcoord) * newVec4(vColor[0], vColor[1], vColor[2], 1)

var myVertex = cstring getGLSLVertexShader(myVertexShader)
#var myFragment: cstring = getGLSLFragmentShader(myFragmentShader)
var myFragment = cstring """
#version 330 core
in vec2 vTexcoord;
in vec2 vPos;
uniform sampler2D texKitten;
uniform float freq;
void main() {
  if (vPos.y < 0) {
    float distortion = sin(vTexcoord.y * freq) * 0.03;
    vec2 newv2 = vec2(vTexcoord.x + distortion, vTexcoord.y);
    gl_FragColor = texture2D(texKitten, newv2);
  } else {
    gl_FragColor = texture2D(texKitten, vTexcoord);
  }
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
  var tex = 0'u32
  glGenTextures(1, addr tex)
  defer: glDeleteTextures(1, addr tex)

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, tex)
  var sample = loadPNG24("sample.png")
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, GLsizei sample.width,
    GLsizei sample.height, 0, GL_RGB, GL_UNSIGNED_BYTE, sample.data.cstring)
  glUniform1i(glGetUniformLocation(shaderProgram, "texKitten"), 0)
  glGenerateMipmap(GL_TEXTURE_2D)
  #var texcols = [1'f32, 0, 0, 1] # red color border
  #glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, addr texcols[0])
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)

  var unifreq = glGetUniformLocation(shaderProgram, "freq")
  let start = cpuTime()
  while windowShouldClose(window) == 0:
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    let diff = cpuTime() - start
    unifreq.glUniform1f(diff)
    glDrawElements(GL_TRIANGLES, 12, GL_UNSIGNED_INT, nil)
    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
