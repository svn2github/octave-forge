md5="5413c421a90de29f0b567a7efc2d9f50";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} roots (@var{v})
Para un vector @var{v} con @math{N} componentes, regresa
las ra@'ices del polinomio.
@iftex
@tex
$$
v_1 z^{N-1} + \cdots + v_{N-1} z + v_N.
$$
@end tex
@end iftex
@ifnottex

@example
v(1) * z^(N-1) + ... + v(N-1) * z + v(N)
@end example
@end ifnottex

Como ejemplo, el siguiente c@'odigo encuentra las ra@'ices del
polinomio de segundo grado.
@iftex
@tex
$$ p(x) = x^2 - 5. $$
@end tex
@end iftex
@ifnottex
@example
p(x) = x^2 - 5.
@end example
@end ifnottex
@example
c = [1, 0, -5];
roots(c)
@result{}  2.2361
@result{} -2.2361
@end example
Note que el resultado verdadero es
@iftex
@tex
$\pm \sqrt{5}$
@end tex
@end iftex
@ifnottex
@math{+/- sqrt(5)}
@end ifnottex
que es aproximadamente
@iftex
@tex
$\pm 2.2361$.
@end tex
@end iftex
@ifnottex
@math{+/- 2.2361}.
@end ifnottex
@seealso{compan}
@end deftypefn