-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{K}, @var{gain}, @var{kc}, @var{kf}, @var{pc}, @var{pf}] = } h2syn (@var{asys}, @var{nu}, @var{ny}, @var{tol})
Diseña 
@iftex
@tex
$ { \cal H }_2 $
@end tex
@end iftex
@ifinfo
H-2
@end ifinfo
control óptimo en cada procedimiento
Doyle, Glover, Khargonekar, Francis, @cite{State-Space Solutions to Standard}
@iftex
@tex
$ { \cal H }_2 $ @cite{and} $ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
@cite{H-2 and H-infinity}
@end ifinfo
@cite{Control Problems}, @acronym{IEEE} @acronym{TAC} August 1989.

Tiempo discreto de control por Zhou, Doyle, and Glover, @cite{Robust and optimal control}, Prentice-Hall, 1996.

@strong{Inputs}
@table @var
@item asys
estructura del sistema de datos (see ss, sys2ss)
@itemize @bullet
@item controlador que se aplica a los sistemas de tiempo continuo 
@item controlador es @strong{not} implementado para sistemas de tiempo discreto
@end itemize
@item nu
número de entradas controladas
@item ny
número de productos medidos
@item tol
umbral de 0. Por defecto: 200*@code{eps}
@end table

@strong{Outputs}
@table @var
@item    k
controlador del sistema
@item    gain
ganancia óptima de circuito cerrado
@item    kc
completo control de la información (empaquetado)
@item    kf
estimador de estado (packed)
@item    pc
@acronym{ARE} solution matrix for regulator subproblem
@item    pf
@acronym{ARE} solución de filtro de matriz para el subproblema
@end table
@end deftypefn
