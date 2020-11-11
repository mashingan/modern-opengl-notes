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
nimble install nimPNG
nimble install glm
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

3. `blink_triangle.nim`
This notes file is extended from previous note (`graphic_pipeline.nim`), with
the different only in part of adding `triangleColor` as uniform in fragment
shader, and setting the color up to red by `glUniform3f`. Additionally, we are
varying the value of red, with sinusiodal based on time elapsed.

4. `color_triangle.nim`
Although the triangle is already colorised, this notes is actually giving
the different color fragment shade for each vertex. The vertices definition
using different RGB colors for each it's packed array definition. This notes
also extended from previous notes (`blink_triangle.nim`) which used uniform
variable shader. The different can be summarized below:

* Getting color attribute from program.
* Deleting the instance of getting uniform variable from program.
* Deleting the dynamic uniform value set.

5. `element_square.nim`
This notes is the continuation of drawing chapter. This notes emphasizes the
the usages of elements together with vertices array. In most code, this doesn't
differ much with previous notes with only diff:

* Adding `elements` variable which define the order of rendering.
* Adding elements buffer (`ebo` variable) for keeping the `elements` variable.
* Changing the GL draw method from `glDrawArrays` to `glDrawElements`

6. `texture_using.nim`
This notes is the initial notes for textures chapter. This also is extended
previous notes with additional textures coordinates for each vertex and
loading the texture with dummy pixel array values. This notes also using
manual written fragment shader instead of nimsl because the need of using
GLSL builtin function `texture2D` and builtin data type `sampler2D`.

7. `texture_filters.nim`
This notes adds texture filter with using sample.png image which loaded using
nimPNG. All other parts are same with previous notes.

8. `texture_units.nim`
This is almost same with previous with additional of 2 textures which mixed
together halfly on each other. With `glActiveTexture`, we choose which texture
we want to use. We also make both of texture as uniform vec2 variables and
set the texture with `glUniform1i`. This is worthy of note that the GLSL
compiler will optimize away the unused variables and will remove the link and
its variable itself if the attribute variable is not used.

9. `transform_rotate.nim`
This is the first notes of transform chapter. We reuse the almost same code
from the previous `texture_units.nim` but without the color attribute and
without using `nimsl` because it clashes with various definitions from `nim-glm`
package. We apply the transformation into uniform `trans` variable in vertex
shader as the `gl_Position` value.

10. `transform_rotate3d.nim`
The continuation notes, this time in addition to explain the perspective
and projection of camera view and world, we also spice up with animated
blending from the exercise in the previous chapter (texture chapter).

11. `depthstencil_cubed.nim`
This notes is the first notes in chapter of depth buffer and stencil buffer.
Taking the base of notes from previous lesson, this notes changes the vertices
to represent the cubed surfaces area in 36 vertices. We also change back the
drawing method from `glDrawElements` to `glDrawArrays` as the vertices
representation is reverted back to simple vertices.  
What also changed is the camera position from `1.2, 1.2, 1.2` to `2.5, 2.5, 2.0`
to get better view of our cube surface. Without `glEnable(GL_DEPTH_TEST)`, we
will see our cube rendered as hollow cube, but it becomes solid boxed cube
after we enable it. The vertices representation also adds `Z` in the position
coordinate so we change our shader from `vec2` to `vec3`.

12. `depthstencil_cubereflect.nim`
As usual, this time we continue the previous notes with additional reflection
cube and a planar surface. The planar vertices are added in existing `vertices`
array so we draw it 6 vertices with offset of 36 vertices
(`glDrawArrays(GL_TRIANGLES, 36, 6)`). As the reflected cube, we transform it
to below in Z axis, and then scale it with each vector direction
(`vec3(1, 1, -1)`). Lastly we draw the all vertices cube again for the reflected
cube.

13. `depthstencil_reflectsurface.nim`
As the continuation from previous, this time we enable the `GL_STENCIL_TEST` to
as its the extension of depth buffer for control over which fragments drawn.
Using stencil buffer, we only draw the needed areas when those stencil values are
1. We disable depth buffer drawing when drawing the floor surface, after we
saved our stencil buffer to only draw the necessary part.  
The second part is the reflection. We reflect our original model cube into reflection cube
model but this time we enable drawing depth buffer. We add a color mask of
`vec3f(0.3, 0.3, 0.3)` to darken the floor surface reflection and after drawing it,
we restore the color mask to `vec3f(1, 1, 1)` (identity vector) to make it normal.

14. `framebuffers_inits.nim`
This time the example a bit involved especially with the necessary refactor
for needed handle object to its own object type. With `initScene` we immediately
generate the vertex and buffer array, we also compile the vertex and fragment
shader and attach those shaders to our program. We also abstract out the
needed for loading the images. We put the program attribute variables into
its own function so we just only need to call it.  
Apart from the big refactor, in this notes example, we define our framebuffers
and its render buffer which we draw it after we finished drawing our cube,
its reflection and also the floor. Except for initializing those buffers,
it's no different than previous notes.

15. `framebuffers_colors.nim`
This notes only plays with different framebuffers color for post-processing. The
frame is drawn in grayscale which multiplied to weighted channels.

16. `framebuffers_blur.nim`
This notes also playes with blurring our image with average of `blurSize` for each
texture coordinate.

17. `framebuffers_edgedetect.nim`
This notes displays different post-processing effect which often used as edge
detection around the color texture.

[open.gl]: https://open.gl
[staticglfw]: https://github.com/treeform/staticglfw
[glfw]: https://www.glfw.org
[nimsl]: https://github.com/yglukhov/nimsl
