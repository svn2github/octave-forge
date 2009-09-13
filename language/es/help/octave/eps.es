md5="27e6620b33371a5f18715be8e8f9f372";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} eps (@var{x})
@deftypefnx {Funci@'on incorporada} {} eps (@var{n}, @var{m})
@deftypefnx {Funci@'on incorporada} {} eps (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Funci@'on incorporada} {} eps (@dots{}, @var{class})
Retorna la matrix o arreglo de N dimensiones cuyos elementos son todos @code{eps},
la precisi@'on de la m@'aquina. M@'as precisamente, @code{eps} es el espacio 
relativa m@'as grande entre dos n@'umeros adyacentes en el sistema de punto 
flotante de la m@'aquina. Este n@'umero es dependiente del sistema. En 
m@'aquinas que soportan aritm@'etica de punto flotante de 64 bits de la IEEE, 
@code{eps} es aproximadamente 
@ifinfo
 2.2204e-16.
@end ifinfo
@iftex
@tex
 $2.2204\times10^{-16}$.
@end tex
@end iftex
@end deftypefn