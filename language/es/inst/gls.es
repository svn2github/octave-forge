-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{beta}, @var{v}, @var{r}] =} gls (@var{y}, @var{x}, @var{o})
mínimos cuadrados generalizada de estimación para el modelo multivariado
@iftex
@tex
$y = x b + e$
con $\bar{e} = 0$ y cov(vec($e$)) = $(s^2)o$,
@end tex
@end iftex
@ifinfo
@math{y = x b + e} con @math{mean (e) = 0} y
@math{cov (vec (e)) = (s^2) o},
@end ifinfo
 donde
@iftex
@tex
$y$ es una $t \times p$ matriz, $x$ es una $t \times k$ matriz, $b$ es una $k
\times p$ matriz, $e$ es una $t \times p$ matriz, y $o$ es una $tp \times
tp$ matriz.
@end tex
@end iftex
@ifinfo
@math{y} es una @math{t} por @math{p} matriz, @math{x} es una @math{t} por
@math{k} matriz, @math{b} es una @math{k} by @math{p} matriz, @math{e}
es una @math{t} por @math{p} matriz, y @math por{o} es una @math{t p} por
@math{t p} matriz.
@end ifinfo

@noindent
Cada fila de @var{y} y @var{x} es una observación y cada columna una
variable. Los valores de retorno @var{beta}, @var{v}, and @var{r} se
definen como sigue.

@table @var
@item beta
El estimador de GLS para @math{b}.

@item v
El estimador de GLS para @math{s^2}.

@item r
La matriz de GLS  residuos, @math{r = y - x beta}.
@end table
@end deftypefn
