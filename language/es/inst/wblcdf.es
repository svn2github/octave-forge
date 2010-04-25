md5="dbe6f99094d3aa24295a4a98367acca6";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} wblcdf (@var{x}, @var{scale}, @var{shape})
Calcula la funciób de distribución acumulada (CDF) en @var{x} de la 
distribución Weibull con parámetro de escala @var{scale} y parámetro 
de forma @var{shape}, el cual esta dado por 

@iftex
@tex
$$ 1 - \exp(-(x/shape)^{scale}) $$
para $x\geq 0$.
@end tex
@end iftex
@ifnottex
@example
1 - exp(-(x/shape)^scale)
@end example
para @var{x} >= 0.
@end ifnottex
@end deftypefn
