md5="d6883851eb088497973494e2b0e791f9";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} wblpdf (@var{x}, @var{scale}, @var{shape})
Calcula la función de densidad de probabilidad (PDF) de @var{x} 
de la distribución de Weibull con parámetro de escala @var{scale} 
y de forma @var{shape}, los cuales estan dados por 

@iftex
@tex
$$  scale \cdot shape^{-scale} x^{scale-1} \exp(-(x/shape)^{scale}) $$
@end tex
@end iftex
@ifnottex
@example
   scale * shape^(-scale) * x^(scale-1) * exp(-(x/shape)^scale)
@end example
@end ifnottex

@noindent
para @var{x} > 0.
@end deftypefn
