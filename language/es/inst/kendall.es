-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} kendall (@var{x}, @var{y})
Calcule Kendall @var{tau} para cada una de las variables especificadas
por los argumentos de entrada.

Para matrices, cada fila es una observación y cada columna una variable@'
los vectores son siempre las observaciones y puede ser vectores fila o columna.

@code{kendall (@var{x})} es equivalente a @code{kendall (@var{x},
@var{x})}.

Para dos vectores de datos @var{x}, @var{y} de longitud común @var{n},
Kendall @var{tau} es la correlación de las señales de todas las 
diferencias de rango de @var{x} y @var{y};  es decir, si ambos @var{x} y
@var{y} tiene distintas entradas, luego

@iftex
@tex
$$ \tau = {1 \over n(n-1)} \sum_{i,j} {\rm sign}(q_i-q_j) {\rm sign}(r_i-r_j) $$
@end tex
@end iftex
@ifinfo
@example
         1    
tau = -------   SUM sign (q(i) - q(j)) * sign (r(i) - r(j))
      n (n-1)   i,j
@end example
@end ifinfo

@noindent
en el que 
@iftex
@tex
$q_i$ and $r_i$
@end tex
@end iftex
@ifinfo
@var{q}(@var{i}) and @var{r}(@var{i})
@end ifinfo
son los rangos de
@var{x} y @var{y}, respectivamente.

Si @var{x} y @var{y} provienen de distribuciones independientes, 
Kendall @var{tau} es asintóticamente normal con media 0 y varianza
@iftex
@tex
${2 (2n+5) \over 9n(n-1)}$.
@end tex
@end iftex
@ifnottex
@code{(2 * (2@var{n}+5)) / (9 * @var{n} * (@var{n}-1))}.
@end ifnottex
@end deftypefn
