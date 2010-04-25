md5="52ee3eddd2061b763879792c66c6f606";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{err}, @var{msg}] =} rename (@var{old}, @var{new})
Cambia el nombre del archivo @var{old} por @var{new}.

Si la ejecución es exitosa, @var{err} es 0 y @var{msg} es una 
cadena vacia. En otro caso, @var{err} es distinto de cero y 
@var{msg} contiene un mensaje de error dependiente del sistema. 
@seealso{ls, dir}
@end deftypefn
