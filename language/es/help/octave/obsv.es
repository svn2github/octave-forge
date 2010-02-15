md5="1c543711559a7968a8da7ccff7d8fb3e";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} obsv (@var{sys}, @var{c})
@deftypefnx {Archivo de funci@'on} {} obsv (@var{a}, @var{c})
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

Las propiedades n@'umericas de @command{is_observable}
son mucho mejores para las pruebas de observaci@'on.
@end deftypefn
