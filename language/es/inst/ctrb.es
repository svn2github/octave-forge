md5="1518a89f2c5a8446a19a47b3f21fda23";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} ctrb (@var{sys}, @var{b})
@deftypefnx {Archivo de función} {} ctrb (@var{a}, @var{b})
Construye la matriz de control:
@iftex
@tex
$$ Q_s = [ B AB A^2B \ldots A^{n-1}B ] $$
@end tex
@end iftex
@ifinfo
@example
             2       n-1
Qs = [ B AB A B ... A   B ]
@end example
@end ifinfo

de una estructura de datos del sistema o la pareja (@var{a}, @var{b}).

@command{ctrb} forma la matriz de control.
Las propiedades numéricas de @command{is_controllable}
son mejores para las pruebas de control.
@end deftypefn
