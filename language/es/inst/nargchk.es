md5="dace240fa2127c00813661cb0daf87ff";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} nargchk (@var{nargin_min}, @var{nargin_max}, @var{n})
Si @var{n} está en el rango desde @var{nargin_min} hasta @var{nargin_max}, 
retorna una matriz vacia. En otro caso, retorna un mensaje indicando si 
@var{n} es muy grande o muy peque@~{n}o.

Esta función es útil para verificar que el número de argumentos 
suministrados a una función se encuentra dentro de un rango aceptable.
@end deftypefn
