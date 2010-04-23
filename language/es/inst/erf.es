md5="aaddf887d691990d9fb74290f307da25";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} erf (@var{z})
Calcula la función de error,
@iftex
@tex
$$
 {\rm erf} (z) = {2 \over \sqrt{\pi}}\int_0^z e^{-t^2} dt
$$
@end tex
@end iftex
@ifinfo

@smallexample
                         z
                        /
erf (z) = (2/sqrt (pi)) | e^(-t^2) dt
                        /
                     t=0
@end smallexample
@end ifinfo
@seealso{erfc, erfinv}
@end deftypefn
