md5="7f8cce3d42d2543570cb6d723bcada3c";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{err}, @var{msg}] =} link (@var{old}, @var{new})
Crea un enlace nuevo (también conocido como enlace fuerte) a un 
archivo existente. 

Si la ejecución es exitosa, @var{err} es 0 y @var{msg} es una cadena vacia. 
En otro caso, @var{err} es distinto de cero y @var{msg} contiene un mensaje 
de error dependiente del sistema.
@seealso{symlink}
@end deftypefn
