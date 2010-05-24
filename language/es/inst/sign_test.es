md5="32e4bde9efa976cf71545c1c5369b3ae";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{b}, @var{n}] =} sign_test (@var{x}, @var{y}, @var{alt})
Para dos pares de muestras @var{x} y @var{y}, realice una prueba de
los signos de la hipótesis nula PROB (@var{x} > @var{y}) == PROB (@var{x} <
@var{y}) == 1/2. Bajo la hipótesis nula, la estadística de prueba @var{b}
sigue aproximadamente una distribución binomial con parámetros @code{@var{n} = sum
(@var{x} != @var{y})} y @var{p} = 1/2.

Con el argumento opcional  @code{alt}, la alternativa de interés pueden
ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, se prueba 
la hipótesis nula contra la alternativa bilateral PROB (@var{x} < @var{y})
!= 1/2.  Si @var{alt} es @code{">"}, la alternativa unilateral PROB 
(@var{x} > @var{y}) > 1/2 ("x es estocásticamente mayor que y") es 
considera. Del mismo modo para @code{"<"}, la alternativa unilateral
PROB (@var{x} > @var{y}) < 1/2 ("x  es estocásticamente menos que y")
es considera. El valor predeterminado es el caso bilateral.

El valor-p de el test es regresado en @var{pval}.

Si los argumentos de salida no son dados, el valor-p de la prueba es 
mostrado.
@end deftypefn
