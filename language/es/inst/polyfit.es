md5="1447c96f6fbe3dfa5f2eaa8b40d9af33";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{p}, @var{s}] =} polyfit (@var{x}, @var{y}, @var{n})
Regresa los coeficientes de un polinomio @var{p}(@var{x}) de grado 
@var{n} que minimiza
@iftex
@tex
$$
\sum_{i=1}^N (p(x_i) - y_i)^2
$$
@end tex
@end iftex
@ifinfo
@code{sumsq (p(x(i)) - y(i))},
@end ifinfo
para ajustar mejor los datos en el sentido de mínimos cuadrados
 
Los coeficientes del polinomio se devuelven en un vector de fila.

Si se piden dos argumentos de salida, la segunda es una estructura
que contiene los siguientes campos:

@table @code
@item R
El factor de Cholesky de la matriz de Vandermonde utilizado para
calcular los coeficientes del polinomio.
@item X
La  matriz Vandermode usada para calular los coeficientes del
polinomio.
@item df
Los grados de libertad
@item normr
La norma de los residuos.
@item yf
Los valores del polinomio para cada valor de @var{x}.
@end table
@end deftypefn