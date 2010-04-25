md5="865165141b5741f8d04bbfbe6ceff34b";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} semilogxerr (@var{args})
Produce gráficas de dos dimensiones en escala semilogarítmica con 
barras de error. Existen diferentes combinaciones de parámetros, la 
forma más usada es 

@example
semilogxerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gráfica semilogarítmica de @var{y} versus @var{x} 
con errores en el eje @var{y} definidos por @var{ey} y el formato definido 
en @var{fmt}. Véase @code{errorbar} para los formatos disponibles e 
información adicional.
@seealso{errorbar, loglogerr, semilogyerr}
@end deftypefn
