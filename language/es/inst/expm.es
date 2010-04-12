md5="347c087ffb692eb03865ce7d58ae4599";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} expm (@var{a})
Retorna el exponencial de una matriz, definido como una serie de Taylor 
infinita 
@iftex
@tex
$$
 \exp (A) = I + A + {A^2 \over 2!} + {A^3 \over 3!} + \cdots
$$
@end tex
@end iftex
@ifinfo

@example
expm(a) = I + a + a^2/2! + a^3/3! + ...
@end example

@end ifinfo
La serie de Taylor @emph{no} es la forma de calcular el exponencial de una
matriz; v@'ease Moler y Van Loan, @cite{Nineteen Dubious Ways to
Compute the Exponential of a Matrix}, SIAM Review, 1978. @code{expm} 
usa la diagonal de Ward 
@iftex
@tex
Pad\'e
@end tex
@end iftex
@ifinfo
Pade'
@end ifinfo
como m@'etodo de aproximaci@'on con tres paso de precondicionamiento (SIAM Journal 
on Numerical Analysis, 1977). Las aproximaciones de la diagonal 
@iftex
@tex
Pad\'e
@end tex
@end iftex
@ifinfo
Pade'
@end ifinfo 
son polinomios raionales de las matrices 
@iftex
@tex
$D_q(a)^{-1}N_q(a)$
@end tex
@end iftex
@ifinfo

@example
     -1
D (a)   N (a)
@end example

@end ifinfo
cuyas series de Taylor coinciden con los primeros 
@iftex
@tex
$2 q + 1 $
@end tex
@end iftex
@ifinfo
@code{2q+1}
@end ifinfo
t@'erminos de la serie de Taylor anterior; la evaluaci@'on directa de la serie de Taylor 
(con los mismos pasos de precondicionamiento) puede ser deseable en virtud de la aproximaci@'on 
@iftex
@tex
Pad\'e
@end tex
@end iftex
@ifinfo
Pade'
@end ifinfo
cuando 
@iftex
@tex
$D_q(a)$
@end tex
@end iftex
@ifinfo
@code{Dq(a)}
@end ifinfo
est@'a mal condicionado. 
@end deftypefn