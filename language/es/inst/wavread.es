md5="38676740e924468ad2084efec1e29d25";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{y} =} wavread (@var{filename})
Cargue el archivo de sonido RIFF/WAVE @var{filename}, y el retorno de
las muestras en el vector @var{y}. Si el archivo contiene datos de multi
canal, entonces, @var{y} es una matriz con los canales representados 
como columnas.

@deftypefnx {Archivo de función} {[@var{y}, @var{Fs}, @var{bits}] =} wavread (@var{filename})
Adicionalmente devuelve la frecuencia de muestreo (@var{fs}) en Hz y el
número de bits por muestra (@var{bits}).

@deftypefnx {Archivo de función} {[@dots{}] =} wavread (@var{filename}, @var{n})
Lee sólo las primeras @var{n} muestras de cada canal.

@deftypefnx {Archivo de función} {[@dots{}] =} wavread (@var{filename},[@var{n1} @var{n2}])
Lee sólo las muestras desde @var{n1} hasta @var{n2} de cada canal.

@deftypefnx {Archivo de función} {[@var{samples}, @var{channels}] =} wavread (@var{filename}, "size")
Devuelve el númeto de muestras (@var{n}) y canales (@var{ch})
en lugar de  los datos de audio.
@seealso{wavwrite}
@end deftypefn 