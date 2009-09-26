md5="8662d3c481a67a9d3173d076828ab19a";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fliplr (@var{x})
Retorna una copia de @var{x} con el orden inverso de columnas. 
Por ejemplo,

@example
@group
fliplr ([1, 2; 3, 4])
@result{}  2  1
         4  3
@end group
@end example

N@'otese que @code{fliplr} solo funciona con arregloe de dos dimensiones. Para 
transformar arreglos de N dimensiones, use @code{flipdim}.
@seealso{flipud, flipdim, rot90, rotdim}
@end deftypefn
