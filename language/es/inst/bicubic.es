md5="e29ad5e4b2de3b8affa2d3b121d3c4cf";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{zi}=} bicubic (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{extrapval})

Retorna una matriz @var{zi} correspondiente a las interpolaciones
bicúbicas en @var{xi} y @var{yi} de los datos suministrados
@var{x}, @var{y} y @var{z}. Los puntos afuera de la malla son 
establecidos en @var{extrapval}

Véase @url{http://wiki.woodpecker.org.cn/moin/Octave/Bicubic}
para información adicional.
@seealso{interp2}
@end deftypefn
