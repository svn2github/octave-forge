md5="96ff15a4d0fc5754695d5309e037f0ca";rev="7199";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci�n} {[@var{n}, @var{m}, @var{p}] =} abcddim (@var{a}, @var{b}, @var{c}, @var{d})
Prueba de compatibilidad de las dimensiones de las matrices definiendo 
el sistema lineal
@iftex
@tex
$[A, B, C, D]$ correspondiente a
$$
\eqalign{
 {dx\over dt} &= A x + B u\cr
            y &= C x + D u}
$$
@end tex
@end iftex
@ifinfo
[A, B, C, D] correspondiente a

@example
dx/dt = a x + b u
y = c x + d u
@end example

@end ifinfo
o un sistema similar en tiempo discreto.

Si las matrices son compatibles en dimensiones, entonces @code{abcddim} retorna

@table @var
@item n
El n�mero de estados del sistema.

@item m
El n�mero de entradas del sistema.

@item p
El n�mero de salidas del sistema.
@end table

De lo contrario @code{abcddim} returns @var{n} = @var{m} = @var{p} = @minus{}1.

Nota: n = 0 (bloque de pura ganancia) se devuelve sin previo aviso.
@seealso{is_abcd}
@end deftypefn
