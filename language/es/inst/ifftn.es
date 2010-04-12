md5="500363b72597bf22ed9cc06452c4c621";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} ifftn (@var{a}, @var{size})
Calcula la FFT inversa de N dimensiones de @var{a} mediante las subrutinas 
de @sc{Fftw}. El vector opcional @var{size} puede ser usado para 
especificar las dimensiones del arreglo que se va a usar. 

Si un elemento de @var{size} es menor que la dimensi@'on correspondiente, 
se trunca la dimensi@'on antes de realizar la FFT inversa. En otro caso, 
si un elemento de @var{size} es mayor que la dimensi@'on correspondiente 
de @var{a}, se redimensiona y se completa con ceros.
@seealso {fftn, ifft, ifft2, fftw}
@end deftypefn
