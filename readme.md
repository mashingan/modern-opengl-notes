# Adapting Modern OpenGL Guide in Nim

This is the notes of lesson from [open.gl][open.gl] adapted using Nim.

## Preparation

In this notes, I use excellent Nim package [staticglfw][staticglfw] for
[GLFW][glfw] setup and package [nimsl][nimsl] for shader DSL instead of
textual representation.

Install the deps with

```
nimble install staticglfw
nimble install nimsl
nimble install opengl
```

## Lesson Notes

1. `startglfw.nim`
This is the initial tutorial which can be found in staticglfw's readme with
additional bits from the [lesson source][open.gl]. This note lesson file is
simply do:

* Initialize [GLFW][glfw] with `init()`.
* Set window drawing context with various hints, lastly we give hint for the window as not resizable.
* Create the actual window context.
* Generate buffers for later.
* Loop our drawing context.
  * Swap the window context with different buffers.
  * Poll any events to our window.
  * Check if we press <ESC> key.
* After getting out of loop, we destroy the window context.
* Lastly we terminate the [GLFW][glfw] itself.

2. `graphic_pipeline.nim`

This tutorial is the expansion from the first one. Here we define out shaders
with `nimsl` and call those shaders into our program. The pipeline of drawing
can be summarized as below:

* Do like the first tutorial at `startgflw.nim` until `glGenBuffers` part done.
* Compile our vertex shader (`myVertex`) which defined as `myVertexShader` proc.
* Compile our fragment shader (`myFragment`) which defined as `myFragmentShader` proc.
* *Notes: Both of procs are defined as default naming in its argument parameter. The* `aPos` *in its vertex shader proc only correctly used as* `attribute`*, as soon we changed the name into different naming, it's changed to* `uniform` *which is different with what we want in the code.*
* Create our program that attach our shaders, link and use it.
* Create our *VAO* (`Vertex Array Object`) for identifying which `vao` we are working.
* Get our attribute location, `aPos` (see notes above about naming), set it as `GL_FLOAT` (in Nim, we `GL_FLOAT` is identic with `GLfloat` so it's defined as `cGL_FLOAT`), and lastly enable it.
* In our main loop, we will clear the color and buffer, and we draw with `glDrawArrays`, with `GL_TRIANGLE` as the primitive operation, the offset vertices is 0, and draw 3 vertices in our buffer vertices.
* The rest of loop is same as the rest of loop mentioned at `startgflw.nim` above.

[open.gl]: https://open.gl
[staticglfw]: https://github.com/treeform/staticglfw
[glfw]: https://www.glfw.org
[nimsl]: https://github.com/yglukhov/nimsl
