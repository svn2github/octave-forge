md5="1dd116435edd8a632462737272d3f196";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{status}, @var{text}]} unix (@var{command})
@deftypefnx {Archivo de funci@'on} {[@var{status}, @var{text}]} unix (@var{command}, "-echo")
Ejecuta un comando del sistema si se est@'a corriendo un sistema operativo 
de la familia Unix, en otro caso no hace nada. Retorna el estado de salida 
del programa en @var{status} y cualquier salida enviada a la salida 
est@'ndar en @var{text}. Si se suministra el argumento opcional 
@code{"-echo"}, tambi@'en envia la salida del comando a la salida est@'andar.
@seealso{isunix, ispc, system}
@end deftypefn
