-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} std (@var{x})
@deftypefnx {Archivo de funci@'on} {} std (@var{x}, @var{opt})
@deftypefnx {Archivo de funci@'on} {} std (@var{x}, @var{opt}, @var{dim})
Si @var{x} es un vector, calcular la desviación estándar de los elementos
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
Si @var{x} es una matriz, calcular la desviación estándar de cada columna
y devolverlos en un vector fila.

El argumento @var{opt} determina el tipo de normalización de su uso. Los
valores válidos son

@table @asis 
@item 0:
  normaliza con @math{N-1}, proporciona la raíz cuadrada del mejor estimador 
  imparcial de la varianza [por defecto]
@item 1:
  normaliza con @math{N}, esto proporciona la raíz cuadrada del segundo 
  momento alrededor de la media
@end table

El tercer argumento @var{dim} determina la dimensión en la que la 
desviación estándar se calcula.
@seealso{mean, median}
@end deftypefn
