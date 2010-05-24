md5="df722763ff6b341ea1835b97daf49b62";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{z}] =} z_test (@var{x}, @var{m}, @var{v}, @var{alt})
Realizar una prueba-Z de la hipótesis nula @code{mean (@var{x}) ==
@var{m}} para una muestra @var{x} de una distribución normal con media
desconocida y varianza conocida @var{v}. Bajo la hipótesis nula, la 
estadística de prueba @var{z} sigue una distribución normal estándar.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @code{mean (@var{x}) != @var{m}}.
Si @var{alt} es @code{">"}, la alternativa unilateral @code{mean (@var{x}) > @var{m}} 
es considerado. Del mismo modo para @code{"<"}, la alternativa unilateral @code{mean
(@var{x}) < @var{m}} es considerada. El valor predeterminado es la alternativa
bilateral.

El valor-p de la prueba se devuelve en @var{pval}.

Si no se da argumento de salida, el valor-p de la prueba se muestra
junto con alguna información.
@end deftypefn 