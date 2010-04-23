md5="ba1e9b3ab0343eb8a6f2ed429abd3063";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dgram (@var{a}, @var{b})
Retorna el gramiano de controlabilidad del sistema de tiempo discreto 
@iftex
@tex
$$ x_{k+1} = ax_k + bu_k $$
@end tex
@end iftex
@ifinfo
@example
  x(k+1) = a x(k) + b u(k)
@end example
@end ifinfo

@strong{Entradas}
@table @var
@item a
Matriz @var{n} por  @var{n}
@item b
Matriz @var{n} por @var{m} 
@end table

@strong{Salida}
@table @var
@item m 
Matriz @var{n} por @var{n}, satisface 
@iftex
@tex
$$ ama^T - m + bb^T = 0 $$
@end tex
@end iftex
@ifinfo
@example
 a m a' - m + b*b' = 0
@end example
@end ifinfo
@end table
@end deftypefn
