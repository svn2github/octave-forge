md5="242719189e4abd88af513f6ea5ca2586";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} vol (@var{x}, @var{m}, @var{n})
Retorna la volatilidad de cada columna de la matriz de entrada @var{x}. 
El n@'umero de conjuntos de datos por periodo est@'a dado por @var{m} 
(p.e. el n@'umero de datos por a@~{n}o, si se quiere calcular la 
volatilidad por a@~{n}o). El par@'anetro opcional @var{n} representa 
el n@'umero de periodos pasados usados para los c@'alculos, si se omite, 
se usa el valor 1. Si @var{t} es el n@'umero de filas de @var{x}, @code{vol} 
retorna la volatilidad de @code{n*m} hasta @var{t}.
@end deftypefn
