md5="f584ab46f14de2165f0b12ca7e141488";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{zer}, @var{gain}] =} tzero (@var{a}, @var{b}, @var{c}, @var{d}, @var{opt})
@deftypefnx {Archivo de función} {[@var{zer}, @var{gain}] =} tzero (@var{sys}, @var{opt})
Calcule los ceros de transmisión de un sistema continuo:
@iftex
@tex
$$ \dot x = Ax + Bu $$
$$ y = Cx + Du $$
@end tex
@end iftex
@ifinfo
@example
.
x = Ax + Bu
y = Cx + Du
@end example
@end ifinfo
or of a discrete one:
@iftex
@tex
$$ x_{k+1} = Ax_k + Bu_k $$
$$ y_k = Cx_k + Du_k $$
@end tex
@end iftex
@ifinfo
@example
x(k+1) = A x(k) + B u(k)
y(k)   = C x(k) + D u(k)
@end example
@end ifinfo

@strong{Outputs}
@table @var
@item zer
 ceros de transmisión de el sistema
@item gain
primer coeficiente (pole-zero form) de @acronym{SISO} función de
transferencia devuelve gain = 0 si el sistema es multivariable

@end table
@strong{Referencias}
@enumerate
@item Emami-Naeini and Van Dooren, Automatica, 1982.
@item Hodel, @cite{Computation of Zeros with Balancing}, 1992 Lin. Alg. Appl.
@end enumerate
@end deftypefn 