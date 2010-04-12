md5="1d2e039c49a02bf7ab238b7a242c60ea";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} rmdir (@var{dir})
@deftypefnx {Funci@'on incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} rmdir (@var{dir}, @code{"s"})
Remueve el directorio @var{dir}.

Si la ejecuaci@'on es exitosa, la variable @var{status} es 1 y cadenas de 
caracteres vacias en @var{msg} y @var{msgid}. En otro caso, @var{status} es 
0, @var{msg} contiene un mensaje de error dependiente del sistema y @var{msgid} 
contiene un identificador de mensaje @'unico.

Si se suministra el par@'ametro opcional @code{"s"}, remueve recursivamente todos 
los subdirecotorios tambi@'en.

@seealso{mkdir, confirm_recursive_rmdir}
@end deftypefn
