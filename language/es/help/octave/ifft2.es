md5="17e8cb98e97d7b99f661fdd5b8df46d9";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} fft2 (@var{a}, @var{n}, @var{m})
Calcula la FFT inversa de dos dimensiones @var{a} usando las subrutinas 
de @sc{Fftw}. Los argumentos opcionales @var{n} y @var{m} pueden ser 
usados para especificar el n@'umero de filas y columnas de @var{a} que 
se van a usar. Si alguno de estos argumentos es mayor que el tama@~{n}o 
de @var{a}, se redimensiona @var{a} y se completa con ceros.

Si @var{a} es una matriz multidimensional, se trata separadamente cada 
submatriz de dos dimensiones de @var{a}.
@seealso {fft2, ifft, ifftn, fftw}
@end deftypefn
