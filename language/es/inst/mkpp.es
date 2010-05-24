md5="41c287e63916a474610a18d212d9ddca";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{pp} = } mkpp (@var{x}, @var{p})
@deftypefnx {Archivo de función} {@var{pp} = } mkpp (@var{x}, @var{p}, @var{d})

Construir una estructura de polinomio piece-wise de puntos de muestreo
@var{x} y los coeficientes @var{p}. La i-ésima fila de @var{p}, 
@code{@var{p} (@var{i},:)}, contiene los coeficientes para el polinomio en el
@var{i}-ésimo intervalo, ordenados de mayor a menor. Debe haber una fila
para cada intervalo en @var{x}, de modo que @code{rows (@var{p}) == 
length (@var{x}) - 1}.

Usted puede concatenar polinomios múltiples del mismo orden que
en el mismo conjunto de intervalos usando @code{@var{p} = [ @var{p1}; @var{p2}; 
@dots{}; @var{pd} ]}.  En este caso, @code{rows (@var{p}) == @var{d} 
* (length (@var{x}) - 1)}.

@var{d} especifica la forma de la matriz @var{p} para todos excepto
la última dimensión. Si @var{d} no se especifica, se calculará
como @code{round (rows (@var{p}) / (length (@var{x}) - 1))} en su lugar.

@seealso{unmkpp, ppval, spline}
@end deftypefn
