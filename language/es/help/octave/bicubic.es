md5="e29ad5e4b2de3b8affa2d3b121d3c4cf";rev="5711";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{zi}=} bicubic (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{extrapval})

Retorna una matriz @var{zi} correspondiente a las interpolaciones
bic@'ubicas en @var{xi} y @var{yi} de los datos suministrados
@var{x}, @var{y} y @var{z}. Los puntos afuera de la malla son 
establecidos en @var{extrapval}

V@'ease @url{http://wiki.woodpecker.org.cn/moin/Octave/Bicubic}
para informaci@'on adicional.
@seealso{interp2}
@end deftypefn
