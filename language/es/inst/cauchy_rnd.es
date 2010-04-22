md5="2d4b61fd0b0e988c2c957bcdd4acb631";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cauchy_rnd (@var{lambda}, @var{sigma}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} cauchy_rnd (@var{lambda}, @var{sigma}, @var{sz})
Retorna una matriz @var{r} por @var{c} o @code{size (@var{sz})} de 
muestras aleatorias a partir de una distribution de Cauchy con
parámetros @var{lambda} y @var{sigma} los cuales deben ser ambos
escalares o de tama@~{n}o @var{r} por @var{c}.

Si @var{r} y @var{c} se omiten, el tama@~{n}o de la matriz resultante 
es el tama@~{n}o común entre @var{lambda} y @var{sigma}.
@end deftypefn
