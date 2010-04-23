md5="bda21e39259aa23d9cf5562988a3f585";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{tsq}] =} hotelling_test (@var{x}, @var{m})

Para una muestra  @var{x} de la distribución normal multivariada con media 
y matriz de covarianza desconocidas, prueba la hipótesis nula @code{mean
(@var{x}) == @var{m}}.

La @math{T^2} de Hotelling se retorna en @var{tsq}.  Bajo la hipótesis nula, 
@math{(n-p) T^2 / (p(n-1))} tiene una distribución F con @math{p} y @math{n-p} 
grados de libertad, donde @math{n} y @math{p} con los números de muestras y 
variables, respectivamente.

El valor @var{p} de la prueba se retorna en @var{pval}.

Si no se suministra argumeto de saldia, se muestra el valor @var{p} de la prueba.
@end deftypefn
