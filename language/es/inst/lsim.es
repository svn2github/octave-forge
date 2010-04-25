md5="e23132fb8dd9c42585c81a8622cef4ea";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{y}, @var{x}] =} lsim (@var{sys}, @var{u}, @var{t}, @var{x0})
Produce una salida para una simulación de un sistema lineal produce
un gráfica para la salida del sistema, @var{sys}.

@var{u} es una matriz que contiene las entradas del sistema. Cada fila de
@var{u} corresponde a un paso de tiempo diferente. Cada columna de @var{u}
a una diferente entrada. @var{t} es un arreglo que contiene el indice de
tiempo del sistema; @var{t} debería ser regularmente espaciada. Si se 
requieren condiciones iniciales en el sistema, el vector @var{x0} puede ser
agregado a la ista de argumentos.

Cuando la función lsim es invocada una gráfica no se muestra;
sin embargo, los datos son devueltos en @var{y} (sistema de salida)
y @var{x} (system estados).
@end deftypefn