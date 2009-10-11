md5="fc59de0d52c261cb87f45e9a581cf387";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} mu2lin (@var{x}, @var{bps})
Convierte datos de audio lineales en mu-law. Los valores mu-law son enteros 
sin signo de  8-bits. Los valores lineales usan enteros sin signo de 
@var{n}-bits o valores de punto flotante en el rango @code{-1<=y<=1} si 
@var{n} es 0. Si no es especificado @var{n}, se valor predetermiando es 8.
@seealso{lin2mu, loadaudio, saveaudio, playaudio, setaudio, record}
@end deftypefn
