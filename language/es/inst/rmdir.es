md5="1d2e039c49a02bf7ab238b7a242c60ea";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} rmdir (@var{dir})
@deftypefnx {Función incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} rmdir (@var{dir}, @code{"s"})
Remueve el directorio @var{dir}.

Si la ejecuación es exitosa, la variable @var{status} es 1 y cadenas de 
caracteres vacias en @var{msg} y @var{msgid}. En otro caso, @var{status} es 
0, @var{msg} contiene un mensaje de error dependiente del sistema y @var{msgid} 
contiene un identificador de mensaje único.

Si se suministra el parámetro opcional @code{"s"}, remueve recursivamente todos 
los subdirecotorios también.

@seealso{mkdir, confirm_recursive_rmdir}
@end deftypefn
