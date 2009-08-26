md5="83b6a54cd147a48da93869e2cb5dae56";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} binornd (@var{n}, @var{p}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} binornd (@var{n}, @var{p}, @var{sz})
Retorna una matriz de @var{r} por @var{c}  o @code{size (@var{sz})} de
muestras aleatorias de la distribuci@'on Binomial con par@'ametros 
@var{n} y @var{p}. Tanto @var{n} como @var{p} deben ser escalares o
de dimensiones @var{r} por @var{c}.

Si @var{r} y @var{c} son omitidos, las dimensiones de la matriz
resultante son las dimensiones comunes entre @var{n} y @var{p}.
@end deftypefn
