md5="8069e3c63f1e92b05ffe3a14f5fc4b7e";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} rindex (@var{s}, @var{t})
Retorna la posición de la última ocurrencia de la cadena @var{t} en la 
cadena @var{s}, o 0 no se encuentra. Por ejemplo, 

@example
rindex ("Teststring", "t")
@result{} 6
@end example

@strong{Precuación:} Esta función no funciona con arreglos de cadenas.
@seealso{find, index}
@end deftypefn
