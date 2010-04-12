md5="9844939d757c88edcdfa54da615a9a65";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} median (@var{x}, @var{dim})
Si @var{x} es un vector, calcula el valor medio de los elementos de 
@var{x}. Si los elementos de @var{x} son ordenados, la media esta
definida como

@iftex
@tex
$$
{\rm median} (x) =
  \cases{x(\lceil N/2\rceil), & $N$ odd;\cr
          (x(N/2)+x(N/2+1))/2, & $N$ even.}
$$
@end tex
@end iftex
@ifinfo

@example
@group
            x(ceil(N/2)),             N odd
median(x) =
            (x(N/2) + x((N/2)+1))/2,  N even
@end group
@end example
@end ifinfo
Si @var{x} es una matriz, calcula el valor de la media para cada
columna y los retorna luego en un vector fila. Si el argumento opcional
@var{dim} es dado, opera a lo lardo de la dimensi@'on. 
@seealso{std, mean}
@end deftypefn