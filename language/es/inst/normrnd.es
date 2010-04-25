md5="b6d19e3725f38cab8c1cd7e42667e27b";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} normrnd (@var{m}, @var{s}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} normrnd (@var{m}, @var{s}, @var{sz})
Retorna una matriz de @var{r} por @var{c}  o @code{size (@var{sz})} de 
muestras aleatorias de la distribuciób normal con media @var{m} 
y desviación estándar @var{s}. Tanto @var{m} como @var{s} deben ser 
escalares o de tama@~{n}o @var{r} por @var{c}.

Si se omiten @var{r} y @var{c}, el tama@~{n}o de la matriz resultaten es 
el tama@~{n}o común entre @var{m} y @var{s}.
@end deftypefn
