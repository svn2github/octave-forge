md5="78b46117139272f8626244a31620b613";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} gammainc (@var{x}, @var{a})
Calcule la normalizada de la funci@'on incompleta gamma,

@iftex
@tex
$$
 \gamma (x, a) = {\displaystyle\int_0^x e^{-t} t^{a-1} dt \over \Gamma (a)}
$$
@end tex
@end iftex
@ifinfo

@smallexample
                                x
                      1        /
gammainc (x, a) = ---------    | exp (-t) t^(a-1) dt
                  gamma (a)    /
                            t=0
@end smallexample

@end ifinfo
con el valor l@'imite de 1 @var{x} tiende a infinito.
La notaci@'on est@'andar es @math{P(a,x)}, por ejemplo
Abramowitz y Stegun (6.5.1).

Si @var{a} es escalar, entonces @code{gammainc (@var{x}, @var{a})} regresa
para cada elemento de @var{x} y vice versa

Si ninguno @var{x} o @var{a} es escalar, el tama@~{n}o de @var{x} y
@var{a} debe coincidir, y @var{gammainc} se aplican elemento por elemento.
@seealso{gamma, lgamma}
@end deftypefn