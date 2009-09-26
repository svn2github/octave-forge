md5="4c58101cb46b30c619c8d0b77b1e638f";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fplot (@var{fn}, @var{limits})
@deftypefnx {Archivo de funci@'on} {} fplot (@var{fn}, @var{limits}, @var{tol})
@deftypefnx {Archivo de funci@'on} {} fplot (@var{fn}, @var{limits}, @var{n})
@deftypefnx {Archivo de funci@'on} {} fplot (@dots{}, @var{fmt})
Grafica la funci@'on @var{fn}, dentro de los l@'imites definidos. La funci@'on @var{fn}
debe ser una cadena, un manejador de funci@'on o una funci@'on en l@'inea. 
Los l@'imites de la gr'afica estan dados por @var{limits} de la forma 
@code{[@var{xlo}, @var{xhi}]} o @code{[@var{xlo}, @var{xhi},
@var{ylo}, @var{yhi}]}. La variable @var{tol} es la tolerancia predeterminada que 
se va a usar en la gr@'afica, y si @var{tol} es un entero, se asume que representa el
n@'umero de puntos a usar en la gr@'afica. El argumento @var{fmt} se pasa al comando 
de graficaci@'on.

@example
   fplot ("cos", [0, 2*pi])
   fplot ("[cos(x), sin(x)]", [0, 2*pi])
@end example
@seealso{plot}
@end deftypefn
