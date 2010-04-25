md5="242719189e4abd88af513f6ea5ca2586";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} vol (@var{x}, @var{m}, @var{n})
Retorna la volatilidad de cada columna de la matriz de entrada @var{x}. 
El número de conjuntos de datos por periodo está dado por @var{m} 
(p.e. el número de datos por a@~{n}o, si se quiere calcular la 
volatilidad por a@~{n}o). El paránetro opcional @var{n} representa 
el número de periodos pasados usados para los cálculos, si se omite, 
se usa el valor 1. Si @var{t} es el número de filas de @var{x}, @code{vol} 
retorna la volatilidad de @code{n*m} hasta @var{t}.
@end deftypefn
