md5="dc757d1763ba4dff5b1544ab29f727dc";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{d}, @var{dd}] =} diffpara (@var{x}, @var{a}, @var{b})
Retorna el estimador @var{d} para el par@'ametro diferenciador de una 
serie integrada en el tiempo.

Las frecuencias de @math{[2*pi*a/t, 2*pi*b/T]} se usan para la estimaci@'on. 
Si se omite @var{b}, se usa el intervalo @math{[2*pi/T, 2*pi*a/T]}. Si se 
omiten @var{b} y @var{a}, se usan @math{a = 0.5 * sqrt (T)} y @math{b = 1.5 * sqrt (T)}, donde @math{T} es el tama@~{n}o de la muestra. Si @var{x} es una matriz, 
se estima el par@'ametro diferenciador de cada columna.

Los estimadores para todas las frecuencias en los intervalos descritos 
anteriormente se retornan en @var{dd}. El valor de @var{d} es simplemente 
la media de @var{dd}.

Referencia: Brockwell, Peter J. & Davis, Richard A. Time Series:
Theory and Methods Springer 1987.
@end deftypefn
