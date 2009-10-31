md5="865165141b5741f8d04bbfbe6ceff34b";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} semilogxerr (@var{args})
Produce gr@'aficas de dos dimensiones en escala semilogar@'itmica con 
barras de error. Existen diferentes combinaciones de par@'ametros, la 
forma m@'as usada es 

@example
semilogxerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gr@'afica semilogar@'itmica de @var{y} versus @var{x} 
con errores en el eje @var{y} definidos por @var{ey} y el formato definido 
en @var{fmt}. V@'ease @code{errorbar} para los formatos disponibles e 
informaci@'on adicional.
@seealso{errorbar, loglogerr, semilogyerr}
@end deftypefn
