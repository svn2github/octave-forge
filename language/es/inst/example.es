md5="0949c8ca6741a4e6ad080cc5e4073369";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} example ('@var{name}',@var{n})
@deftypefnx {Archivo de función} {[@var{x}, @var{idx}] =} example ('@var{name}',@var{n})
Muestra el código del ejemplo @var{n} asociado con la función 
'@var{name}', pero no lo ejecuta. Si no se especifica @var{n}, se 
muestran todos los ejemplos. 

Cuando se llama con argumentos de salida, se retornan los ejemplos en 
forma de cadena @var{x}, en donde @var{idx} indica la posición final 
de cada uno de los ejemplos.

Véase @code{demo} para una explicación más completa. 
@seealso{demo, test}
@end deftypefn
