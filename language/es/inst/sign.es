md5="3546a7c797255db5894b0019caaf49db";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} sign (@var{x})
Calcula la funci@'on @dfn{signum}, la cual se define como 
@iftex
@tex
$$
{\rm sign} (@var{x}) = \cases{1,&$x>0$;\cr 0,&$x=0$;\cr -1,&$x<0$.\cr}
$$
@end tex
@end iftex
@ifinfo

@example
           -1, x < 0;
sign (x) =  0, x = 0;
            1, x > 0.
@end example
@end ifinfo

Para argumentos complejos, la funci@'on @code{sign} retorna 
@code{x ./ abs (@var{x})}.
@end deftypefn
