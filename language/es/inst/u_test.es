md5="afed07ecb5872e455f0b0b164ffabbc2";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{z}] =} u_test (@var{x}, @var{y}, @var{alt})
Para dos muestras @var{x} y @var{y}, realice un test-u de Mann-Whitney
de la hipótesis nula PROB (@var{x} > @var{y}) == 1/2 == PROB (@var{x}
< @var{y}). Bajo la hipótesis nula, la estadística de prueba @var{z}
sigue aproximadamente una distribución normal estándar. Tenga en 
cuenta que esta prueba es equivalente a la de Wilcoxon rank-sum.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral PROB (@var{x} > @var{y})
!= 1/2. Si @var{alt} es @code{">"}, la alternativa unilateral PROB 
(@var{x} > @var{y}) > 1/2 es considerado. Del mismo modo para @code{"<"},
la alternativa unilateral PROB (@var{x} > @var{y}) < 1/2 es considerada.
El valor predeterminado es la alternativa bilateral.

El valor-p de el test es devuelto en @var{pval}.

Si no se da un argumento de salida, el valor-p de el test es el mostrado.
@end deftypefn 