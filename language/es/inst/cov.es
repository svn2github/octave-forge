md5="230381431041ea45bff6f5d1315607db";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cov (@var{x}, @var{y})
Calcula la covariaza.

Si cada fila de @var{x} y @var{y} es una observación y cada columna es 
una variable, la (@var{i}, @var{j})-ésima entrada de 
@code{cov (@var{x}, @var{y})} es la covarianza entre la @var{i}-ésima
variable en @var{x} y la @var{j}-ésima variable en @var{y}.
@iftex
@tex
$$
\sigma_{ij} = {1 \over N-1} \sum_{i=1}^N (x_i - \bar{x})(y_i - \bar{y})
$$
donde $\bar{x}$ y $\bar{y}$ son los valores medios de $x$ y $y$.
@end tex
@end iftex
Si se llama con un argumento, calcula @code{cov (@var{x}, @var{x})}.
@end deftypefn
