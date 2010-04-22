md5="4011d62ea42c0eb1ba145e586628b18e";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{H} =} convhulln (@var{p})
@deftypefnx {Función cargable} {@var{H} =} convhulln (@var{p}, @var{opt})
Retorna un vector de índices de los puntos de la envoltura convexa.
La matriz de entrada de tama@~{n}o [n, dim] contiene @var{n} pontos de dimensión @var{dim}.

Si se suministra el segundo argumento, este debe ser un cadena o un arreglo con las 
opciones para el subyacente comando qhull (véase la documentación de Qhull para las opciones disponibles). Las opciones predeterminadas son "s Qci Tcv".

@seealso{convhull, delaunayn}
@end deftypefn
