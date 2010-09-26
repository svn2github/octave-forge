-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} std (@var{x})
@deftypefnx {Archivo de funci@'on} {} std (@var{x}, @var{opt})
@deftypefnx {Archivo de funci@'on} {} std (@var{x}, @var{opt}, @var{dim})
Si @var{x} es un vector, calcular la desviaci�n est�ndar de los elementos
de @var{x}.
@iftex
@tex
$$
{\rm std} (x) = \sigma (x) = \sqrt{{\sum_{i=1}^N (x_i - \bar{x})^2 \over N - 1}}
$$
donde $\bar{x}$ es el valor medio de $x$.
@end tex
@end iftex
@ifnottex

@example
@group
std (x) = sqrt (sumsq (x - mean (x)) / (n - 1))
@end group
@end example
@end ifnottex
Si @var{x} es una matriz, calcular la desviaci�n est�ndar de cada columna
y devolverlos en un vector fila.

El argumento @var{opt} determina el tipo de normalizaci�n de su uso. Los
valores v�lidos son

@table @asis 
@item 0:
  normaliza con @math{N-1}, proporciona la ra�z cuadrada del mejor estimador 
  imparcial de la varianza [por defecto]
@item 1:
  normaliza con @math{N}, esto proporciona la ra�z cuadrada del segundo 
  momento alrededor de la media
@end table

El tercer argumento @var{dim} determina la dimensi�n en la que la 
desviaci�n est�ndar se calcula.
@seealso{mean, median}
@end deftypefn
