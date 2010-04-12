md5="e7f07b5b413ec75e8a49108c85abb9a3";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} splice (@var{list_1}, @var{offset}, @var{length}, @var{list_2})
Reemplaza @var{length} elementos de @var{list_1} comenzando en 
@var{offset} con el contenido de @var{list_2} (si existe). Si se 
omite @var{length}, se reemplazan todos los elementos de @var{offset} 
al final de @var{list_1}. Como caso especial, si @var{offset} es mayor 
que la longitud de @var{list_1} y @var{length} es 0, @code{splice} 
es equivalente a @code{append (@var{list_1}, @var{list_2})}.
@end deftypefn
