md5="3f8e8e6c17005c2d26841ab0ffbc1b33";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} fseek (@var{fid}, @var{offset}, @var{origin})
Establece el apundador del archivo en cualquier ubicación dentro del archivo @var{fid}.

El apuntador se ubica en @var{offset} caracteres apartir de @var{origin},
el cual puede ser una de las variables predefinidas @code{SEEK_CUR} (posición 
actual), @code{SEEK_SET} (inicio), o @code{SEEK_END} (fin del archivo) o 
las cadenas "cof", "bof" o "eof" respectivamente. Si se omite @var{origin}, 
se asume @code{SEEK_SET}. La variable @var{offset} debe ser cero, o un valor retornado 
por @code{ftell} (en caso de que sea @var{origin}, debe ser @code{SEEK_SET}).

Si la ejecución es exitosa, retorna 0, y -1 en caso de error.
@seealso{ftell, fopen, fclose}
@end deftypefn
