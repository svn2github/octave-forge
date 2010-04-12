md5="51247d99e55aa11791b96d894dfead8a";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} betarnd (@var{a}, @var{b}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} betarnd (@var{a}, @var{b}, @var{sz})
Retorna una matrix de @var{r} por @var{c} o @code{size (@var{sz})} 
con muestras aleatorias de una distribuci@'on Beta con par@'ametros @var{a} y
@var{b}. Tanto @var{a} como @var{b} deben ser escalares o de tama@~no
@var{r} por @var{c}.

Si @var{r} y @var{c} son omitidos, el tama@~no de la matriz resultante es
la dimensi@'on com@'un entre @var{a} y @var{b}.
@end deftypefn
