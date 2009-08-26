md5="ae5f70a6c5661e90532890a1355cc4b0";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} betaln (@var{a}, @var{b})
Retorna el logaritmo natural de la funci@'on Beta,
@iftex
@tex
$$
 B (a, b) = \log {\Gamma (a) \Gamma (b) \over \Gamma (a + b)}.
$$
@end tex
@end iftex
@ifinfo

@example
betaln (a, b) = gammaln (a) + gammaln (b) - gammaln (a + b)
@end example
@end ifinfo
@seealso{beta, betai, gammaln}
@end deftypefn
