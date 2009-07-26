md5="d5223776b257cd1db4ca849e16f43b74";rev="5920";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{p} =} colamd (@var{s})
@deftypefnx {Funci@'on cargable} {@var{p} =} colamd (@var{s}, @var{knobs})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{stats}] =} colamd (@var{s})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{stats}] =} colamd (@var{s}, @var{knobs})

Permutaci'on de m@'inimo grado de aproximaci@'on de columna. @code{@var{p} = colamd
(@var{s})} retorna el vector permutaci@'on de m@'inimo grado de aproximaci@'on de columna 
para la matriz dispersa @var{s}. Para una matriz no sim@'etrica @var{s},
@code{@var{s} (:,@var{p})} tiende a tener m@'as factores dispersos LU que @var{s}.
La factorizaci@'on Cholesky de @code{@var{s} (:,@var{p})' * @var{s}
(:,@var{p})} tambi@'en tiende a ser m@'as disperso que @code{@var{s}' * @var{s}}.

@var{knobs} es un vector de entrada opcional, de uno a tres elementos.  
Si @var{s} es m por n, las filas con m@'as de @code{max(16,@var{knobs}(1)*sqrt(n))} 
entradas se ignoran. Las columnas con m@'as de @code{max(16,knobs(2)*sqrt(min(m,n)))} 
entradas se eliminan antes del ordenamiento, y se ordenadan despu@'es en la 
permutaci@'on de salida @var{p}. Solo se remueven las filas o columnas complemente 
densas si @code{@var{knobs} (1)} y @code{@var{knobs} (2)} son < 0, respectivamente.
Si @code{@var{knobs} (3)} es distinto de cero, se imprime @var{stats} y @var{knobs}. 
El valor predetermiando es @code{@var{knobs} = [10 10 0]}. N@'otese que
@var{knobs} difiere de las versiones previas de colamd.

@var{stats} es un vector de salida opcional con 20 elementos que suministra datos
acerca del ordenamiento y la validez de la matriz de entrada @var{s}. Las 
estad@'isticas del ordenamiento estan en @code{@var{stats} (1:3)}. @code{@var{stats} (1)} y
@code{@var{stats} (2)} es el n@'umero de filas y columnas densas o vacias 
ignoradas por COLAMD y @code{@var{stats} (3)} es el n@'umero de recolecciones de basura 
realizadas en la estructura interna usada por COLAMD
(aproximadamente del tama@~{n}o de @code{2.2 * nnz(@var{s}) + 4 * @var{m} + 7 * @var{n}}
enteros).

Las funciones incorporadas de Octave est@'an destinadas a generar matrices 
dispersas v@'alidas, sin elementos duplicados, con @'idices de filas 
ascendentes de los elementos distintos de cero en cada columna, con n@'umero 
no negativo de entradas en cada una de las columnas (!), 
y as@'i sucesivamente. Si una matriz no es v@'alida, COLAMD puede o no ser 
capaz de continuar. Si existen entradas duplicadas (un @'indice de fila 
aparece dos o m@'as veces en la misma columna) o si los @'indices de de las 
filas en una columna est@'an desordenados, COLAMD puede corregir estos 
errores ignarando las entradas duplicadas y ordena cada columna de su copia 
interna de la matriz @var{s} (la matriz de entrada @var{s} no se modifica). 
Si una matriz no es v@'alida en otras formas, COLAMD no puede continuar, un 
mensaje de error se imprime, ni argumentos de salida (@var{p} o @var{stats}) 
se retornan. COLAMD es asi una simple forma de verificar si una matriz 
dispersa es v@'alida.

@code{@var{stats} (4:7)} suministra informaci@'on si COLAMD fue capaz de 
continuar. La matriz es v@'alida si @code{@var{stats} (4)} es cero, o 1 si es
inv@'alida. @code{@var{stats} (5)} es el @'indice de la columna extrema 
derecha que no esta ordenado o contiene entradas duplicadas, o cero si no 
existen tales columnas . 

@code{@var{stats} (6)} es el @'indice de la @'ultima fila duplicada o 
desordenada en el @'indice de columnas dado por @code{@var{stats} (5)}, o 
cero si no existen tales filas. @code{@var{stats} (7)} es el n@'umero de  
indices de filas duplicadas o desordenadas. @code{@var{stats} (8:20)} es 
siempre cero en la versi@'on actual de COLAMD (reservado para futuro uso).

El ordenamiento es seguido por una eliminaci@'on de columnas en posorden.

Los autores del c@'odigo mismo son Stefan I. Larimore y Timothy A.
Davis (davis@@cise.ufl.edu), University of Florida. El algoritmo fue 
desarrollado en colaboraci@'on con John Gilbert, Xerox PARC, y Esmond
Ng, Oak Ridge National Laboratory. (V@'ease
@url{http://www.cise.ufl.edu/research/sparse/colamd})
@seealso{colperm, symamd}
@end deftypefn
