md5="64f8051129c19903dfc6bdad7eeb8b3b";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} beta (@var{a}, @var{b})
Retorna la función Beta,
@iftex
@tex
$$
 B (a, b) = {\Gamma (a) \Gamma (b) \over \Gamma (a + b)}.
$$
@end tex
@end iftex
@ifinfo

@example
beta (a, b) = gamma (a) * gamma (b) / gamma (a + b).
@end example
@end ifinfo
@end deftypefn
