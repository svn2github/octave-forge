md5="c5b33a2451d55e42e5777c134703f138";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} clock ()
Retorna un vector que contiene el a@~{n}o, mes (1-12), día (1-31), hora
(0-23), minutos (0-59) y segundos (0-59) actual. Por ejemplo,

@example
@group
clock ()
@result{} [ 1993, 8, 20, 4, 56, 1 ]
@end group
@end example

La función clock es mas precisa en sistemas que tienen la función
@code{gettimeofday}.
@end deftypefn
