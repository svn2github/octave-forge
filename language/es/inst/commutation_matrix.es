md5="d3fe118abaa7bf2e690fb35398d2e1fe";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} commutation_matrix (@var{m}, @var{n})
Retorna la matriz de commutación
@iftex
@tex
 $K_{m,n}$
@end tex
@end iftex
@ifinfo
 K(m,n)
@end ifinfo
 la cual es única
@iftex
@tex
 $m n \times m n$
@end tex
@end iftex
@ifinfo
@var{m}*@var{n} por @var{m}*@var{n}
@end ifinfo
 matriz tal que
@iftex
@tex
 $K_{m,n} \cdot {\rm vec} (A) = {\rm vec} (A^T)$
@end tex
@end iftex
@ifinfo
@math{K(m,n) * vec(A) = vec(A')}
@end ifinfo
 para todas
@iftex
@tex
 $m\times n$
@end tex
@end iftex
@ifinfo
@math{m} por @math{n}
@end ifinfo
 matrices
@iftex
@tex
 $A$.
@end tex
@end iftex
@ifinfo
@math{A}.
@end ifinfo

Si solo se suministra el argumento @var{m},
@iftex
@tex
 $K_{m,m}$
@end tex
@end iftex
@ifinfo
@math{K(m,m)}
@end ifinfo
 es retornado.

Véase Magnus y Neudecker (1988), Matrix differential calculus with
applications in statistics and econometrics.
@end deftypefn
