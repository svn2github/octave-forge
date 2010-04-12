md5="890dc1b8aedabdb2516575d3df37a38d";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} betainc (@var{x}, @var{a}, @var{b})
Retorna la funci@'on Beta incompleta,
@iftex
@tex
$$
 \beta (x, a, b) = B (a, b)^{-1} \int_0^x t^{(a-z)} (1-t)^{(b-1)} dt.
$$
@end tex
@end iftex
@ifinfo

@smallexample
                                      x
                                     /
betainc (x, a, b) = beta (a, b)^(-1) | t^(a-1) (1-t)^(b-1) dt.
                                     /
                                  t=0
@end smallexample
@end ifinfo

Si @var{x} posee mas de un componente, tanto @var{a} como @var{b} deben ser
escalares. Si @var{x} es un escalar, @var{a} y @var{b} deben ser de 
dimensiones compatibles.
@end deftypefn
