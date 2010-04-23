md5="e0fc2f24c75e6459540e170c37b09f44";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{retval} =} is_stabilizable (@var{sys}, @var{tol})
@deftypefnx {Archivo de función} {@var{retval} =} is_stabilizable (@var{a}, @var{b}, @var{tol}, @var{dflg})
Comprobar la lógica para la estabilización del sistema (es decir,
todos los modos inestables son controlables). Retorna 1 si el sistema
es estabilizable, 0 si el sistema no es estabilizable, -1 si el sistema
no tiene los modos estabilizables en el eje imaginario (círculo 
unitario para los sistemas de tiempo discreto.

Prueba para estabilización se realiza a través de Hautus Lema. Si
@iftex
@tex
@var{dflg}$\neq$0
@end tex
@end iftex
@ifinfo 
@var{dflg}!=0
@end ifinfo
asumir que las matrices de tiempo-discreto (a, b) son suministradas.
@seealso{size, rows, columns, length, ismatrix, isscalar, isvector
is_observable, is_stabilizable, is_detectable}
@end deftypefn