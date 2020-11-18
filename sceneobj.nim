import strformat, sugar
import opengl
import nimPNG

template `as`(a, b: untyped): untyped =
  cast[b](a)

template checkShaderCompileStatus*(shader: GLuint) =
  var errnum = glGetError()
  echo "catched error: ", errnum.int
  var status = 0'i32
  glGetShaderiv(shader, GL_COMPILE_STATUS, addr status)
  if GLBoolean(status) != GL_TRUE:
    var buf: cstring = newString(512)
    var length = 0'i32
    glGetShaderInfoLog(shader, 512, addr length, buf)
    echo "failed shader compilation"
    if length > 0:
      echo buf
    return

type
  Scene* = object
    vao*: uint32
    vbo*: uint32
    vshader*: uint32
    fshader*: uint32
    gshader*: uint32
    program*: uint32

template ok*(test, body: untyped) =
  if `test` >= 0:
    `body`

proc `=destroy`*(scene: var Scene) =
  scene.vao.ok: glDeleteVertexArrays 1, addr scene.vao
  scene.vbo.ok: glDeleteBuffers 1, addr scene.vbo
  scene.vshader.ok: glDeleteShader scene.vshader
  scene.vshader.ok: glDeleteShader scene.fshader
  scene.gshader.ok: glDeleteShader scene.gshader
  scene.program.ok: glDeleteProgram scene.program

proc compileShader*(vertexShader: var cstring, mode = GL_VERTEX_SHADER): uint32 =
  var vxShades = vertexShader.addr as cstringArray
  result = glCreateShader mode
  var msgwhich = if mode == GL_FRAGMENT_SHADER: "fragment"
                 else: "vertex"
  if result.glIsShader == GL_FALSE:
    echo fmt"cannot create {msgwhich} shader"
    return
  glShaderSource(result, 1, vxShades, nil)
  glCompileShader result

  # check if shader compiled succesfully
  checkShaderCompileStatus result.GLuint
  echo fmt"{msgwhich} shader compiled"

proc initScene*(verticeSize: int, verticeAddr: pointer, outColor = "",
  vertexShader, fragmentShader, geometryShader: var cstring): Scene =
  glGenVertexArrays(1, addr result.vao)
  glBindVertexArray result.vao

  glGenBuffers(1, addr result.vbo)
  glBindBuffer(GL_ARRAY_BUFFER, result.vbo)
  glBufferData(GL_ARRAY_BUFFER, verticeSize, verticeAddr,
    GL_STATIC_DRAW)

  result.program = glCreateProgram()
  if vertexShader != "":
    result.vshader = compileShader vertexShader
    result.program.glAttachShader result.vshader
  if fragmentShader != "":
    result.fshader = compileShader(fragmentShader, GL_FRAGMENT_SHADER)
    result.program.glAttachShader result.fshader
  if geometryShader != "":
    result.gshader = compileShader(geometryShader, GL_GEOMETRY_SHADER)
    result.program.glAttachShader result.gshader

  if outColor != "":
    result.program.glBindFragDataLocation(0, "outColor")

  glLinkProgram result.program
  glUseProgram result.program

proc useVao*(scene: Scene) =
  glBindVertexArray scene.vao

proc useVbo*(scene: Scene) =
  glBindBuffer GL_ARRAY_BUFFER, scene.vbo

proc useProgram*(scene: Scene) =
  glUseProgram scene.program

proc loadTexture*(scene: Scene, filename, uniformVar: string, texture: uint32,
  which: GLenum) =
  glActiveTexture which
  var texwhich = 0'i32
  if which == GL_TEXTURE0:
    texwhich = 0'i32
  elif which == GL_TEXTURE1:
    texwhich = 1'i32
  glBindTexture GL_TEXTURE_2D, texture
  var sample = loadPNG24 filename
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, GLsizei sample.width,
    GLsizei sample.height, 0, GL_RGB, GL_UNSIGNED_BYTE, sample.data.cstring)
  glUniform1i(glGetUniformLocation(scene.program, uniformVar), texwhich)
  glGenerateMipmap(GL_TEXTURE_2D)
  #var texcols = [1'f32, 0, 0, 1] # red color border
  #glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, addr texcols[0])
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)

template activateAttrib*(scene: Scene, size, row, skip: int32,
  attrib: string) =
  let rowsize: GLint = row * sizeof(float32)
  echo attrib, " attrib"
  var varAttrib = glGetAttribLocation(scene.program, attrib)
  dump varAttrib
  dump varAttrib.GLuint
  if varAttrib < 0:
    echo "invalid ", attrib, " attribute"
    return
  varAttrib.GLuint.glEnableVertexAttribArray
  var skipcount: pointer = nil
  if skip > 0:
    skipcount = (skip * sizeof(float32)) as pointer
  glVertexAttribPointer(varAttrib.GLuint, size, cGL_FLOAT, GL_FALSE,
    rowsize, skipcount)

proc useFramebuffer*(fb: uint32) =
  glBindFramebuffer GL_FRAMEBUFFER, fb

proc drawBufferTexture*(texture, stencil: uint32) =
  glBindTexture GL_TEXTURE_2D, texture
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.GLint, 800, 600, 0, GL_RGB,
    GL_UNSIGNED_BYTE, nil)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)

  glBindRenderbuffer GL_RENDERBUFFER, stencil
  glRenderbufferStorage GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, 800, 600
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT,
    GL_RENDERBUFFER, stencil)
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
    GL_TEXTURE_2D, texture, 0)