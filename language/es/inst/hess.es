md5="581767592e80701a09dbe294bd55b90a";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{h} =} hess (@var{a})
@deftypefnx {Función cargable} {[@var{p}, @var{h}] =} hess (@var{a})
@cindex Hessenberg decomposition
Calcule la descomposición de la matriz de Hessenberg @var{a}.

La descomposición Hessenberg se utiliza generalmente como el
primer paso en un cálculo de valor propio, pero tiene otras
aplicaciones (ver Golub, Nash y Van Loan, IEEE Transactions en
Control Automatico, 1979). La descomposición Hessenberg es

@iftex
@tex
$$
A = PHP^T
$$
donde $P$ es una matriz unitaria cuadrada ($P^HP = I$), y $H$
es Hessenberg superior($H_{i,j} = 0, \forall i \ge j+1$).
@end tex
@end iftex
@ifinfo
@code{p * h * p' = a} donde @code{p} es una matriz unitaria cuadrada
(@code{p' * p = I}, utilizando transposición complex-conjugate) y 
@code{h} es Hessenberg superior (@code{i >= j+1 => h (i, j) = 0}).
@end ifinfo
@end deftypefn