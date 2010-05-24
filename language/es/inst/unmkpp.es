md5="d237dc17225f3081cc0038e69da530a2";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{x}, @var{p}, @var{n}, @var{k}, @var{d}] =} unmkpp (@var{pp})
Extraer los componentes de piece-wise de la estructura del polinomio 
@var{pp}.
Estos son los siguientes:

@table @asis
@item @var{x}
Ejemplos de puntos
@item @var{p}

Coeficientes del polinomio de puntos en el intervalo de la muestra.
@code{@var{p}(@var{i}, :)} contiene los coeficientes para el polinomio
en un intervalo @var{i} ordenados de mayor a menor. Si @code{@var{d} >
1}, @code{@var{p} (@var{r}, @var{i}, :)} contiene los coeficientes para
el polinomio r-ésimo definido en el intervalo @var{i}. Sin embargo,
este se almacena como un arreglo 2-D, de modo que @code{@var{c} = reshape
(@var{p} (:, @var{j}), @var{n}, @var{d})} da @code{@var{c} (@var{i}, 
@var{r})} es el j-ésimo coeficiente del polinomio r-ésimo durante
el intervalo i-ésimo.

@item @var{n}
Número de piezas de polinomio.
@item @var{k}
Orden del el polinomio más 1.
@item @var{d}
Número de polinomios definidos para cada intervalo.
@end table

@seealso{mkpp, ppval, spline}
@end deftypefn 