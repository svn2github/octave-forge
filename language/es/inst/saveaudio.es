md5="a96884f03efbe215b5c84a5b5be09133";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} saveaudio (@var{name}, @var{x}, @var{ext}, @var{bps})
Guarda el vector de datos de audio @var{x} en el archivo @file{@var{name}.@var{ext}}. 
Los par@'ametros @var{ext} y @var{bps} determinan la codificaci@'on y el n@'umero de 
bits por muestra usados en el archivo de audio (v@'ease @code{loadaudio});  los 
valores predetermiandos son @file{lin} y 8, respectivamente.
@seealso{lin2mu, mu2lin, loadaudio, playaudio, setaudio, record}
@end deftypefn
