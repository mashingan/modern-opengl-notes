import sugar

import staticglfw
import opengl
import nimsl/nimsl

template `as`(a, b: untyped): untyped =
  cast[b](a)

var vertices = [
  0'f32, 0.5, # vertex 1
  0.5, -0.5,  # vertex 2
  -0.5, -0.5  # vertex 3
]

proc myVertexShader(proj: Mat4, aPos: Vec2, vPos: var Vec2): Vec4 =
  vPos = aPos
  result = newVec4(aPos, 0, 1)

proc myFragmentShader(vPos: Vec2): Vec4 =
  result = newVec4(1, 1, 1, 1)

var myVertex: cstring = getGLSLVertexShader(myVertexShader)
var myFragment: cstring = getGLSLFragmentShader(myFragmentShader)

dump myvertex
dump myFragment

template checkShaderCompileStatus(shader: GLuint) =
  var status = 0'i32
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr status)
  if GLBoolean(status) != GL_TRUE:
    var buf: cstring = ""
    var length = 0'i32
    glGetShaderInfoLog(vertexShader, 512, addr length, buf)
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

  var vbo = 0'u32
  glGenBuffers(1, addr vbo)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof vertices, addr vertices, GL_STATIC_DRAW)

  var vxShades = myVertex.addr as cstringArray
  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(vertexShader, 1, vxShades, nil)
  glCompileShader(vertexShader)

  # check if shader compiled succesfully
  checkShaderCompileStatus vertexShader

  var fgShades = myFragment.addr as cstringArray
  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
  glShaderSource(fragmentShader, 1, fgShades, nil)
  glCompileShader(fragmentShader)

  # check if shader compiled succesfully
  checkShaderCompileStatus fragmentShader

  var shaderProgram = glCreateProgram()
  shaderProgram.glAttachShader vertexShader
  shaderProgram.glAttachShader fragmentShader

  # since 0 is by default and there's only one output right now
  # the following code is not necessary, note that in actual lesson
  # it's "outColor" instead of "gl_FragColor" because in fragment shader
  # code the output was set to "outColor"
  #
  #glBindFragDataLocation(shaderProgram, 0, "gl_FragColor")

  glLinkProgram shaderProgram
  glUseProgram shaderProgram

  # setup vertex array object (VAO) for fast vertices switching
  # everytime calling glVertexAttribPointer.
  # This must be set first before we call glVertexAttribPointer if not
  # we will get GL_INVALID_OPERATION.
  var vao = 0'u32
  glGenVertexArrays(1, addr vao)
  vao.glBindVertexArray

  # in original tutorial, the "position" has in/attribute in it's declaration,
  # however using nimsl the only working variable is "aPos" as attribute
  # because when changed to "position" it becomes uniform which is not we
  # intended.
  var posAttrib = glGetAttribLocation(shaderProgram, "aPos")
  dump posAttrib
  dump posAttrib.GLuint
  glVertexAttribPointer(posAttrib.GLuint, 2, cGL_FLOAT, GL_FALSE, 0, nil)
  posAttrib.GLuint.glEnableVertexAttribArray

  while windowShouldClose(window) == 0:
    glClearColor(0, 0, 0, 0)
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1:
      window.setWindowShouldClose(1)

  window.destroyWindow
  terminate()

main()
