md5="110f78e4d7e99881ee7c7f5a43c835a3";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{uts}, @var{err}, @var{msg}] =} uname ()
Retorna la información del sistema en una estructura. Por ejemplo, 

@example
@group
uname ()
     @result{} @{
           sysname = x86_64
           nodename = segfault
           release = 2.6.15-1-amd64-k8-smp
           version = Linux
           machine = #2 SMP Thu Feb 23 04:57:49 UTC 2006
         @}
@end group
@end example

Si la ejecución es exitosa, la variable @var{err} es 0 y @var{msg} es 
una cadena vacia. En otro caso, @var{err} es distinto de cero y @var{msg} 
contiene un mensaje de error dependiente del sistema.
@end deftypefn
