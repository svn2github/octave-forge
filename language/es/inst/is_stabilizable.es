md5="e0fc2f24c75e6459540e170c37b09f44";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{retval} =} is_stabilizable (@var{sys}, @var{tol})
@deftypefnx {Archivo de funci@'on} {@var{retval} =} is_stabilizable (@var{a}, @var{b}, @var{tol}, @var{dflg})
Comprobar la l@'ogica para la estabilizaci@'on del sistema (es decir,
todos los modos inestables son controlables). Retorna 1 si el sistema
es estabilizable, 0 si el sistema no es estabilizable, -1 si el sistema
no tiene los modos estabilizables en el eje imaginario (c@'irculo 
unitario para los sistemas de tiempo discreto.

Prueba para estabilizaci@'on se realiza a trav@'es de Hautus Lema. Si
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