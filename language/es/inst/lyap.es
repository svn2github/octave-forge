-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} lyap (@var{a}, @var{b}, @var{c})
@deftypefnx {Archivo de funci@'on} {} lyap (@var{a}, @var{b})
Resuelva el Lyapunov (o Sylvester) a través de la ecuación del
algoritmo Bartels-Stewart (Comunicaciones del @acronym{ACM}, 1972).

Si @var{a}, @var{b}, y @var{c} son especificadas, entonces @code{lyap} 
retorna la solucion del la ecuación de Sylvester
@iftex
@tex
  $$ A X + X B + C = 0 $$
@end tex
@end iftex
@ifinfo
@example
    a x + x b + c = 0
@end example
@end ifinfo
Si solo @code{(a, b)} son especificadas, entonces @command{lyap} retorna
la solución de la ecuación de Lyapunov
@iftex
@tex
  $$ A^T X + X A + B = 0 $$
@end tex
@end iftex
@ifinfo
@example
    a' x + x a + b = 0
@end example
@end ifinfo
Si @var{b} no es cuadrada, entonces @code{lyap} retorna la solucion de
cualquiera de las
@iftex
@tex
  $$ A^T X + X A + B^T B = 0 $$
@end tex
@end iftex
@ifinfo
@example
    a' x + x a + b' b = 0
@end example
@end ifinfo
@noindent
o
@iftex
@tex
  $$ A X + X A^T + B B^T = 0 $$
@end tex
@end iftex
@ifinfo
@example
    a x + x a' + b b' = 0
@end example
@end ifinfo
@noindent
según sea el caso.

Resuelve utilizando el algorimo Bartels-Stewart (1972).
@end deftypefn
