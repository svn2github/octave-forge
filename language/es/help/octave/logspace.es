md5="1ebaf103578c89b70483c3cd869857bf";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} logspace (@var{base}, @var{limit}, @var{n})
Similar a @code{linspace} salvo que los valores son logar@'itmicamente 
espaceados de
@iftex
@tex
$10^{base}$ to $10^{limit}$.
@end tex
@end iftex
@ifinfo
10^base hasta 10^l@'imite.
@end ifinfo

Si @var{limit} es igual a
@iftex
@tex
$\pi$,
@end tex
@end iftex
@ifinfo
pi,
@end ifinfo
los puntos son entre
@iftex
@tex
$10^{base}$ y $\pi$,
@end tex
@end iftex
@ifinfo
10^base y pi,
@end ifinfo
@emph{not}
@iftex
@tex
$10^{base}$ y $10^{\pi}$,
@end tex
@end iftex
@ifinfo
10^base y 10^pi,
@end ifinfo
Con el fin de ser compatible con la correspondiente funci@'on de 
@sc{Matlab}.

Tambi@'en por compatibilidad, regresar el segundo argumento si se
solicitan menos de dos valores.
@seealso{linspace}
@end deftypefn