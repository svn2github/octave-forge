md5="abec15b1bf9ce5a95766f36bd6875342";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{a}, @var{b}, @var{c}, @var{d}] =} tf2ss (@var{num}, @var{den})
Conversi@'on de la funci@'on de transferencia de estado-espacio.
El sistema de estado-espacio:
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
se obtiene de una funci@'on de transferencia:
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
El vector @var{den} debe contener s@'olo una fila, mientras que el
vector @var{num} puede contener tantas filas como salidas @var{y} 
del sistema. El sistema de matrices de estados-espacio obtenidos a
partir de esta funci@'on ser@'a en forma can@'onica controlable como
se describe en @cite{Modern Control Theory}, (Brogan, 1991).
@end deftypefn