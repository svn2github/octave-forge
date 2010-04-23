md5="6e15c51928bd03e4f9e739efb7d6eff5";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{status}, @var{text}] =} dos (@var{command})
@deftypefnx {Archivo de función} {[@var{status}, @var{text}] =} dos (@var{command}, "-echo")
Ejecuta un comando del sistema si se ejecuta bajo sistemas operativos de 
la famila de Windows, en otro caso no hace nada. Retorna el estado de 
salida del programa en la variable @var{status} y cualquier salida enviada  
a la salia estándar en @var{text}. Si se suministra el segundo argumento 
opcional @code{"-echo"}, también envia la salida del comando a la salida 
estándar.
@seealso{unix, isunix, ispc, system}
@end deftypefn
