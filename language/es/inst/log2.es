md5="23ce2a58d800ea07c18ea5121e1af26c";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} log2 (@var{x})
@deftypefnx {Funci@'on de mapeo} {[@var{f}, @var{e}] =} log2 (@var{x})
Calcula el logaritmo en base 2 de @var{x}. Con dos salidas, retorna 
@var{f} y @var{e} tales que 
@iftex
@tex
 $1/2 <= |f| < 1$ and $x = f \cdot 2^e$.
@end tex
@end iftex
@ifinfo
 1/2 <= abs(f) < 1 and x = f * 2^e.
@end ifinfo
@seealso{log, log10, logspace, exp}
@end deftypefn
