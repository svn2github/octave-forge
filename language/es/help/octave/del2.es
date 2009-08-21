md5="1fa2b12ee5efd782fab4efdf13a5aa1d";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{d} =} del2 (@var{m})
@deftypefnx {Archivo de funci@'on} {@var{d} =} del2 (@var{m}, @var{h})
@deftypefnx {Archivo de funci@'on} {@var{d} =} del2 (@var{m}, @var{dx}, @var{dy}, @dots{})

Calcula el operador discrete de Laplace. Si @var{m} es una matriz, el operador se 
define como

@iftex
@tex
$d = {1 \over 4} \left( {d^2 \over dx^2} M(x,y) + {d^2 \over dy^2} M(x,y) \right)$
@end tex
@end iftex
@ifnottex
@example
@group
      1    / d^2            d^2         \
D  = --- * | ---  M(x,y) +  ---  M(x,y) | 
      4    \ dx^2           dy^2        /
@end group
@end example
@end ifnottex

El anterior exemplo se extiende a arrglos de N-dimensiones calculando la segunda 
derivada sobre las dimensiones superiores.

El espacio entre puntos de evaluaci@'on puede ser definido por @var{h}, el 
cual es un escalar que define el espaciamiento en todas las dimensiones. O 
alternativamente, el espaciamiento en cada dimensi@'on puede ser definido 
separadamente por @var{dx}, @var{dy}, etc. 
Los valores de espaciamiento escalar produces espaciamiento equidistante, 
mientras que valores de espaciamiento vectorial pueden ser usados para 
especificar especiamiento variable. La longitud de los vectores debe coincidir 
con la respectiva dimensi@'on de @var{m}. El valor predetermiando de espaciamiento 
es 1.

Se necesitan de por lo menos 3 puntos en para cada dimensi@'on. Los puntos de frontera
son calculados como extrapolaci@'on lineal de los puntos interiores.

@seealso{gradient, diff}
@end deftypefn
