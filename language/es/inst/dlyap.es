md5="bc6db52fcc344d4ed459a41e850492d8";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dlyap (@var{a}, @var{b})
Resuelve la ecuación de Lyapunov en tiempo discreto 

@strong{Entradas}
@table @var
@item a
Matriz @var{n} por @var{n};
@item b
Matriz: @var{n} por @var{n}, @var{n} por @var{m}, o @var{p} por @var{n}.
@end table

@strong{Salida}
@table @var
@item x
Matriz que satisface apropiadamente la ecuación de Lyapunov en en 
tiempo discreto.
@end table

Opciones:
@itemize @bullet
@item @var{b} es cuadrado: resuelve  
@iftex
@tex
$$ axa^T - x + b = 0 $$
@end tex
@end iftex
@ifinfo
@code{a x a' - x + b = 0}
@end ifinfo
@item @var{b} no es cuadrado: @var{x} satisface 
@iftex
@tex
$$ axa^T - x + bb^T = 0 $$
@end tex
@end iftex
@ifinfo
@example
a x a' - x + b b' = 0
@end example
@end ifinfo
@noindent
o 
@iftex
@tex
$$ a^Txa - x + b^Tb = 0, $$
@end tex
@end iftex
@ifinfo
@example
a' x a - x + b' b = 0,
@end example
@end ifinfo
@noindent
cualquiera que es apropiado. 
@end itemize

@strong{Método}
Usa el método de descomposición de Schur como se muestra en Kitagawa,
@cite{An Algorithm for Solving the Matrix Equation @math{X = F X F' + S}},
International Journal of Control, Volume 25, Number 5, pages 745--753
(1977).

Método de solución columna-por-columna como se sugiere en 
Hammarling, @cite{Numerical Solution of the Stable, Non-Negative
Definite Lyapunov Equation}, @acronym{IMA} Journal of Numerical Analysis, Volume
2, pages 303--323 (1982).
@end deftypefn
