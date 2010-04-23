md5="f57efed852e3020df67a5a61ac0dd287";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} linspace (@var{base}, @var{limit}, @var{n})
Retorna un vector con @var{n} elementos espaciados linealmente entre 
@var{base} y @var{limit}. Si el número de elementos es mayor que 1, 
se incluyen @var{base} y @var{limit} dentro del rango. Si @var{base} es 
mayor que @var{limit}, se guardan los elementos en orden descendente. Si 
no se especifica el número puntos, se usa el valor 100.

La función @code{linspace} siempre retorna un vector fila.

Por compatibilidad de con @sc{Matlab}, retorna el segundo argumento si 
se solicitan menos de dos valores.
@end deftypefn
