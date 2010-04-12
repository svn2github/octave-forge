md5="af32a73d91c1014f61920264508199f7";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} fft (@var{a}, @var{n}, @var{dim})
Calcula la FFT de @var{a} usando las subrutinas de @sc{Fftw}. La FFT se 
calcula a lo largo de la primera dimensi@'on no singleton del arreglo.
As@'i si @var{a} es una matriz, @code{fft (@var{a})} calcula la FFT 
para cada columna de @var{a}.

Si se llama con dos argumentos, se espera que @var{n} sea un entero
que especifica el n@'umero de elementos que se van a usar de @var{a}, 
o una matriz vacia para especificar que su valor deber@'ia ser ignorado. 
Si @var{n} es mayor que la dimensi@'on en la cual se va a calcular la 
FFT, se redimensiona @var{a} y completa con ceros. En otro caso, si @var{n} 
es menor que la dimensi@'on a lo largo de la cual se va a calcular la 
FFT, entonces se trunca @var{a}.

Si se llama con tres argumentos, @var{dim} es un entero que especifica la 
dimensi@'on de la matriz a lo largo de la cual se ejecutar@'a la FFT.
@seealso{ifft, fft2, fftn, fftw}
@end deftypefn
