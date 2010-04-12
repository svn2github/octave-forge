md5="0df2e7c266cbb1ed658e6de94630478b";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{a}, @var{b}, @var{c}, @var{d}] =} zp2ss (@var{zer}, @var{pol}, @var{k})
Conversi@'on de zero/pole a espacio de estados.

@strong{Entradas}
@table @var
@item zer
@itemx pol

Vectores de los polos (posiblemente) complejos y ceros de la funci@'on de
transferencia. Valores complejos que vienen en pares conjugados (es decir,
@math{x+jy} en @var{zer} significa que @math{x-jy} también en @var{zer}).
El n@'umero de ceros no debe exceder el n@'umero de polos.

@item k
Escalar Real (primer coeficiente).
@end table

@strong{Outputs}
@table @var
@item @var{a}
@itemx @var{b}
@itemx @var{c}
@itemx @var{d}
El sistema de espacio de estado, en la forma:
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
@end table
@end deftypefn