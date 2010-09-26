-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} getrusage ()
Devuelve una estructura que contiene una serie de estad�sticas sobre el
actual proceso de Octave. No todos los campos est�n disponibles en todos
los sistemas. Si no es posible obtener estad�sticas de tiempo de CPU,
las ranuras de tiempo de CPU se ponen a cero. Otros datos que faltan se
sustituyen por NaN . Aqu� est� una lista de todos los campos posibles
que pueden estar presentes en la estructura devuelta por
@code{getrusage}:

@table @code
@item idrss
Tama�o de datos sin compartir

@item inblock
N�mero de operaciones de entrada de bloques.

@item isrss
Tama�o de pila sin compartir.

@item ixrss
Tama�o de memoria compartida.

@item majflt
Cifras de los principales fallos de p�gina.

@item maxrss
M�ximo tama�o de los datos.

@item minflt
N�mero de menores errores de p�gina.

@item msgrcv
N�mero de mensajes recibidos.

@item msgsnd
N�mero de mensajes enviados.

@item nivcsw
N�mero de cambios de contexto involuntario.

@item nsignals
N�mero de se�ales recibidas.

@item nswap
N�mero de canjes.

@item nvcsw
N�mero de cambios de contexto voluntario.

@item oublock
N�mero de operaciones de salida por categor�as.

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
