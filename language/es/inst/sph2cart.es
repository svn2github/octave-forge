md5="ef5c1faf900f3fb08573301d81d9bf98";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{x}, @var{y}, @var{z}] =} sph2cart (@var{theta}, @var{phi}, @var{r})
Transforma las coordenadas esféricas en cartesianas. Las variables 
@var{x}, @var{y} y @var{z} deben tener la misma forma. La variable 
@var{theta} describe el ángulo relativo al eje @code{x}. La variable 
@var{phi} es el ángulo relativo al plano @code{xy}. La variable 
@var{r} es la distancia al origen @code{(0, 0, 0)}.
@seealso{pol2cart, cart2pol, cart2sph}
@end deftypefn
