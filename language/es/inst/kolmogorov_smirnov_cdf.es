md5="dfe73015f9ebfaf14723544dc0e30455";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} kolmogorov_smirnov_cdf (@var{x}, @var{tol})
Retorna la CDF en @var{x} de la distribución Kolmogorov-Smirnov,
@iftex
@tex
$$ Q(x) = \sum_{k=-\infty}^\infty (-1)^k \exp(-2 k^2 x^2) $$
@end tex
@end iftex
@ifinfo
@example
         Inf
Q(x) =   SUM    (-1)^k exp(-2 k^2 x^2)
       k = -Inf
@end example
@end ifinfo

@noindent
para @var{x} > 0.

El parámetro opcional @var{tol} especifica la precisión con la cual 
la serie sería evaluada; el valor predetermiando de @var{tol} es @code{eps}.
@end deftypefn
