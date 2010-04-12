md5="169534819de9a02fd5ae6448af4d60a5";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} semilogyerr (@var{args})
Produce gr@'aficas de dos dimensiones en escala semilogar@'itmica con 
barras de error. Existen diferentes combinaciones de argumentos, la 
forma m@'as usada es 

@example
semilogyerr (@var{x}, @var{y}, @var{ey}, @var{fmt})
@end example

@noindent
la cual produce una gr@'afica semilogar@'itmica de @var{y} versus @var{x} 
con errores en la escala de @var{y} definida por @var{ey} y el formato 
definido por @var{fmt}. V@'ease @code{errorbar} para los formatos disponibles 
e informaci@'on adicional.
@seealso{errorbar, loglogerr, semilogxerr}
@end deftypefn
