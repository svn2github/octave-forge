-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} peaks ()
@deftypefnx {Archivo de funci@'on} {} peaks (@var{n})
@deftypefnx {Archivo de funci@'on} {} peaks (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {@var{z} =} peaks (@dots{})
@deftypefnx {Archivo de funci@'on} {[@var{x}, @var{y}, @var{z}] =} peaks (@dots{})
Generar una función con una gran cantidad de máximos y mínimos locales.
La función tiene la forma

@iftex
@tex
$f(x,y) = 3 (1 - x) ^ 2 e ^ {\left(-x^2 - (y+1)^2\right)} - 10 \left({x \over 5} - x^3 - y^5)\right) - {1 \over 3} e^{\left(-(x+1)^2 - y^2\right)}$
@end tex
@end iftex
@ifnottex
@verbatim
f(x,y) = 3*(1-x)^2*exp(-x^2 - (y+1)^2) ...
         - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ...
         - 1/3*exp(-(x+1)^2 - y^2)
@end verbatim
@end ifnottex

Llamado sin un argumento de retorno, @code{peaks} gráica de la superficie
de la función anterior usando @code{mesh}.																																							 Si @ var (n) es un escalar, el código @ () picos devuelve los valores de la función anterior en un @ var (n) por @ var (n) de malla en el rango de @ code ([-3,3 ]). El valor predeterminado de @ var (n) es 49.
Called without a return argument,  plots the surface of the 
above function using  If @var{n} is a scalar, the @code{peaks}
returns the values of the above function on a @var{n}-by-@var{n} mesh over
the range @code{[-3,3]}. The default value for @var{n} is 49.

If @var{n} is a vector, then it represents the @var{x} and @var{y} values
of the grid on which to calculate the above function. The @var{x} and 
@var{y} values can be specified separately.
@seealso{surf, mesh, meshgrid}
@end deftypefn
