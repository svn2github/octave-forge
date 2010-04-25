md5="04d9478b5ea702ed41c7670064d86841";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sysgettype (@var{sys})
Retorna el tipo del sistema inicial del sistema 

@strong{Entrada}
@table @var
@item sys
Estructura de datos del sistema.
@end table

@strong{Salida}
@table @var
@item systype
Cadena indicando como fue construida la estructura inicialmente. Los valores 
pueden ser: @code{"ss"}, @code{"zp"}, o @code{"tf"}.
@end table

Para sistemas inicializados @acronym{FIR} retorna @code{systype="tf"}.
@end deftypefn
