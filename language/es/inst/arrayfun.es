md5="3630cec0eb91d05685d2284a76299ffb";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci�n} {@var{a} =} arrayfun (@var{name}, @var{c})
@deftypefnx {Archivo de funci�n} {@var{a} =} arrayfun (@var{func}, @var{c})
@deftypefnx {Archivo de funci�n} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{d})
@deftypefnx {Archivo de funci�n} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{options})
@deftypefnx {Archivo de funci�n} {[@var{a}, @var{b}, @dots{}] =} arrayfun (@var{func}, @var{c}, @dots{})
Ejecuta una funci�n en cada elemento de un arreglo. �sta es until para
funciones que no aceptan arreglos como argumentos. Si la funci�n acepta 
arreglos como agumentos, es mejor llamar la funci�n directamente.

V�ase @code{cellfun} para instrucciones completas acerca de su uso.
@seealso{cellfun}
@end deftypefn
