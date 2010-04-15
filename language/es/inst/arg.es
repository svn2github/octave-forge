md5="6f370f19768f5cc033d23c1843ef1ff1";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} arg (@var{z})
@deftypefnx {Función de mapeo} {} angle (@var{z})
Calcula el argumento de @var{z}, definido como
@iftex
@tex
$\theta = \tan^{-1}(y/x)$.
@end tex
@end iftex
@ifinfo
@var{theta} = @code{atan (@var{y}/@var{x})}.
@end ifinfo
@noindent
en radianes. 

Por ejemplo,

@example
@group
arg (3 + 4i)
     @result{} 0.92730
@end group
@end example
@end deftypefn
