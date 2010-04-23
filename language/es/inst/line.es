md5="e9ecd3cf57b286c93dd03ca6f649799a";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} line ()
@deftypefnx {Archivo de función} {} line (@var{x}, @var{y})
@deftypefnx {Archivo de función} {} line (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {} line (@var{x}, @var{y}, @var{z}, @var{property}, @var{value}, @dots{})
Crea un objeto línea entre @var{x} y @var{y} y lo inserta en el 
eje actual. Retorna un apuntador (o vector de apuntadores) a los 
objetos línea creados.

Se pueden especificar múltiples parejas de propiedades para una línea, 
pero siempre deben aparecer en pares.
@end deftypefn
