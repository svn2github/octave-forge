md5="169534819de9a02fd5ae6448af4d60a5";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} semilogyerr (@var{args})
Produce gráficas de dos dimensiones en escala semilogarítmica con 
barras de error. Existen diferentes combinaciones de argumentos, la 
forma más usada es 

@example
semilogyerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gráfica semilogarítmica de @var{y} versus @var{x} 
con errores en la escala de @var{y} definida por @var{ey} y el formato 
definido por @var{fmt}. Véase @code{errorbar} para los formatos disponibles 
e información adicional.
@seealso{errorbar, loglogerr, semilogxerr}
@end deftypefn
