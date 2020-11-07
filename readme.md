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


[open.gl]: https://open.gl
[staticglfw]: https://github.com/treeform/staticglfw
[glfw]: https://www.glfw.org
[nimsl]: https://github.com/yglukhov/nimsl
