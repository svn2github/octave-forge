md5="241ed57431677ec5b1af366f91806186";rev="5951";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{H} =} convhull (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {@var{H} =} convhull (@var{x}, @var{y}, @var{opt})
Retorna el vector de @'indices de los puntos de la envoltura convexa. Los 
putos se definen por los vectores @var{x} y @var{y}.

Un tercer argumento opcional, el cual debe ser una cadena, contiene opciones adicionales
que se pasan al comando subyacente qhull. Para infomaci@'on adicional, v@'ease la documentaci@'on de la libreria Qhull.
@seealso{delaunay, convhulln}
@end deftypefn
