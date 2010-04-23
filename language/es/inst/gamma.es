md5="b6a9a5e3371e8fbf85ca6969875324c2";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} gamma (@var{z})
Calcula la función Gamma, definida como 
@iftex
@tex
$$
 \Gamma (z) = \int_0^\infty t^{z-1} e^{-t} dt.
$$
@end tex
@end iftex
@ifinfo

@example
            infinity
            /
gamma (z) = | t^(z-1) exp (-t) dt.
            /
         t=0
@end example
@end ifinfo
@seealso{gammai, lgamma}
@end deftypefn
