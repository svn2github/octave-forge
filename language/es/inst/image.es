md5="4b76118be88b0e387f921172a810b924";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} image (@var{img})
@deftypefnx {Archivo de funci@'on} {} image (@var{x}, @var{y}, @var{img})
Muestra una matriz como una imagen en color. Los elementos de @var{x}
son @'indices en el mapa de color actual, el mapa de color se
incrementar@'a de manera que los extremos de la @var{x} se asignan a
los extremos del mapa de color.

En primer lugar trata de usar @code{gnuplot}, luego @code{display} de
@code{ImageMagick}, luego @code{xv}, y a luego @code{xloadimage}.
El programa utilizado se puede cambiar con la funci@'on @code{image_viewer}.

El eje de los valores correspondientes a los elementos de la matriz se
especifican en @var{x} y @var{y}. Si usted no est@'a utilizando gnuplot 4.2
o posterior, se omiten estas variables.
@seealso{imshow, imagesc, colormap, image_viewer}
@end deftypefn