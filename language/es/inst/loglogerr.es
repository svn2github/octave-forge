md5="1da0a2efe6313ea6a971f7159b3a8fd6";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} loglogerr (@var{args})
Produce gr@'aficas de dos dimensiones en ejes logar@'itmicos dobles 
con barras de errores. Existen m@'ultiples combinaciones de par@'ametros, 
entre las m@'as usadas estan 

@example
loglogerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gr@'afica logar@'itmica doble de @var{y} en funci@'on 
de @var{x} con errores en la escala de @var{y} definidos por @var{ey} y 
el formato de la gr@'afica definido por @var{fmt}. V@'ease @code{errorbar} 
para informaci@'on acerca de los formatos y detalles adicionales.
@seealso{errorbar, semilogxerr, semilogyerr}
@end deftypefn
