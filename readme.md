# Adapting Modern OpenGL Guide in Nim

This is the notes of lesson from [open.gl][open.gl] adapted using Nim.

## Preparation

In this notes, I use excellent Nim package [staticglfw][staticglfw] for
[GLFW][glfw] setup and package [nimsl][nimsl] for shader DSL instead of
textual representation.

Install both with

```
nimble install staticglfw
nimble install nimsl
```


[open.gl]: https://open.gl
[staticglfw]: https://github.com/treeform/staticglfw
[glfw]: https://www.glfw.org
[nimsl]: https://github.com/yglukhov/nimsl
