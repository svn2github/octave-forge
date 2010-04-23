md5="5a8dde770d73cb8751febeda44accf85";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} diff (@var{x}, @var{k}, @var{dim})
Si @var{x} es un vector de longitud @var{n}, @code{diff (@var{x})} es el 
vector de las primeras diferencias 
@iftex
@tex
 $x_2 - x_1, \ldots{}, x_n - x_{n-1}$.
@end tex
@end iftex
@ifinfo
@var{x}(2) - @var{x}(1), @dots{}, @var{x}(n) - @var{x}(n-1).
@end ifinfo

Si @var{x} es una matriz, @code{diff (@var{x})} es la matriz de 
columnas de diferencias a lo largo de la primera dimensión no 
singleton.

El segundo argumento es opcional. Si se especifica, @code{diff (@var{x},
@var{k})}, donde @var{k} es un entero no negativo, retorna las diferencias 
@var{k}-ésima. Es posible que @var{k} sea mayor que la primera dimensión 
no singleton de la matriz. En este caso, @code{diff} continua haciendo las 
diferencias a lo largo de la siguiente dimensión no singleton.

La dimensión a lo largo de la cual es toman las diferencias se puede 
especificar explícitamente con la variable opcional @var{dim}. En este caso
las diferencias de orden @var{k}-ésimo se calculan a lo largo de esta dimensión.
En el caso donde @var{k} excede @code{size (@var{x}, @var{dim})}, se retorna una 
matriz vacia.
@end deftypefn