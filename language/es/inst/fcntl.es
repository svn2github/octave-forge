md5="9dfc76e55d6c25d724bce97f0ced1676";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{err}, @var{msg}] =} fcntl (@var{fid}, @var{request}, @var{arg})
Cambia las propiedades del archivo abierto @var{fid}. Los siguientes valores 
se pueden pasar como @var{request}: 

@vtable @code
@item F_DUPFD
Retorna un duplicado del descriptor del archivo.

@item F_GETFD
Retorna los indicadores del descriptor del archivo @var{fid}.

@item F_SETFD
Establece los indicadores del descriptor del archivo @var{fid}.

@item F_GETFL
Retorna los indicadores de estado de archivo para @var{fid}. Los siguientes 
códigos pueden ser reotornados (algunos de los indicadores pueden no estar 
definidos en algunos sistemas).

@vtable @code
@item O_RDONLY
Abierto para solo lectura.

@item O_WRONLY
Abierto para solo escritura.

@item O_RDWR
Abierto para lectura y escritura.

@item O_APPEND
A@~{n}adido en cada escritura.

@item O_CREAT
Crea un archivo si no existe.

@item O_NONBLOCK
Modo de no bloqueo.

@item O_SYNC
Espera mientras se completa la escritura.

@item O_ASYNC
Entrada/Salida asíncrona.
@end vtable

@item F_SETFL
Establece los indicadores de estado de archivo @var{fid} al valor especificado por 
@var{arg}. El único indicador que puede ser cambiado es @code{O_APPEND} y 
@code{O_NONBLOCK}.
@end vtable

Si la ejecución es exitosa, @var{err} es 0 y @var{msg} es una cadena vacia.
En otro caso, @var{err} es diferente de cero y @var{msg} contiene un mensaje 
de error dependiente del sistema.
@end deftypefn
