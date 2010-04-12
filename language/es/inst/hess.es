md5="581767592e80701a09dbe294bd55b90a";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{h} =} hess (@var{a})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{h}] =} hess (@var{a})
@cindex Hessenberg decomposition
Calcule la descomposici@'on de la matriz de Hessenberg @var{a}.

La descomposici@'on Hessenberg se utiliza generalmente como el
primer paso en un c@'alculo de valor propio, pero tiene otras
aplicaciones (ver Golub, Nash y Van Loan, IEEE Transactions en
Control Automatico, 1979). La descomposici@'on Hessenberg es

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
(@code{p' * p = I}, utilizando transposici@'on complex-conjugate) y 
@code{h} es Hessenberg superior (@code{i >= j+1 => h (i, j) = 0}).
@end ifinfo
@end deftypefn