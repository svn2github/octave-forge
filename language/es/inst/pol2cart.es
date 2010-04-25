md5="13d6be3c30b93354bfabd733a9c3227d";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{x}, @var{y}] =} pol2cart (@var{theta}, @var{r})
@deftypefnx {Archivo de función} {[@var{x}, @var{y}, @var{z}] =} pol2cart (@var{theta}, @var{r}, @var{z})
Transforma coordenadas polares o cilíndricas en coordenadas cartesianas. 
La variables @var{theta}, @var{r} (y @var{z}) deben tener la misma forma. 
La variable @var{theta} describe el ángulo relativo al eje x. La variable 
@var{r} es la distancia al eje z (0, 0, z).
@seealso{cart2pol, cart2sph, sph2cart}
@end deftypefn
