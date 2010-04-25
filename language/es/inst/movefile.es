md5="160adf6a01fed995e0b8a6c1e477baee";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{status}, @var{msg}, @var{msgid}] =} movefile (@var{f1}, @var{f2})
Mueve el archivo @var{f1} al nombre nuevo @var{f2}. El nombre @var{f1} 
puede contener comodines. Si @var{f1} se expande en múltiples nombres de 
archivo, la variable @var{f2} debe ser un directorio. 

Si la ejecución es exitosa, el valor de @var{status} es 1, y el valor 
de @var{msg} y @var{msgid} es una cadena de caracteres vacias. En otro caso, 
la variable @var{status} es 0, @var{msg} contiene un mensaje de error 
dependiente del sistema, y @var{msgid} contiene un identificador de mensaje 
único.
@seealso{glob}
@end deftypefn
