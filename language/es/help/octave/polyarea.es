md5="2920b7d3ab2a4d3799452b85b3426431";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} polyarea (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {} polyarea (@var{x}, @var{y}, @var{dim})
Determina el @'area de un pol@'igono mediante el m@'etodo del tr@'iangulo. 
Las variables @var{x} y @var{y} definen las parejas de v@'ertices, y por 
lo tanto deben tener la misma forma. Estos pueden ser vectores o arreglos. 
Si son arreglos, las columnas de @var{x} y @var{y} son tratadas 
separadamente y se retorna un @'area para cada una.

Si se suministra el argumento opcional @var{dim}, @code{polyarea} 
calcula el @'area a lo largo de esta dimensi@'on de los arreglos 
@var{x} y @var{y}.
@end deftypefn
