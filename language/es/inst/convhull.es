md5="241ed57431677ec5b1af366f91806186";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{H} =} convhull (@var{x}, @var{y})
@deftypefnx {Archivo de función} {@var{H} =} convhull (@var{x}, @var{y}, @var{opt})
Retorna el vector de índices de los puntos de la envoltura convexa. Los 
putos se definen por los vectores @var{x} y @var{y}.

Un tercer argumento opcional, el cual debe ser una cadena, contiene opciones adicionales
que se pasan al comando subyacente qhull. Para infomación adicional, véase la documentación de la libreria Qhull.
@seealso{delaunay, convhulln}
@end deftypefn
