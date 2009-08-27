md5="c5b33a2451d55e42e5777c134703f138";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} clock ()
Retorna un vector que contiene el a@~{n}o, mes (1-12), d@'ia (1-31), hora
(0-23), minutos (0-59) y segundos (0-59) actual. Por ejemplo,

@example
@group
clock ()
@result{} [ 1993, 8, 20, 4, 56, 1 ]
@end group
@end example

La funci@'on clock es mas precisa en sistemas que tienen la funci@'on
@code{gettimeofday}.
@end deftypefn
