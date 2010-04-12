md5="dfe73015f9ebfaf14723544dc0e30455";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} kolmogorov_smirnov_cdf (@var{x}, @var{tol})
Retorna la CDF en @var{x} de la distribuci@'on Kolmogorov-Smirnov,
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

El par@'ametro opcional @var{tol} especifica la precisi@'on con la cual 
la serie ser@'ia evaluada; el valor predetermiando de @var{tol} es @code{eps}.
@end deftypefn
