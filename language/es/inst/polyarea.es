md5="2920b7d3ab2a4d3799452b85b3426431";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} polyarea (@var{x}, @var{y})
@deftypefnx {Archivo de función} {} polyarea (@var{x}, @var{y}, @var{dim})
Determina el área de un polígono mediante el método del tríangulo. 
Las variables @var{x} y @var{y} definen las parejas de vértices, y por 
lo tanto deben tener la misma forma. Estos pueden ser vectores o arreglos. 
Si son arreglos, las columnas de @var{x} y @var{y} son tratadas 
separadamente y se retorna un área para cada una.

Si se suministra el argumento opcional @var{dim}, @code{polyarea} 
calcula el área a lo largo de esta dimensión de los arreglos 
@var{x} y @var{y}.
@end deftypefn
