md5="13bb11a5ab673c82baf8d741850f3135";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} split (@var{s}, @var{t}, @var{n})
Divide la cadena @var{s} en partes separadas por @var{t}, retornando 
el resultado en un arreglo cadena (emparejado con espacios en blanco 
hasta completar una mastriz válida). Si se suministra el parámetro 
opcional @var{n}, divide @var{s} en máximo @var{n} partes difentes.

Por ejemplo, 

@example
split ("Test string", "t")
@result{} "Tes "
        " s  "
        "ring"
@end example

@example
split ("Test string", "t", 2)
@result{} "Tes    "
        " string"
@end example
@end deftypefn
