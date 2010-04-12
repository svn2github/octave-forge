md5="0958bac87fd6679f4ae855f56a01c65a";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} mkdir (@var{dir})
@deftypefnx {Funci@'on incorporada} {[@var{status}, @var{msg}, @var{msgid}] =} mkdir (@var{parent}, @var{dir})
Crea un directorio llamado @var{dir}.

Si la ejecuci@'on es exitosa, la variable @var{status} es 1, @var{msg} y 
@var{msgid} cadenas de caracteres vacias. En otro caso, @var{status} es 0, 
@var{msg} contiene un mensaje de error dependiente del sistema y @var{msgid} 
contiene un identificador de mensaje @'unico.
@seealso{rmdir}
@end deftypefn
