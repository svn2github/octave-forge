md5="9ab67c9a1696b28107be9a14029ad2b6";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} realmax (@var{x})
@deftypefnx {Función incorporada} {} realmax (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} realmax (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Función incorporada} {} realmax (@dots{}, @var{class})

Retorna una matriz o arreglo de N dimensiones cuyos elementos son todos iguales 
al número de punto flotante más grande que es representable. El valor 
real es dependiente del sistema. En máquinas que soportan aritmética de punto 
flotante de 64 bits de IEEE, @code{realmax} es aproximadamente 

@ifinfo
 1.7977e+308
@end ifinfo

@iftex
@tex
 $1.7977\times10^{308}$.
@end tex
@end iftex

@seealso{realmin}
@end deftypefn
