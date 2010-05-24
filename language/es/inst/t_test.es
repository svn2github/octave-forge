md5="06e4268b82172710dde0bde1cf225c03";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{t}, @var{df}] =} t_test (@var{x}, @var{m}, @var{alt})
Para una muestra @var{x} de una distribución normal con media
desconocida y varianza, realizar una prueba-t de la hipótesis nula
@code{mean (@var{x}) == @var{m}}. Bajo la hipótesis nula, la
estadística de prueba @var{t} sigue una distribución de Student
con @code{@var{df} = length (@var{x}) - 1} grados de libertad.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @code{mean (@var{x}) != @var{m}}.
Si @var{alt} es @code{">"}, la alternativa unilateral @code{mean (@var{x}) > @var{m}} 
es considerado. Del mismo modo para @code{"<"}, la alternativa unilateral @code{mean
(@var{x}) < @var{m}} es considerada. El valor predeterminado es la alternativa
bilateral.

El valor-p de la prueba es devuelto en @var{pval}.

Si no se da argumento de salida, el valor-p de la prueba es el mostrado.
@end deftypefn 