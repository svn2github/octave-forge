md5="dadc44bc354c2a4dfe8eca4b172bd4a4";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} ls options
Lista el contenido de un directorio. Por ejemplo, 

@example
ls -l
@print{} total 12
@print{} -rw-r--r--   1 jwe  users  4488 Aug 19 04:02 foo.m
@print{} -rw-r--r--   1 jwe  users  1315 Aug 17 23:14 bar.m
@end example

Los comandos @code{dir} y @code{ls} son implementados mediante un llamado 
al comando del sistema usado para listar archivos, esto implica que las 
opciones pueden variar entre sistemas.
@seealso{dir, stat, readdir, glob, filesep, ls_command}
@end deffn
