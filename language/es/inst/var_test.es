md5="6ea6db0e5eb68afef775ac3504a3f4bf";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{f}, @var{df_num}, @var{df_den}] =} var_test (@var{x}, @var{y}, @var{alt})
Para dos muestras @var{x} y @var{y} a partir de distribuciones
normales con medias y varianzas desconocidas, realizar una prueba-F
de la hipótesis nula de varianzas iguales. Bajo la hipótesis nula,
la estadística de prueba @var{f} sigue una distribución-F con 
@var{df_num} y @var{df_den} grados de libertad.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @code{var (@var{x}) 
!= var(@var{y})}. Si @var{alt} es @code{">"}, la alternativa unilateral
@code{var (@var{x}) > var (@var{y})} es considerado. Del mismo modo para
@code{"<"}, la alternativa unilateral @code{var(@var{x}) > var (@var{y})}
es utilizada. El valor predeterminado es la alternativa bilateral.

El valor-p de la prueba es devuelto en @var{pval}.

Si no se da argumento de salida, el valor-p de la prueba es mostrado.
@end deftypefn 