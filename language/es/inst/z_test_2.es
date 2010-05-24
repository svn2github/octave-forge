md5="06d757e9e3d095f3394db473f8f48909";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{z}] =} z_test_2 (@var{x}, @var{y}, @var{v_x}, @var{v_y}, @var{alt})
Para dos muestras @var{x} y @var{y} a partir de distribuciones
normales con medias desconocidas y varianzas conocidas @var{v_x}
y @var{v_y}, realizar una prueba-z de la hipótesis de medias 
iguales. Bajo la hipótesis nula, la estadística de prueba
@var{z} sigue una distribución normal estándar.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @code{mean (@var{x})
 != mean (@var{y})}. si @var{alt} es @code{">"}, la alternativa unilateral
@code{mean (@var{x}) > mean (@var{y})} es considerada. Del mismo modo para
@code{"<"}, la alternativa unilateral PROB @code{mean (@var{x}) < mean (@var{y})}
es considerada. El valor predeterminado es la alternativa bilateral.

El valor-p de el test es devuelto en @var{pval}.

Si no se da argumento de salida, el valor-p de el test es mostrado
junto con la información.
@end deftypefn 