md5="7bc153a003629616cbf8d485ebff964d";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} wblrnd (@var{scale}, @var{shape}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} wblrnd (@var{scale}, @var{shape}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestras aleatorias de la 
distribuci@'on Weibull con par@'ametros de escala @var{scale} y  de 
forma @var{shape}, los cuales deben ser escalares o de tama@~{n}o @var{r} 
por @var{c}. Si @var{sz} es un vector, retorna una matriz de tama@~{n}o 
@var{sz}.

Si se omiten @var{r} y @var{c}, se usa el tama@~{n}o com@'un de 
@var{alpha} y @var{sigma}.
@end deftypefn
