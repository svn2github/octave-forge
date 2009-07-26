md5="230381431041ea45bff6f5d1315607db";rev="5962";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cov (@var{x}, @var{y})
Calcula la covariaza.

Si cada fila de @var{x} y @var{y} es una observaci@'on y cada columna es 
una variable, la (@var{i}, @var{j})-@'esima entrada de 
@code{cov (@var{x}, @var{y})} es la covarianza entre la @var{i}-@'esima
variable en @var{x} y la @var{j}-@'esima variable en @var{y}.
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
