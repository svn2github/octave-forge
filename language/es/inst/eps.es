md5="27e6620b33371a5f18715be8e8f9f372";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} eps (@var{x})
@deftypefnx {Función incorporada} {} eps (@var{n}, @var{m})
@deftypefnx {Función incorporada} {} eps (@var{n}, @var{m}, @var{k}, @dots{})
@deftypefnx {Función incorporada} {} eps (@dots{}, @var{class})
Retorna la matrix o arreglo de N dimensiones cuyos elementos son todos @code{eps},
la precisión de la máquina. Más precisamente, @code{eps} es el espacio 
relativa más grande entre dos números adyacentes en el sistema de punto 
flotante de la máquina. Este número es dependiente del sistema. En 
máquinas que soportan aritmética de punto flotante de 64 bits de la IEEE, 
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