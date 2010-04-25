md5="bdeae73d5a9dc925c98defead7016d71";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} realmin (@var{x})
@deftypefnx {Función incorporada} {} realmin (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} realmin (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Función incorporada} {} realmin (@dots{}, @var{class})

Retorna una matriz o arreglo de N dimensiones cuyos elementos son todos iguales 
al número de punto flotante más peque@~{n}o que es representable. El valor 
real es dependiente del sistema. En máquinas que soportan aritmética de punto 
flotante de 64 bits de IEEE, @code{realmin} es aproximadamente 

@ifinfo
 2.2251e-308
@end ifinfo

@iftex
@tex
 $2.2251\times10^{-308}$.
@end tex
@end iftex

@seealso{realmax}
@end deftypefn
