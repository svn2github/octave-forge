md5="82603d19225b09996b80a37c5e4aa230";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} ctime (@var{t})
Convierte un valor retornado @code{time} (o cualquier otro entero 
no negativo), al tiempo actual y retorna una cadena con el mismo formato de 
@code{asctime}. La funci@'on @code{ctime (time)} es equivalente a
@code{asctime (localtime (time))}. Por ejemplo,

@example
@group
ctime (time ())
@result{} "Mon Feb 17 01:15:06 1997\n"
@end group
@end example
@end deftypefn
