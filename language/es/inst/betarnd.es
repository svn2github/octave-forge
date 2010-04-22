md5="51247d99e55aa11791b96d894dfead8a";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} betarnd (@var{a}, @var{b}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} betarnd (@var{a}, @var{b}, @var{sz})
Retorna una matrix de @var{r} por @var{c} o @code{size (@var{sz})} 
con muestras aleatorias de una distribución Beta con parámetros @var{a} y
@var{b}. Tanto @var{a} como @var{b} deben ser escalares o de tamaño
@var{r} por @var{c}.

Si @var{r} y @var{c} son omitidos, el tamaño de la matriz resultante es
la dimensión común entre @var{a} y @var{b}.
@end deftypefn
