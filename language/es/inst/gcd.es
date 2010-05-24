md5="826b7226a1917f51611e429cdf5bf7b0";rev="7332";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{g} =} gcd (@var{a1}, @code{...})
@deftypefnx {Función cargable} {[@var{g}, @var{v1}, @var{...}] =} gcd (@var{a1}, @code{...})

Si un solo argumento se da a continuación, calcular el máximo común 
divisor de los elementos de este argumento. De lo contrario, si más
de un argumento se da todos los argumentos deben ser del mismo tamaño
o escalar. En este caso el máximo común divisor se calcula para el 
elemento de forma individual. Todos los elementos deben ser enteros.
Por ejemplo,

@example
@group
gcd ([15, 20])
    @result{}  5
@end group
@end example

@noindent
y

@example
@group
gcd ([15, 9], [20 18])
    @result{}  5  9
@end group
@end example

Los argumentos opcionales de retorno @var{v1}, etc, contienen vectores 
enteros de manera que,

@ifinfo
@example
@var{g} = @var{v1} .* @var{a1} + @var{v2} .* @var{a2} + @var{...}
@end example
@end ifinfo
@iftex
@tex
$g = v_1 a_1 + v_2 a_2 + \cdots$
@end tex
@end iftex

Para mantener la compatiability con versiones anteriores de esta función,
cuando todos los argumentos son escalares, un argumento declaración 
individual @var{v1} contiene todos los valores de @var{v1}, @var{...} es 
aceptable.
@seealso{lcm, min, max, ceil, floor}
@end deftypefn
