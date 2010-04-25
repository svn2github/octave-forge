md5="a96884f03efbe215b5c84a5b5be09133";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} saveaudio (@var{name}, @var{x}, @var{ext}, @var{bps})
Guarda el vector de datos de audio @var{x} en el archivo @file{@var{name}.@var{ext}}. 
Los parámetros @var{ext} y @var{bps} determinan la codificación y el número de 
bits por muestra usados en el archivo de audio (véase @code{loadaudio});  los 
valores predetermiandos son @file{lin} y 8, respectivamente.
@seealso{lin2mu, mu2lin, loadaudio, playaudio, setaudio, record}
@end deftypefn
