md5="fdb25057d85c0d03ee1b992f8ffe3580";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} ord2 (@var{nfreq}, @var{damp}, @var{gain})
Crea un sistema continuo de 2do orden con par@'ametros:

@strong{Entradas}
@table @var
@item nfreq
frequencia natural [Hz]. (no en rad/s)
@item damp
coeficiente de amortiguamiento
@item gain
dc-gain
Est@'e es el valor de la constante de estado s@'olo para 
damp > 0. gain se asume que es 1.0 si se omite.

@end table

@strong{Salidas}
@table @var
@item outsys
Estructura de datos del sistema tiene la representaci@'on con
@ifinfo
@math{w = 2 * pi * nfreq}:
@end ifinfo
@iftex
@tex
$ w = 2  \pi  f $:
@end tex
@end iftex
@example
@group
    /                                        \
    | / -2w*damp -w \  / w \                 |
G = | |             |, |   |, [ 0  gain ], 0 |
    | \   w       0 /  \ 0 /                 |
    \                                        /
@end group
@end example
@end table
@strong{See also} @command{jet707} (@acronym{MIMO} example, Boeing 707-321
aircraft model)
@end deftypefn 