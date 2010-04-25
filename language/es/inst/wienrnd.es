md5="b085fb0d61afd062ebec25b5f7ef3cef";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} wienrnd (@var{t}, @var{d}, @var{n})
Retorna una implementación simulada del proceso de Wiener de @var{d} 
dimensiones en el intervalo [0, @var{t}]. Si se omite @var{d}, se usa 
@var{d} = 1. La primera columna de la matriz retornada contiene el tiempo, 
las columnas restantes contienen el proceso de Wiener.

El parámetro opcional @var{n} proporciona el número de sumandos 
usados para simular el proceso sobre un intervalo de longitud 1. Si se 
omite @var{n}, se usa @var{n} = 1000.
@end deftypefn
