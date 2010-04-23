md5="af32a73d91c1014f61920264508199f7";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} fft (@var{a}, @var{n}, @var{dim})
Calcula la FFT de @var{a} usando las subrutinas de @sc{Fftw}. La FFT se 
calcula a lo largo de la primera dimensión no singleton del arreglo.
Así si @var{a} es una matriz, @code{fft (@var{a})} calcula la FFT 
para cada columna de @var{a}.

Si se llama con dos argumentos, se espera que @var{n} sea un entero
que especifica el número de elementos que se van a usar de @var{a}, 
o una matriz vacia para especificar que su valor debería ser ignorado. 
Si @var{n} es mayor que la dimensión en la cual se va a calcular la 
FFT, se redimensiona @var{a} y completa con ceros. En otro caso, si @var{n} 
es menor que la dimensión a lo largo de la cual se va a calcular la 
FFT, entonces se trunca @var{a}.

Si se llama con tres argumentos, @var{dim} es un entero que especifica la 
dimensión de la matriz a lo largo de la cual se ejecutará la FFT.
@seealso{ifft, fft2, fftn, fftw}
@end deftypefn
