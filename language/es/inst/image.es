md5="4b76118be88b0e387f921172a810b924";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} image (@var{img})
@deftypefnx {Archivo de función} {} image (@var{x}, @var{y}, @var{img})
Muestra una matriz como una imagen en color. Los elementos de @var{x}
son índices en el mapa de color actual, el mapa de color se
incrementará de manera que los extremos de la @var{x} se asignan a
los extremos del mapa de color.

En primer lugar trata de usar @code{gnuplot}, luego @code{display} de
@code{ImageMagick}, luego @code{xv}, y a luego @code{xloadimage}.
El programa utilizado se puede cambiar con la función @code{image_viewer}.

El eje de los valores correspondientes a los elementos de la matriz se
especifican en @var{x} y @var{y}. Si usted no está utilizando gnuplot 4.2
o posterior, se omiten estas variables.
@seealso{imshow, imagesc, colormap, image_viewer}
@end deftypefn