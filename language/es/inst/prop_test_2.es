md5="798154219c48fd3dbd1ea663776d3982";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{z}] =} prop_test_2 (@var{x1}, @var{n1}, @var{x2}, @var{n2}, @var{alt})
Si @var{x1} y @var{n1} son las cuentas de  éxitos y los ensayos en
una muestra, y @var{x2} y @var{n2} los que están en un segundo, la
hipótesis nula de las probabilidades de éxito @var{p1} y @var{p2}
son las mismas. Bajo la hipótesis nula, la estadística de prueba
@var{z} sigue aproximadamente una distribución normal estándar.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @var{p1} != @var{p2}.
Si @var{alt} es @code{">"}, la alternativa unilateral  @var{p1} > @var{p2}
es usado. Del mismo modo para @code{"<"}, la alternativa unilateral 
@var{p1} < @var{p2} es usada. El valor predeterminado es la alternativa 
bilateral.

El valor-p de la prueba se devuelve en @var{pval}.

Si no se da ningún argumento de salida, se muestra el valor-p de la
prueba.
@end deftypefn 