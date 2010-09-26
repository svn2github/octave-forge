-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{x}, @var{obj}, @var{info}, @var{lambda}] =} qp (@var{x0}, @var{H}, @var{q}, @var{A}, @var{b}, @var{lb}, @var{ub}, @var{A_lb}, @var{A_in}, @var{A_ub})
Resuelva el programa cuadrático
@iftex
@tex
$$
 \min_x {1 \over 2} x^T H x + x^T q
$$
@end tex
@end iftex
@ifnottex

@example
     min 0.5 x'*H*x + x'*q
      x
@end example

@end ifnottex
sujeto a
@iftex
@tex
$$
 Ax = b \qquad lb \leq x \leq ub \qquad A_{lb} \leq A_{in} \leq A_{ub}
$$
@end tex
@end iftex
@ifnottex

@example
     A*x = b
     lb <= x <= ub
     A_lb <= A_in*x <= A_ub
@end example
@end ifnottex

@noindent
usando el método space-null active-set.
using a null-space active-set method.

Límitada(@var{A}, @var{b}, @var{lb}, @var{ub}, @var{A_lb},
@var{A_ub}) puede ser establecida a la matriz vacía (@code{[]})
si no está presente. Si la conjetura inicial es factible el algoritmo
es más rápido.

El valor @var{info} es una estructura con los siguientes campos:
@table @code
@item solveiter
El número de iteraciones necesarias para encontrar la solución.
@item info
Un entero que indica el estado de la solución, de la siguiente manera:
@table @asis
@item 0
El problema es factible y convexo. Solución global encontrado.
@item 1
El problema no es convexo. solución local encontrada.
@item 2
El problema no es convexo y sin límites.
@item 3
El número máximo de iteraciones alcanzado.
@item 6
El problema es no factible.
@end table
@end table
@end deftypefn
