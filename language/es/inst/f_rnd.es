md5="9f6390462572ad32b52c1970a2485447";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} f_rnd (@var{m}, @var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} f_rnd (@var{m}, @var{n}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestras aleatorias de la 
distribuci@'on f con @var{m} y @var{n} grados de libertad. Tanto 
@var{m} como @var{n} deben ser escalares o de tama@~{n}o @var{r} por @var{c}.
Si @var{sz} es un vector, las muestras aleatorias deben ser una matriz de 
tama@~{n}o @var{sz}.

Si se omite @var{r} y @var{c}, el tama@~{n}o de la matriz resultante es 
el tama@~{n}o com@'un de @var{m} y @var{n}.
@end deftypefn
