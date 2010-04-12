md5="dbe6f99094d3aa24295a4a98367acca6";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} wblcdf (@var{x}, @var{scale}, @var{shape})
Calcula la funci@'ob de distribuci@'on acumulada (CDF) en @var{x} de la 
distribuci@'on Weibull con par@'ametro de escala @var{scale} y par@'ametro 
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
