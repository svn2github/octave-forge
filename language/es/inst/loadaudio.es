md5="1d529e5cdd7a563543b21a8922ec00f1";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} loadaudio (@var{name}, @var{ext}, @var{bps})
Carga los datos de audio del archivo @file{@var{name}.@var{ext}} en 
el vector @var{x}.

La extensi@'on @var{ext} determina como se interpretan los datos en el 
archivo de audio; las extensiones @file{lin} (predeterminado) y @file{raw} 
corresponden a codificaci@'on lineal; las extensiones @file{au}, @file{mu}, 
o @file{snd} a codificaci@'on mu-law.

El argumento @var{bps} puede ser 8 (predeterminado) o 16, y especifica 
el n@'umero de bits por muestra usados en el archivo de audio.
@seealso{lin2mu, mu2lin, saveaudio, playaudio, setaudio, record}
@end deftypefn
