md5="0988f83e2dfa986f84b2ae076d472c29";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{file_ids}, @var{err}, @var{msg}] =} pipe ()
Crea una segmentación y retorna el vector @var{file_ids}, el cual corresponde 
con las última posición de lectura y escritura del segmento.

Si la ejeción es exitosa, @var{err} es 0 y @var{msg} es una cadena vacia. 
En otro caso, @var{err} es distinto de cero y @var{msg} contiene un mensaje 
de error dependiente del sistema. 
@end deftypefn
