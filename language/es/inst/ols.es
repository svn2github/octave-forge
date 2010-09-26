-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{beta}, @var{sigma}, @var{r}] =} ols (@var{y}, @var{x})
mínimos cuadrados ordinarios de estimación para el modelo multivariado
@iftex
@tex
$y = x b + e$
con
$\bar{e} = 0$, y cov(vec($e$)) = kron ($s, I$)
@end tex
@end iftex
@ifinfo
@math{y = x b + e} con
@math{mean (e) = 0} y @math{cov (vec (e)) = kron (s, I)}.
@end ifinfo
 donde
@iftex
@tex
$y$ es un $t \veces p$ matriz, $x$ es un $t \veces k$ matriz,
$b$ es un $k \veces p$ matriz, y $e$ es un $t \veces p$ matriz.
@end tex
@end iftex
@ifinfo
@math{y} es una matriz @math{t} por @math{p}, @math{x} es una matriz
@math{t} por @math{k} , @math{b} es una matriz @math{k} por @math{p}, y
@math{e} es una matriz @math{t} por @math{p} .
@end ifinfo

cada fila de @var{y} y @var{x} es una observación y cada columna una
variable.

Los valores devueltos @var{beta}, @var{sigma}, y @var{r} son definidos como
los siguientes.

@table @var
@item beta
El estimador de OLS para @var{b}, @code{@var{beta} = pinv (@var{x}) *
@var{y}}, donde @code{pinv (@var{x})} denota la seudoinversa de
@var{x}.

@item sigma
Los estimadores OLS para la matriz @var{s},

@example
@group
@var{sigma} = (@var{y}-@var{x}*@var{beta})'
  * (@var{y}-@var{x}*@var{beta})
  / (@var{t}-rank(@var{x}))
@end group
@end example

@item r
La matriz de residuos OLS, @code{@var{r} = @var{y} - @var{x} *
@var{beta}}.
@end table
@end deftypefn
