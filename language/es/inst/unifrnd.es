md5="8965d591d3e3d0d218c90d18ba384066";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} unifrnd (@var{a}, @var{b}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} unifrnd (@var{a}, @var{b}, @var{sz})
Retorna una matriz de @var{r} por @var{c} o @code{size (@var{sz})} de 
muestras aleatorias de la distribuci@'on uniforme sobre [@var{a}, @var{b}]. 
Tanto @var{a} como @var{b} deben ser escalares o de tama@~{n}o @var{r} por @var{c}.

Si se omiten @var{r} y @var{c}, el tama@~{n}o de la matriz resultante es 
el tama@~{n}o com@'un entre @var{a} y @var{b}.
@end deftypefn
