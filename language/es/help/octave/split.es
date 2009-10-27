md5="13bb11a5ab673c82baf8d741850f3135";rev="6405";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} split (@var{s}, @var{t}, @var{n})
Divide la cadena @var{s} en partes separadas por @var{t}, retornando 
el resultado en un arreglo cadena (emparejado con espacios en blanco 
hasta completar una mastriz v@'alida). Si se suministra el par@'ametro 
opcional @var{n}, divide @var{s} en m@'aximo @var{n} partes difentes.

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
