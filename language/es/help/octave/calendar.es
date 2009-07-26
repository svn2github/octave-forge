md5="c47c5ec7313695b835b8ed0dadfa8511";rev="5835";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} calendar (@dots{})
@deftypefnx {Archivo de funci@'on} {@var{c} =} calendar ()
@deftypefnx {Archivo de funci@'on} {@var{c} =} calendar (@var{d})
@deftypefnx {Archivo de funci@'on} {@var{c} =} calendar (@var{y}, @var{m})
Si es llamado sin argumentos, retorna el calendario mensual actual en
una matriz de 6x7.

Si @var{d} se especifica, retorna el calendario para el mes que 
contiene el dia @var{d}, el cual debe ser una n@'umero de fecha serial
o una cadena de fecha.

Si @var{y} y @var{m} se especifican, retorna el calendario para el a@~
{n}o @var{y} y el mes @var{m}.

Si no se especifican argumentos de salida, imprime el calendario en 
la pantalla en lugar de retornar una matriz.
@seealso{datenum}
@end deftypefn
