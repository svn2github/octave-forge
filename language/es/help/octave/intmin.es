md5="79404e550582cf818fcedb6a65e9526b";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} intmin (@var{type})
Retorna el entero m@'as peque@~{n}o que puede ser representado 
por una variable de tipo entero.

La variable @var{type} puede ser 

@table @code
@item int8
Entero con signo de 8 bits.
@item int16
Entero con signo de 16 bits.
@item int32
Entero con signo de 32 bits.
@item int64
Entero con signo de 64 bits.
@item uint8
Entero sin signo de 8 bits.
@item uint16
Entero sin signo de 16 bits.
@item uint32
Entero sin signo de 32 bits.
@item uint64
Entero sin signo de 64 bits.
@end table

El valor predetermiando de @var{type} es @code{uint32}.
@seealso{intmax, bitmax}
@end deftypefn
