md5="9ab67c9a1696b28107be9a14029ad2b6";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} realmax (@var{x})
@deftypefnx {Funci@'on incorporada} {} realmax (@var{n}, @var{m})
@deftypefnx {Funci@'on incorporada} {} realmax (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Funci@'on incorporada} {} realmax (@dots{}, @var{class})

Retorna una matriz o arreglo de N dimensiones cuyos elementos son todos iguales 
al n@'umero de punto flotante m@'as grande que es representable. El valor 
real es dependiente del sistema. En m@'aquinas que soportan aritm@'etica de punto 
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
