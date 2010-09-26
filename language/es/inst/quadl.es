-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{q} =} quadl (@var{f}, @var{a}, @var{b})
@deftypefnx {Archivo de funci@'on} {@var{q} =} quadl (@var{f}, @var{a}, @var{b}, @var{tol})
@deftypefnx {Archivo de funci@'on} {@var{q} =} quadl (@var{f}, @var{a}, @var{b}, @var{tol}, @var{trace})
@deftypefnx {Archivo de funci@'on} {@var{q} =} quadl (@var{f}, @var{a}, @var{b}, @var{tol}, @var{trace}, @var{p1}, @var{p2}, @dots{})
Numéricamente evaluar la integral usando la adaptación de la regla
Lobatto. @code{quadl (@var{f}, @var{a}, @var{b})} se aproxima a la
integral de @code{@var{f}(@var{x})} a la máquina. @var{f} es una  
función miembro, función en línea o cadena que contiene el nombre de
la función a evaluar. La función @var{f} debe devolver un vector de 
valores de salida si se le da un vector de valores de entrada.

Si se define, @var{tol} define la tolerancia relativa a la que la 
integración @code{@var{f}(@var{x})}. Mientras que si @var{trace} 
se define, muestra el punto extremo izquierdo del intervalo actual,
el intervalo de longitud, y la integral parcial .

Otros argumentos @var{p1}, etc, se pasan directamente al @var{f}.
Para utilizar los valores predeterminados para @var{tol} y @var{trace},
se puede pasar matrices vacías.

Reference: W. Gander and W. Gautschi, 'Adaptive Quadrature - 
Revisited', BIT Vol. 40, No. 1, March 2000, pp. 84--101.
@url{http://www.inf.ethz.ch/personal/gander/}

@end deftypefn
