md5="b3ddb15093a972c28911ee364baeb47d";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} freport ()
Imprime la lista de cúales archivos han sido abiertos, y si han sido abiertos para 
lectura, escritura o ambos. Por ejemplo,

@example
@group
freport ()

     @print{}  number  mode  name
     @print{} 
     @print{}       0     r  stdin
     @print{}       1     w  stdout
     @print{}       2     w  stderr
     @print{}       3     r  myfile
@end group
@end example
@end deftypefn
