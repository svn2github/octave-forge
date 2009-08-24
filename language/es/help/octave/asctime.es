md5="bf07d928d1e762e0b1e59c0083a1f568";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} asctime (@var{tm_struct})
Convierte una estructura de tipo time en una cadena de caracteres 
usando el siguiente formato de cinco campos: Jue Mar 28 08:40:14 1996.  Por ejemplo,

@example
@group
asctime (localtime (time ()))
@result{} "Lun Feb 17 01:15:06 1997\n"
@end group
@end example

Esta funci@'on es equivalente a @code{ctime (time ())}.
@end deftypefn
