md5="e85a4e0e2e27f5bb6ffd2d2e9c4357a0";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Function File} {@var{x} =} are (@var{a}, @var{b}, @var{c}, @var{opt})
Resuelve la ecuaci�n algebr�ica de Riccati
@iftex
@tex
$$
A^TX + XA - XBX + C = 0
$$
@end tex
@end iftex
@ifinfo
@example
a' * x + x * a - x * b * x + c = 0
@end example
@end ifinfo

@strong{Inputs}
@noindent
para matrices cuadradas de dimensiones id�nticas
@table @var
@item a
matriz @var{n} por @var{n};
@item b
matriz @var{n} por @var{n} o @var{n} by @var{m}; en el �ltimo caso
@var{b} es reemplazado por @math{b:=b*b'};
@item c
matriz @var{n} por @var{n} o @var{p} por @var{m}; en el �ltimo caso
@var{c} es reemplazado por @math{c:=c'*c};
@item opt
(argumento opcional; predeterminado = @code{"B"}):
Opci�n de cadena pasada a @code{balance} previo a la factorizaci�n ordenada de Schur.
@end table

@strong{Output}
@table @var
@item x
soluci�n del @acronym{ARE}.
@end table

@strong{Method}
M�todo de Laub Schur (@acronym{IEEE} Transactions on
Automatic Control, 1979) es aplicado a la apropiada matrix Hamiltoniana.
@seealso{balance, dare}
@end deftypefn
