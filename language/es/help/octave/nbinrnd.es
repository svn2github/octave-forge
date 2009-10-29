md5="0e94ebb945a28424d2c45667f9525482";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} nbinrnd (@var{n}, @var{p}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} nbinrnd (@var{n}, @var{p}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestras aleatorias de la 
distribuci@'on de Pascal (binomial negativa) con par@'ametros @var{n} 
y @var{p}. Tanto @var{n} como @var{p} deben ser escalares o de tama@~{n}o 
@var{r} por @var{c}.

Si se omiten @var{r} y @var{c}, el tama@~{n}o de la matriz resultante 
es el tama@~{n}o com@'un de @var{n} y @var{p}. O si @var{sz} es un vector, 
crea una matriz de tama@~{n}o @var{sz}.
@end deftypefn
