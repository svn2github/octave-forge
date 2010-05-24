md5="a5cb7b3396785d56224b1f12b127befd";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{t}, @var{df}] =} welch_test (@var{x}, @var{y}, @var{alt})
Para dos muestras @var{x} y @var{y} a partir de distribuciones
normales con medias desconocidas y variaciones desconocidas no
necesariamente iguales, realice una prueba Welch de la  hipótesis
nula de medias iguales. Bajo la hipótesis nula, la estadística
de prueba @var{t} aproximadamente sigue una distribución de Student
con @var{df} grados de libertad.

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