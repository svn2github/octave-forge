md5="0b34a11dcee784924a68fc09706bb09a";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{z}] =} wilcoxon_test (@var{x}, @var{y}, @var{alt})
Para dos pares de vectores de la muestra @var{x} y @var{y}, realice una
prueba de Wilcoxon de rangos de la hipótesis nula PROB (@var{x} >
@var{y}) == 1/2. Bajo la hipótesis nula, la estadística de prueba @var{z}
sigue aproximadamente una distribución normal estándar cuando 
@var{n} > 25.

@strong{Precausión}: Esta función supone una distribución normal para @var{z}
y por lo tanto no es válido para @var{n} <= 25.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés 
pueden ser seleccionados. Si @var{alt} es @code{"!="} o @code{"<>"}, se 
prueba la hipótesis nula contra la alternativa bilateral PROB (@var{x} > 
@var{y}) != 1/2. Si es alt @code{">"}, la alternativa unilateral PROB 
(@var{x} > @var{y}) > 1/2 es considera. Del mismo modo para @code{"<"},
la alternativa unilateral PROB (@var{x} > @var{y}) < 1/2 es considera.
El valor predeterminado es la alternativa bilateral

El valor-p de la prueba es regresado en @var{pval}.

Si no son dados argumentos de salida, el valor-p de la prueba es mostrado
@end deftypefn
