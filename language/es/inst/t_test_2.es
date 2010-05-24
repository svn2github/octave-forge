md5="65ac96e8b2293c25a097a8c87972475d";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{t}, @var{df}] =} t_test_2 (@var{x}, @var{y}, @var{alt})
Para dos muestras x e y a partir de distribuciones normales con medias
y varianzas iguales desconocidas, realizar una prueba-t de dos muestras
de la hipótesis nula de medias iguales. Bajo la hipótesis nula, la
estadística de prueba @var{t} sigue una distribución de Student con
@var{df} grados de libertad.

Con el argumento de cadena opcional @var{alt}, la alternativa de interés
pueden ser seleccionada. Si @var{alt} es @code{"!="} o @code{"<>"}, null
es la prueba en contra de la alternativa bilateral @code{mean (@var{x}) 
!= mean (@var{y})}. Si @var{alt} es @code{">"}, la alternativa unilateral
@code{mean (@var{x}) > @var{m}} es considerado. Del mismo modo para @code{"<"},
la alternativa unilateral @code{mean (@var{x}) > mean (@var{y})} es usada.
El valor predeterminado es la alternativa bilateral.

El valor-p de la prueba se devuelve en @var{pval}.

Si no se da ningún argumento de salida, se muestra el valor-p de la
prueba.
@end deftypefn 