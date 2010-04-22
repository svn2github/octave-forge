md5="3630cec0eb91d05685d2284a76299ffb";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{a} =} arrayfun (@var{name}, @var{c})
@deftypefnx {Archivo de función} {@var{a} =} arrayfun (@var{func}, @var{c})
@deftypefnx {Archivo de función} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{d})
@deftypefnx {Archivo de función} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{options})
@deftypefnx {Archivo de función} {[@var{a}, @var{b}, @dots{}] =} arrayfun (@var{func}, @var{c}, @dots{})
Ejecuta una función en cada elemento de un arreglo. Ésta es until para
funciones que no aceptan arreglos como argumentos. Si la función acepta 
arreglos como agumentos, es mejor llamar la función directamente.

Véase @code{cellfun} para instrucciones completas acerca de su uso.
@seealso{cellfun}
@end deftypefn
