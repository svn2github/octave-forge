md5="e23132fb8dd9c42585c81a8622cef4ea";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{y}, @var{x}] =} lsim (@var{sys}, @var{u}, @var{t}, @var{x0})
Produce una salida para una simulaci@'on de un sistema lineal produce
un gr@'afica para la salida del sistema, @var{sys}.

@var{u} es una matriz que contiene las entradas del sistema. Cada fila de
@var{u} corresponde a un paso de tiempo diferente. Cada columna de @var{u}
a una diferente entrada. @var{t} es un arreglo que contiene el indice de
tiempo del sistema; @var{t} deber@'ia ser regularmente espaciada. Si se 
requieren condiciones iniciales en el sistema, el vector @var{x0} puede ser
agregado a la ista de argumentos.

Cuando la funci@'on lsim es invocada una gr@'afica no se muestra;
sin embargo, los datos son devueltos en @var{y} (sistema de salida)
y @var{x} (system estados).
@end deftypefn