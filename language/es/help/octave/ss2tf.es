md5="5b4e6a6b1d1e13f81babde87cee8a97c";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{num}, @var{den}] =} ss2tf (@var{a}, @var{b}, @var{c}, @var{d})

Convierte un espacio de estados en funci@'on de transferencia. 

El sistema de espacios de estados: 

@iftex
@tex
$$ \dot x = Ax + Bu $$
$$ y = Cx + Du $$
@end tex
@end iftex
@ifinfo
@example
      .
      x = Ax + Bu
      y = Cx + Du
@end example
@end ifinfo

es convertido en la funci@'on de transferencia: 
@iftex
@tex
$$ G(s) = { { \rm num }(s) \over { \rm den }(s) } $$
@end tex
@end iftex
@ifinfo
@example

                num(s)
          G(s)=-------
                den(s)
@end example
@end ifinfo

Esta funci@'on es usada internamente para las manipulaciones de 
formato de las estructuras de datos de sistemas.
@end deftypefn
