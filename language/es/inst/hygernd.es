md5="0da891e78f719e2c4f77f5cd8fd09863";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hygernd (@var{t}, @var{m}, @var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} hygernd (@var{t}, @var{m}, @var{n}, @var{sz})
@deftypefnx {Archivo de función} {} hygernd (@var{t}, @var{m}, @var{n})
Regresa una matriz @var{r} por una @var{c} de muestras aletorias de la 
distribucion hypergeometric con parametros @var{t}, @var{m}, y @var{n}.

Los parámetros @var{t}, @var{m}, y @var{n} deben ser enteros positivos
con @var{m} y @var{n} no mayor que @var{t}.

Los parametros @var{sz} deben ser un escalar o un vector de dimensiones
de matriz. Si @var{sz} es un escalar, entonces @var{sz} por @var{sz} 
genera una matriz de muestras aleatorias.
@end deftypefn
  