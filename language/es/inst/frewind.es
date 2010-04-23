md5="fcedbb6fc9ec51a004ac6a856c2f9692";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} frewind (@var{fid})
Mueve el apuntador al inicio del archivo @var{fid}, retornado 
0 si la operación es exitosa, y -1 se hubo alg@'n error. Esta función 
es equivalente a @code{fseek (@var{fid}, 0, SEEK_SET)}.
@end deftypefn
