md5="bd143222caba6ac5a3f783aac0823eba";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} duplication_matrix (@var{n})
Retorna la matriz de duplicación 
@iftex
@tex
 $D_n$
@end tex
@end iftex
@ifinfo
@math{Dn}
@end ifinfo
 la cual es única
@iftex
@tex
 $n^2 \times n(n+1)/2$
@end tex
@end iftex
@ifinfo
@math{n^2} por @math{n*(n+1)/2}
@end ifinfo
 matriz tal que 
@iftex
@tex
 $D_n * {\rm vech} (A) = {\rm vec} (A)$
@end tex
@end iftex
@ifinfo
@math{Dn vech (A) = vec (A)}
@end ifinfo
 para todos simétrica
@iftex
@tex
 $n \times n$
@end tex
@end iftex
@ifinfo
@math{n} por @math{n}
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

Véase Magnus y Neudecker (1988), Matrix differential calculus with
applications in statistics and econometrics.
@end deftypefn
