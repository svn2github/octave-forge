md5="47a653e9c3b9dc45c842df36759a2658";rev="7199";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} abs (@var{z})
Calcula la magnitud de @var{z}, definida como
@iftex
@tex
$|z| = \sqrt{x^2 + y^2}$.
@end tex
@end iftex
@ifinfo
|@var{z}| = @code{sqrt (x^2 + y^2)}.
@end ifinfo

Por ejemplo,

@example
@group
abs (3 + 4i)
     @result{} 5
@end group
@end example
@end deftypefn
