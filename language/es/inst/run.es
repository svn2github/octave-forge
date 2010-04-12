md5="7e827cb82e797616c1385410574be9a6";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} run (@var{f})
@deftypefnx {Comando} {} run @var{f}
Ejecuta los scripts en el espacio de trabajo actual que no est@'an 
necesariamente en la ruta. Si @var{f} es el script a ser ejecutado, 
incluyendo su ruta, @code{run} cambia al directorio donde se encuentra
@var{f}. @code{run} entonces ejecuta el script, y retorna al directorio 
original.
@seealso{system}
@end deftypefn
