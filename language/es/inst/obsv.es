md5="1c543711559a7968a8da7ccff7d8fb3e";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} obsv (@var{sys}, @var{c})
@deftypefnx {Archivo de función} {} obsv (@var{a}, @var{c})
Construir matriz de observabilidad:
@iftex
@tex
$$ Q_b = \left[ \matrix{  C       \cr
                          CA    \cr
                          CA^2  \cr
                          \vdots  \cr
                          CA^{n-1} } \right ] $$
@end tex
@end iftex
@ifinfo
@example
@group
     | C        |
     | CA       |
Qb = | CA^2     |
     | ...      |
     | CA^(n-1) |
@end group
@end example
@end ifinfo
De una estructura de datos de sistema o los pares (@var{a}, @var{c}).

Las propiedades númericas de @command{is_observable}
son mucho mejores para las pruebas de observación.
@end deftypefn
