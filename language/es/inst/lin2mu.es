md5="d6d12e1c3a59c034ab6962b5101aa913";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} lin2mu (@var{x}, @var{n})
Convierte datos de audio lineales en mu-law.  Los valores Mu-law usan 
enteros sin signo de 8 bits. Los valores lineales usan enteros sin 
signo de @var{n} bits o valores de punto flotante dentro del rango 
@code{-1<=@var{x}<=1} si @var{n} es 0. Si no se especifica @var{n}, 
su valor predetermiando es 0, 8 o 16 dependiendo en el rango de los 
valores en @var{x}.
@seealso{mu2lin, loadaudio, saveaudio, playaudio, setaudio, record}
@end deftypefn
