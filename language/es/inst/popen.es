md5="a4b731ced966a8a71bed25c910864caa";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{fid} =} popen (@var{command}, @var{mode})
Iniciar un proceso y crear un enlace. El nombre del comando a ejecutar
es dado por @var{command}. El identificador de archivo correspondiente al
flujo de entrada o salida del proceso se devuelve en @var{fid}.
El argumento @var{mode} puede ser

@table @code
@item "r"
El enlace se conecta a la salida estándar del proceso, y se abre
para la lectura.

@item "w"
El enlace se conecta a la entrada estándar del proceso, y se abre
para escritura.
@end table

Por ejemplo,

@example
@group
fid = popen ("ls -ltr / | tail -3", "r");
while (isstr (s = fgets (fid)))
  fputs (stdout, s);
endwhile
     @print{} drwxr-xr-x  33 root  root  3072 Feb 15 13:28 etc
     @print{} drwxr-xr-x   3 root  root  1024 Feb 15 13:28 lib
     @print{} drwxrwxrwt  15 root  root  2048 Feb 17 14:53 tmp
@end group
@end example
@end deftypefn