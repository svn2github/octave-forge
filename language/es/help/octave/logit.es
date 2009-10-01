md5="8b32a555de1102491ba32fcc98d56e02";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} logit (@var{p})
Para cada componente de @var{p}, retorna el logit de @var{p} definido 
como 
@iftex
@tex
$$
{\rm logit}(p) = \log\Big({p \over 1-p}\Big)
$$
@end tex
@end iftex
@ifnottex
@example
logit(@var{p}) = log (@var{p} / (1-@var{p}))
@end example
@end ifnottex
@end deftypefn
