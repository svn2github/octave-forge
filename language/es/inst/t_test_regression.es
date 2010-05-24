md5="33cbaff2daa409097ad32fc59ffd5208";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{t}, @var{df}] =} t_test_regression (@var{y}, @var{x}, @var{rr}, @var{r}, @var{alt})
Realizar una prueba t para la hipótesis nula @code{@var{rr} * @var{b} =
@var{r}} en un modelo de regresión normal clásico @code{@var{y} =
@var{x} * @var{b} + @var{e}}. Bajo la hipótesis nula, la estadística
de prueba  @var{t} sigue un @var{t} distribución con @var{df} grados 
de libertad.

Si @var{r} es omitida, un valor de 0 es asumido.

Con el argumento de cadena opcional @var{alt}, la alternativa de
interés puede ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"},
se prueba la hipótesis nula contra la alternativa bilateral 
@code{@var{rr} * @var{b} != @var{r}}. Si @var{alt} es @code{">"}, la 
alternativa unilateral @code{@var{rr} * @var{b} > @var{r}} se utiliza.
Del mismo modo para @var{"<"}, la alternativa unilateral @code{@var{rr} *
@var{b} < @var{r}} se utiliza. El valor predeterminado es el caso
bilateral.

el valor-p de la prueba es retornado en @var{pval}.

Si un argumento de salida no es dado, el valor-p de la prueba es mostrado. 
@end deftypefn 