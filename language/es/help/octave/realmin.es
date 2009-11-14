md5="bdeae73d5a9dc925c98defead7016d71";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} realmin (@var{x})
@deftypefnx {Funci@'on incorporada} {} realmin (@var{n}, @var{m})
@deftypefnx {Funci@'on incorporada} {} realmin (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Funci@'on incorporada} {} realmin (@dots{}, @var{class})

Retorna una matriz o arreglo de N dimensiones cuyos elementos son todos iguales 
al n@'umero de punto flotante m@'as peque@~{n}o que es representable. El valor 
real es dependiente del sistema. En m@'aquinas que soportan aritm@'etica de punto 
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
