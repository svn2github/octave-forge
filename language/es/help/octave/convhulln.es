md5="4011d62ea42c0eb1ba145e586628b18e";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{H} =} convhulln (@var{p})
@deftypefnx {Funci@'on cargable} {@var{H} =} convhulln (@var{p}, @var{opt})
Retorna un vector de @'indices de los puntos de la envoltura convexa.
La matriz de entrada de tama@~{n}o [n, dim] contiene @var{n} pontos de dimensi@'on @var{dim}.

Si se suministra el segundo argumento, este debe ser un cadena o un arreglo con las 
opciones para el subyacente comando qhull (v@'ease la documentaci@'on de Qhull para las opciones disponibles). Las opciones predeterminadas son "s Qci Tcv".

@seealso{convhull, delaunayn}
@end deftypefn
