md5="1dd116435edd8a632462737272d3f196";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{status}, @var{text}]} unix (@var{command})
@deftypefnx {Archivo de función} {[@var{status}, @var{text}]} unix (@var{command}, "-echo")
Ejecuta un comando del sistema si se está corriendo un sistema operativo 
de la familia Unix, en otro caso no hace nada. Retorna el estado de salida 
del programa en @var{status} y cualquier salida enviada a la salida 
est@'ndar en @var{text}. Si se suministra el argumento opcional 
@code{"-echo"}, también envia la salida del comando a la salida estándar.
@seealso{isunix, ispc, system}
@end deftypefn
