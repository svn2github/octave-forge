md5="7d17b58deed4bc57bbcdf3b610ca1b76";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} findstr (@var{s}, @var{t}, @var{overlap})
Retorna el vector con todas las posiciones donde la cadena m@'as corta aparece en 
la m@'as larga. Si el argumento opcional @var{overlap} es distinto de cero, el 
vector retornado puede incluir posiciones  que se superponen (predeterminado). 
Por ejemplo, 

@example
findstr ("ababab", "a")
@result{} [ 1, 3, 5 ]
findstr ("abababa", "aba", 0)
@result{} [ 1, 5 ]
@end example
@end deftypefn
