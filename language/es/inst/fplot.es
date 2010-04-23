md5="4c58101cb46b30c619c8d0b77b1e638f";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} fplot (@var{fn}, @var{limits})
@deftypefnx {Archivo de función} {} fplot (@var{fn}, @var{limits}, @var{tol})
@deftypefnx {Archivo de función} {} fplot (@var{fn}, @var{limits}, @var{n})
@deftypefnx {Archivo de función} {} fplot (@dots{}, @var{fmt})
Grafica la función @var{fn}, dentro de los límites definidos. La función @var{fn}
debe ser una cadena, un apuntador de función o una función en línea. 
Los límites de la gr'afica estan dados por @var{limits} de la forma 
@code{[@var{xlo}, @var{xhi}]} o @code{[@var{xlo}, @var{xhi},
@var{ylo}, @var{yhi}]}. La variable @var{tol} es la tolerancia predeterminada que 
se va a usar en la gráfica, y si @var{tol} es un entero, se asume que representa el
número de puntos a usar en la gráfica. El argumento @var{fmt} se pasa al comando 
de graficación.

@example
   fplot ("cos", [0, 2*pi])
   fplot ("[cos(x), sin(x)]", [0, 2*pi])
@end example
@seealso{plot}
@end deftypefn
