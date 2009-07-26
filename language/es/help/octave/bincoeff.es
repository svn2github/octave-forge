md5="49494ecc0001bfef93827e572c1412e7";rev="5715";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} bincoeff (@var{n}, @var{k})
Retorna el coeficiente binomial de @var{n} y @var{k}, definido como
@iftex
@tex
$$
 {n \choose k} = {n (n-1) (n-2) \cdots (n-k+1) \over k!}
$$
@end tex
@end iftex
@ifinfo

@example
@group
 /   \
 | n |    n (n-1) (n-2) ... (n-k+1)
 |   |  = -------------------------
 | k |               k!
 \   /
@end group
@end example
@end ifinfo

Por ejemplo,

@example
@group
bincoeff (5, 2)
@result{} 10
@end group
@end example
@end deftypefn
