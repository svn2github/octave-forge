-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} getrusage ()
Devuelve una estructura que contiene una serie de estadísticas sobre el
actual proceso de Octave. No todos los campos están disponibles en todos
los sistemas. Si no es posible obtener estadísticas de tiempo de CPU,
las ranuras de tiempo de CPU se ponen a cero. Otros datos que faltan se
sustituyen por NaN . Aquí está una lista de todos los campos posibles
que pueden estar presentes en la estructura devuelta por
@code{getrusage}:

@table @code
@item idrss
Tamaño de datos sin compartir

@item inblock
Número de operaciones de entrada de bloques.

@item isrss
Tamaño de pila sin compartir.

@item ixrss
Tamaño de memoria compartida.

@item majflt
Cifras de los principales fallos de página.

@item maxrss
Máximo tamaño de los datos.

@item minflt
Número de menores errores de página.

@item msgrcv
Número de mensajes recibidos.

@item msgsnd
Número de mensajes enviados.

@item nivcsw
Número de cambios de contexto involuntario.

@item nsignals
Número de señales recibidas.

@item nswap
Número de canjes.

@item nvcsw
Número de cambios de contexto voluntario.

@item oublock
Número de operaciones de salida por categorías.

@item stime
Una estructura que contiene la hora del sistema de CPU usado. La 
estructura cuenta con los elementos @code{sec} (segundo) @code{usec}
(microsegundos).

@item utime
Una estructura que contiene la hora del sistema de CPU usado. La 
estructura cuenta con los elementos @code{sec} (segundo) @code{usec}
(microsegundos).
@end table
@end deftypefn
