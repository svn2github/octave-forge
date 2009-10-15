md5="ec072566f58981206c324685ca0b4a8c";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{x} =} syl (@var{a}, @var{b}, @var{c})
Resuelve la ecuaci@'on de Silvestre 
@iftex
@tex
$$
 A X + X B + C = 0
$$
@end tex
@end iftex
@ifinfo

@example
A X + X B + C = 0
@end example
@end ifinfo
usando las subrutinas est@'andar de @sc{Lapack}. Por ejemplo, 

@example
@group
syl ([1, 2; 3, 4], [5, 6; 7, 8], [9, 10; 11, 12])
     @result{} [ -0.50000, -0.66667; -0.66667, -0.50000 ]
@end group
@end example
@end deftypefn
