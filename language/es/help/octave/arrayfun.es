md5="3630cec0eb91d05685d2284a76299ffb";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{a} =} arrayfun (@var{name}, @var{c})
@deftypefnx {Archivo de funci@'on} {@var{a} =} arrayfun (@var{func}, @var{c})
@deftypefnx {Archivo de funci@'on} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{d})
@deftypefnx {Archivo de funci@'on} {@var{a} =} arrayfun (@var{func}, @var{c}, @var{options})
@deftypefnx {Archivo de funci@'on} {[@var{a}, @var{b}, @dots{}] =} arrayfun (@var{func}, @var{c}, @dots{})
Ejecuta una funci@'on en cada elemento de un arreglo. @'Esta es until para
funciones que no aceptan arreglos como argumentos. Si la funci@'on acepta 
arreglos como agumentos, es mejor llamar la funci@'on directamente.

V@'ease @code{cellfun} para instrucciones completas acerca de su uso.
@seealso{cellfun}
@end deftypefn
