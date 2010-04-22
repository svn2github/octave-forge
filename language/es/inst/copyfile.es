md5="a05dc2614388e4b49dc88db063e376f1";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{status}, @var{msg}, @var{msgid}] =} copyfile (@var{f1}, @var{f2}, @var{force})
Copia el archivo @var{f1} al nombre nuevo @var{f2}. El nombre @var{f1}
puede contener comodines. Si @var{f1} coincide con múltiples nombres de archivos, 
@var{f2} debe ser un directorio. Si se suministra @var{force} igual a la cadena "f" 
el comando de copiaado será forzado.

Si es exitoso, @var{status} es 1, @var{msg} y @var{msgid} contienen una cadena de 
caracteres vacia.  De otra forma, @var{status} es 0, @var{msg} contiene un
mensaje de error dependiente del sistema, y @var{msgid} contiene un identificador de 
mensaje único.
@seealso{glob, movefile}
@end deftypefn
