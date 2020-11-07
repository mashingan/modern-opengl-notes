import sugar

import staticglfw
import opengl
import nimsl/nimsl

template `as`(a, b: untyped): untyped =
  cast[b](a)

var vertices = [
  0'f32, 0.5, 1, 0, 0,  # vertex 1: Red
  0.5, -0.5, 0, 1, 0,   # vertex 2: Green
  -0.5, -0.5, 0, 0, 1   # vertex 3: Blue
]

proc myVertexShader(acol: Vec3, aPos: Vec2, vColor: var Vec3): Vec4 =
  vColor = acol
  result = newVec4(aPos, 0, 1)

proc myFragmentShader(vColor: Vec3): Vec4 =
  result = newVec4(vColor[0], vColor[1], vColor[2], 1)

var myVertex: cstring = getGLSLVertexShader(myVertexShader)
var myFragment: cstring = getGLSLFragmentShader(myFragmentShader)

dump myvertex
dump myFragment

template checkShaderCompileStatus(shader: GLuint) =
  var status = 0'i32
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr status)
  if GLBoolean(status) != GL_TRUE:
    var buf: cstring = newString(512)
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

  var vbo = 0'u32
  glGenBuffers(1, addr vbo)
  glBindBuffer(GL_ARRAY_BUFFER, vbo)
  glBufferData(GL_ARRAY_BUFFER, sizeof vertices, addr vertices, GL_STATIC_DRAW)
  defer: glDeleteBuffers(1, addr vbo)

  echo "compile vertex shader"
  var vxShades = myVertex.addr as cstringArray
  var vertexShader = glCreateShader(GL_VERTEX_SHADER)
  glShaderSource(vertexShader, 1, vxShades, nil)
  glCompileShader(vertexShader)

  # check if shader compiled succesfully
  checkShaderCompileStatus vertexShader
  echo "vertex shader compiled"
  defer: vertexShader.glDeleteShader

  echo "compile fragment shader"
  var fgShades = myFragment.addr as cstringArray
  var fragmentShader = glCreateShader(GL_FRAGMENT_SHADER)
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

  # since 0 is by default and there's only one output right now
  # the following code is not necessary, note that in actual lesson
  # it's "outColor" instead of "gl_FragColor" because in fragment shader
  # code the output was set to "outColor"
  #
  #glBindFragDataLocation(shaderProgram, 0, "gl_FragColor")

  glLinkProgram shaderProgram
  glUseProgram shaderProgram

  echo "pos attrib"
  # in original tutorial, the "position" has in/attribute in it's declaration,
  # however using nimsl the only working variable is "aPos" as attribute
  # because when changed to "position" it becomes uniform which is not we
  # intended.
  var posAttrib = glGetAttribLocation(shaderProgram, "aPos")
  dump posAttrib
  dump posAttrib.GLuint
  if posAttrib < 0:
    echo "invalid pos attribute"
    return
  posAttrib.GLuint.glEnableVertexAttribArray
  glVertexAttribPointer(posAttrib.GLuint, 2, cGL_FLOAT, GL_FALSE,
    5 * sizeof(float32), nil)
    #0, nil)

  echo "color attrib"
  var colAttrib = glGetAttribLocation(shaderProgram, "acol")
  dump colAttrib
  dump colAttrib.GLuint
  if colAttrib < 0:
    echo "invalid color attribute"
    return
  var colsize = 2 * sizeof(float32)
  colAttrib.GLuint.glEnableVertexAttribArray
  glVertexAttribPointer(colAttrib.GLuint, 3, cGL_FLOAT, GL_FALSE,
    5 * sizeof(float32), colsize as pointer)
    # this is really peculiar as the last argument needed is pointer
    # but it's not actually the address of the value itself instead it's
    # just simply a cast to `(void*)`. Really strange.

  while windowShouldClose(window) == 0:
    glClearColor(0, 0, 0, 1)
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawArrays(GL_TRIANGLES, 0, 3)
    swapBuffers window
    pollEvents()

    if window.getKey(KEY_ESCAPE) == 1 or window.getKey(KEY_Q) == 1:
      window.setWindowShouldClose(1)

main()
