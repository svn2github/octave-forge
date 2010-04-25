md5="1da0a2efe6313ea6a971f7159b3a8fd6";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} loglogerr (@var{args})
Produce gráficas de dos dimensiones en ejes logarítmicos dobles 
con barras de errores. Existen múltiples combinaciones de parámetros, 
entre las más usadas estan 

@example
loglogerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gráfica logarítmica doble de @var{y} en función 
de @var{x} con errores en la escala de @var{y} definidos por @var{ey} y 
el formato de la gráfica definido por @var{fmt}. Véase @code{errorbar} 
para información acerca de los formatos y detalles adicionales.
@seealso{errorbar, semilogxerr, semilogyerr}
@end deftypefn
